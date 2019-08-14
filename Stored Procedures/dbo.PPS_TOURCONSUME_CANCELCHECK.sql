SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_TOURCONSUME_CANCELCHECK](
  @Num varchar(14),                 --单号
  @Cls varchar(10),                 --类别
  @Oper varchar(30),                 --操作员
  @ToStat integer,                  --操作时间
  @Msg varchar(255) output          --操作人
) as
begin
  declare
    @nItemNo integer,
    @nCount integer,
    @FromStat integer,
    @PledgeMon decimal(24, 4),
    @TourFeeMon decimal(24, 4),
    @TourFeeType varchar(50)
    
  
  select @nCount = count(1) from ToursConsume(nolock) where Num = @Num
  if @nCount = 0 
  begin
    select @Msg = '指定单据不存在！'
    return(1)
  end 
  
  select @FromStat = Stat, @TourFeeType = TourFeeType, @PledgeMon = PledgeMon from ToursConsume(nolock) where Num = @Num
  
  if @FromStat <> 100 
  begin
    select @Msg = '单据不是审核状态！'
    return(1)
  end
  
  select @TourFeeMon = 0
  if @TourFeeType = '普通比例' 
  begin
    select @TourFeeMon = @PledgeMon
  end       
  
  update ToursConsume set Stat = 0, Checker = '', ChkDate = Null, LstUpdOper = @Oper, LstUpdTime = GetDate(),
    TourFeeMon = CustomersTotal + @TourFeeMon, InnerFeeMon = 0, ConTotal = 0, SettleMon = CustomersTotal + @TourFeeMon, DisTotal = 0
  where Num = @Num
  delete from ToursConsumeDtl where Num = @Num
  delete from ToursConsumeDisDtl where Num = @num
  
  select @nItemNo = IsNull(Max(ItemNo), 0) + 1 from ToursConsumeLog(nolock) where Num = @Num
  insert into ToursConsumeLog(Num, ItemNo, FromStat, ToStat, Oper, OperTime)
  values(@Num, @nItemNo, 100, 0, @Oper, GetDate())  
  return(0)
end
GO
