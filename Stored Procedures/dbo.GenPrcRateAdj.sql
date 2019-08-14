SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GenPrcRateAdj] (
  @p_num CHAR(14),
  @OperGid INT,  
  @Gen_Num CHAR(10) output,
  @errmsg VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE
    @Line INT,
    @GenPrcRateAdj INT,
    @return_status INT,
    @GdGid INT,
	  @piVdrGid int,
	  @piSort char(13),
	  @piBrand char(10),
	  @piPayRate decimal(24,4),
	  @OldPrc decimal(24,4), 
	  @QTY decimal(24,4),
	  @AdjAmt decimal(24,4),
	  @cuSum decimal(24,4),
	  @piSortCode char(13),
	  @piShopNo char(30),
    @SettleNo int,
    @Gen_Stat int,
    @AdjLtd8 int,
    @UserGid int,
    @RstDept int,
    @RstWrh int,
    @QPC DECIMAL(24,4),
    @QPCSTR CHAR(15)
    
  
  select @UserGid = UserGid, @RstWrh = RstWrh from system
  
  EXEC OPTREADINT 430, 'RSTDEPT', 0, @RstDept OUTPUT
      
	--调整联销率的商品存入临时表中TempAdjGoods
  EXEC OPTREADINT 86, 'PS3_AdjLtd8', 0, @AdjLtd8 OUTPUT
  if @AdjLtd8 = 1 
  begin
  	if (@RstDept = 0) and (@RstWrh = 0)
  	begin
			insert into TempAdjGoods (SPID, GdGid, VdrGid, Sort, Brand) 
			  select distinct @@Spid, g.gid, g.billto, g.F1, g.Brand from Goods g
			    left join VDRLESSEE v on g.billto = v.vdrgid 
		    where v.Num = @p_num and g.sale = 3
		end
	  else
	  begin
			insert into TempAdjGoods (spid, GdGid, VdrGid, Sort, Brand) 
			  select distinct @@spid, g.gid, g.billto, g.F1, g.Brand from V_Goods g
			    left join VDRLESSEE v on g.billto = v.vdrgid 
		    where v.Num = @p_num and g.sale = 3	  	
	  end
  end
  else if @AdjLtd8 = 0 
  begin
  	if (@RstDept = 0) and (@RstWrh = 0)
  	begin  	
			insert into TempAdjGoods (spid, GdGid, VdrGid, Sort, Brand) 
			  select distinct @@spid, g.gid, g.billto, g.F1, g.Brand from Goods g
			    left join VDRLESSEE v on g.billto = v.vdrgid 
		    where (v.Num = @p_num) and (isnull(g.IsLtd,0) & 8 <> 8) and (g.sale = 3)
		end
	  else
	  begin
			insert into TempAdjGoods (spid, GdGid, VdrGid, Sort, Brand) 
			  select distinct @@spid, g.gid, g.billto, g.F1, g.Brand from V_Goods g
			    left join VDRLESSEE v on g.billto = v.vdrgid 
		    where (v.Num = @p_num) and (isnull(g.IsLtd,0) & 8 <> 8) and (g.sale = 3)	  	
	  end
  end
  
  select @Line = count(1) from TempAdjGoods 
  if @Line = 0 
  begin
  	set @errmsg = '可调整商品不存在！'
  	return 1
  end 
  --生成联销率调整单
  exec GENNEXTBILLNUMEX '', 'PRCADJ', @Gen_Num output

  select @SettleNo = Max(NO) from MONTHSETTLE(nolock)
 
  --未审核 	  	
	Insert Into PrcAdj (Cls, Num, SettleNo, Filler, RecCnt, AdjAmt, Stat, Note)
  Values ('联销率', @Gen_Num, @SettleNo, @OperGid, @Line, @cuSum, 0, 
    '联销贸易协议改动后自动生成')
    
  set @cuSum = 0 
  set @Line = 0 
    
  if exists(select * from master..syscursors where cursor_name = 'c_TempAdjGoods')
    deallocate c_TempAdjGoods
  declare c_TempAdjGoods cursor for
    select GdGid, vdrgid, Sort, Brand from TempAdjGoods(nolock) where SPID = @@spid
  open c_TempAdjGoods
  fetch next from c_TempAdjGoods into @GdGid, @piVdrGid, @piSort, @piBrand
  while @@fetch_status = 0
  begin
	  
	  set @Line = @Line + 1 
	  
	  --获取联销率
	  execute VdrLeGetValue @piVdrGid, @piSort, @piBrand, @piPayRate OUTPUT, @piSortCode OUTPUT, @piShopNo OUTPUT

    if (@RstDept = 0) and (@RstWrh = 0) 
      select @OldPrc = PAYRATE, @Qty = v.QTY from Goods g, v_inv v
      where g.gid = @GdGid
      and v.GDGID = @GdGid 
      and v.store = @usergid
    else
      select @OldPrc = PAYRATE, @Qty = v.QTY from V_Goods g, v_inv v
      where g.gid = @GdGid
      and v.GDGID = @GdGid 
      and v.store = @usergid    	
       
    if (@RstDept = 0) and (@RstWrh = 0) 
      select @QPC = QPCQPC, @QPCSTR = QPCQPCSTR from V_QPCGOODS where Gid = @GdGid
    else
    	select @QPC = QPCQPC, @QPCSTR = QPCQPCSTR from V_V_QPCGOODS where Gid = @GdGid
    
    set @AdjAmt = (@OldPrc - @piPayRate) * @QTY / 100 
              
		Insert Into PrcAdjDtl (Cls, Num, Line, SettleNo, GdGid, OldPrc, NewPrc, Qty, QPC, QPCSTR)
		  Values('联销率', @Gen_Num, @Line, @SettleNo, @GdGid, @OldPrc, @piPayRate, @Qty, @QPC, @QPCSTR)
    
    set @cuSum = @cuSum + @AdjAmt
    
    fetch next from c_TempAdjGoods into @GdGid, @piVdrGid, @piSort, @piBrand
    
    if @@fetch_status = 0 
    begin
      update PrcAdj set AdjAmt = @cuSum
      where NUM = @Gen_Num

      EXEC OPTREADINT 705, 'GenPrcRateAdjStat', 0, @Gen_Stat OUTPUT      
      if @Gen_Stat = 1 
      	exec PRCADJCHK '联销率', @Gen_Num
    end
  end
  close c_TempAdjGoods
  deallocate c_TempAdjGoods
END	
GO
