SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_TOURCONSUME_IMPROTBUYDATA](
  @piNum varchar(14),                 --单号
  @piCardNum varchar(20),             --卡号
  @piDate datetime,                   --操作时间
  @piOper varchar(30),                --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare 
    @nCount integer,
    @PosNo varchar(20),
    @FlowNo varchar(20),
    @nLine integer,
    @ItemNo integer,
    @Gid integer, 
    @Qty decimal(24, 4), 
    @RealAmt decimal(24, 4),
    @TourGuideDis decimal(24, 4),
    @TourGuideSpecDis decimal(24, 4),
    @EmpRate decimal(24, 4),
    @ShopGuideRate decimal(24, 4),
    @sumRealAmt decimal(24, 4),
    @TourFeeType varchar(50),
    @TourDis decimal(24, 4),
    @TourSpecDis decimal(24, 4),
    @PledgeMon decimal(24, 4),
    @TourFeeMon decimal(24, 4),
    @InnerFeeMon decimal(24, 4),
    @DisTotal decimal(24, 4)
    
    
  declare curBuy cursor for
    select PosNo, FlowNo 
    from Buy1(nolock) 
    where CardCode = @piCardNum and convert(varchar(12), FilDate, 102) = convert(varchar(12), @piDate, 102)
        
  select @nCount = count(1) from ToursConsume(nolock) where Num = @piNum
  if @nCount = 0 
  begin
    select @poErrMsg = '指定单据不存在！'
    return(1)
  end   
  
  ---导入数据
  delete from ToursConsumeDtl where Num = @piNum
  
  select @nLine = 0
  open curBuy  
  fetch next from curBuy into @PosNo, @FlowNo      
  while @@fetch_status = 0      
  begin
    declare curBuy2 cursor for         
      select Dtl.ItemNo, Dtl.Gid, Dtl.Qty, Dtl.RealAmt, GD.TourGuideDis, 
        GD.TourGuideSpecDis, GD.EmpRate, GD.ShopGuideRate 
      from Buy2 Dtl(nolock), NativeProductGoods GD(nolock)
      where PosNo = @PosNo and FlowNo = @FlowNo and  Dtl.Gid = GD.Gid 
      and ItemNo not in (select ItemNo from ToursConsumeDtl where PosNo = @PosNo and FlowNo = @FlowNo)      
    open curBuy2 
    fetch next from curBuy2 into @ItemNo, @Gid, @Qty, @RealAmt, @TourGuideDis,
      @TourGuideSpecDis, @EmpRate, @ShopGuideRate 
    while @@fetch_status = 0 
    begin
      select @nLine = @nLine + 1
      insert into ToursConsumeDtl(Num, Line, PosNo, FlowNo, ItemNo, 
        Gid, Qty, RealAmt, TourGuideDis, TourGuideSpecDis, 
        EmpRate, ShopGuideRate)
      values(@piNum, @nLine, @PosNo, @FlowNo, @ItemNo,
        @Gid, @Qty, @RealAmt, @TourGuideDis, @TourGuideSpecDis,
        @EmpRate, @ShopGuideRate)   
      fetch next from curBuy2 into @ItemNo, @Gid, @Qty, @RealAmt, @TourGuideDis, 
        @TourGuideSpecDis, @EmpRate, @ShopGuideRate  
    end    
    close curBuy2
    deallocate curBuy2                                
    fetch next from curBuy into @PosNo, @FlowNo      
  end                                                            
  close curBuy
  deallocate curBuy  
  
  ---计算汇总值 
  ---消费总额
  select @TourFeeType = TourFeeType, @PledgeMon = IsNull(PledgeMon, 0) from ToursConsume(nolock) where Num = @piNum
  select @TourDis = IsNull(sum(IsNull(RealAmt, 0) * IsNull(TourGuideDis, 0) / 100), 0),
         @TourSpecDis = IsNull(sum(IsNull(RealAmt, 0) * IsNull(TourGuideSpecDis, 0) / 100), 0),
         @InnerFeeMon = IsNull(sum(IsNull(RealAmt, 0) * IsNull(EmpRate, 0) / 100), 0) + IsNull(sum(IsNull(RealAmt, 0) * IsNull(ShopGuideRate, 0) / 100), 0),
         @sumRealAmt = IsNull(sum(IsNull(RealAmt, 0)), 0)
  from ToursConsumeDtl(nolock)
  where Num = @piNum      
  
  ---根据提成类型计算明细提成
  if @TourFeeType = '普通比例' 
  begin
    if @PledgeMon > @TourDis
      select @TourFeeMon = @PledgeMon
    else    
      select @TourFeeMon = @TourDis
    
    update ToursConsumeDtl set DisTotal = IsNull(TourGuideDis, 0) * RealAmt / 100 where Num = @piNum       
    select @DisTotal = @TourDis
  end else if @TourFeeType = '特殊比例'
  begin
    select @TourFeeMon = @TourSpecDis
    update ToursConsumeDtl set DisTotal = IsNull(TourGuideSpecDis, 0) * RealAmt / 100 where Num = @piNum
    select @DisTotal = @TourSpecDis
  end else 
  begin 
    select @poErrMsg = '提成类型设置错误！'
    return(1)
  end     
  
  update ToursConsume set TourFeeMon = IsNull(@TourFeeMon, 0) + IsNull(CustomersTotal, 0), 
    InnerFeeMon = IsNull(@InnerFeeMon, 0), 
    ConTotal = IsNull(@sumRealAmt, 0), 
    SettleMon = IsNull(@TourFeeMon, 0) + IsNull(CustomersTotal, 0),
    DisTotal = IsNull(@DisTotal, 0)                              
  where Num = @piNum  
  
  
  ---计算商品提成信息  
  if @TourFeeType = '普通比例' 
  begin
    declare curDtl cursor for 
      select sum(IsNull(RealAmt, 0)) RealAmt, TourGuideDis  GDDis
      from ToursConsumeDtl(nolock)
      where Num = @piNum
      group by TourGuideDis 
      order by TourGuideDis 
  end else if @TourFeeType = '特殊比例'
  begin
    declare curDtl cursor for 
      select sum(IsNull(RealAmt, 0)) RealAmt, TourGuideSpecDis  GDDis
      from ToursConsumeDtl(nolock)
      where Num = @piNum
      group by TourGuideSpecDis  
      order by TourGuideSpecDis  
  end 
 
  delete from ToursConsumeDisDtl     
  select @nLine = 0     
  open curDtl
  fetch next from curDtl into @RealAmt, @TourGuideDis
  while @@fetch_status = 0 
  begin
    select @nLine = @nLine + 1
    insert into ToursConsumeDisDtl(Num, Line, GDDis, RealAmt, DisTotal)
    values(@piNum, @nLine, IsNull(@TourGuideDis, 0), IsNull(@RealAmt, 0),  IsNull(@RealAmt, 0) * IsNull(@TourGuideDis, 0) / 100)    
    fetch next from curDtl into @RealAmt, @TourGuideDis    
  end 
  close curDtl
  deallocate curDtl

  return(0)
end
GO
