SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_GEN_IN_DIR]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Ret int,
    @Cls char(10),
    @OrdNum char(10),
    @OrdDept char(14),
    @OrdTaxRateLmt decimal(24,4),
    @OrdFinished int,
    @OrdStat int,
    @OrdRecCnt int,
    @OrdReceiver int,
    @OrdAlcGid int,
    @DirAlcNum char(10),
    @SettleNo int,
    @Filler int,
    @VdrGid int,
    @VdrCode varchar(10),
    @VdrName varchar(100),
    @Sender int,
    @PayTerm int,
    @PayDate datetime,
    @OcrDate datetime,
    @Note varchar(255),
    @Total decimal(24,2),
    @Tax decimal(24,2),
    @AlcTotal decimal(24,2),
    @OutTax decimal(24,2),
    @RecCnt int,
    @RstWrh int,
    @UserGid int,
    @optGenInStat int,
    @optMstInputDept int,
    @optMstInputTaxRateLmt int,
    @optChkOption varchar(255)

  set @Cls = '直配进'

  --检查收货单的数据合法性
  
  if not exists(select * from GOODSRECEIPT(nolock)
    where NUM = @Num)
  begin
    set @Msg = '收货单号不存在：' + @Num
    return(1)
  end
  else if (select STAT from GOODSRECEIPT(nolock)
    where NUM = @Num) <> 100
  begin
    set @Msg = '收货单状态不是已审核，不能生成直配进货单'
    return(1)
  end
  else if exists(select * from DIRALC(nolock)
    where CLS = @Cls
    and STAT in (0, 7)
    and GENBILL = 'GOODSRECEIPT'
    and GENNUM = @Num)
  begin
    set @Msg = '收货单已被其他单导入，不能生成直配进货单'
    return(1)
  end

  --检查来源定单的数据合法性

  exec OptReadInt 84, 'MstInputDept', 0, @optMstInputDept output
  exec OptReadInt 84, 'MstInputTaxRateLmt', 0, @optMstInputTaxRateLmt output
  
  select @RstWrh = RSTWRH,
    @UserGid = USERGID
    from SYSTEM(nolock)

  select @OrdNum = o.NUM,
    @OrdDept = o.DEPT,
    @OrdTaxRateLmt = o.TAXRATELMT,
    @OrdFinished = o.FINISHED,
    @OrdStat = o.STAT,
    @OrdRecCnt = o.RECCNT,
    @OrdReceiver = o.RECEIVER,
    @OrdAlcGid = o.ALCGID,
    @VdrGid = o.VENDOR
    from GOODSRECEIPT gr(nolock), ORD o(nolock)
    where gr.SRCORDNUM = o.NUM
    and gr.NUM = @Num
  if @@rowcount = 0
  begin
    set @Msg = '来源定单不存在'
    return(1)
  end
  else if @OrdStat <> 1
  begin
    set @Msg = '来源定单不是已审核状态，不能生成直配进货单'
    return(1)
  end
  else if @OrdFinished <> 0
  begin
    set @Msg = '来源定单已经全部到货，不能生成直配进货单'
    return(1)
  end
  else if @optMstInputDept = 1 and @OrdDept is null
  begin
    set @Msg = '来源定单没有限制部门，不能生成直配进货单'
    return(1)
  end
  else if @optMstInputTaxRateLmt = 1 and @OrdTaxRateLmt is null
  begin
    set @Msg = '来源定单没有限制税率，不能生成直配进货单'
    return(1)
  end
  else if @RstWrh = 1 and (
    select count(*) from ORDDTL od(nolock)
    where od.NUM = @OrdNum
    and od.WRH in (select GID from V_WAREHOUSEH(nolock))) < @OrdRecCnt
  begin
    set @Msg = '来源定单要求高级别权限，不能生成直配进货单'
    return(1)
  end
  else if @RstWrh = 2 and (
    select count(*) from ORDDTL od(nolock)
    where od.NUM = @OrdNum
    and od.GDGID in (select GID from V_GOODSH(nolock))) < @OrdRecCnt
  begin
    set @Msg = '来源定单要求高级别权限，不能生成直配进货单'
    return(1)
  end
  else if exists(select * from STORE(nolock)
    where GID = @VdrGid and isnull(PROPERTY, 0) & 8 = 8)
  begin
    set @Msg = '来源定货单供应商是配货中心，不能生成直配进货单'
    return(1)
  end
  else if @UserGid <> @OrdReceiver
  begin
    set @Msg = '来源定货单收货单位不是本单位，不能生成直配进货单'
    return(1)
  end
  
  --结转期号
  select @SettleNo = max(NO) from MONTHSETTLE(nolock)
  
  --填单人
  exec Utils_GetOperGid @Oper, @Filler output
  
  --发生日期
  set @OcrDate = getdate()
  
  --付款期限
  select @VdrCode = v.CODE from VENDOR v(nolock)
    where v.GID = @VdrGid
  exec @Ret = GetPayDate @VdrCode, @OcrDate, @VdrGid output, @VdrName output,
    @PayTerm output, @PayDate output
  if @Ret <> 1 or @PayTerm <> 1
  begin
    set @PayDate = null
  end
  
  --发送方
  set @Sender = isnull(@OrdAlcGid, @UserGid)
  
  --备注
  set @Note = '由收货单 ' + @Num + ' 在审核时自动生成。'
  
  --抢占单号
  exec GENNEXTBILLNUMOLD @Cls, 'DIRALC', @DirAlcNum output
  
  --插入直配进货单汇总
  insert into DIRALC(CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER,
    OCRDATE, PSR, TOTAL, TAX, ALCTOTAL, STAT,
    SRC, SRCNUM, SNDTIME, NOTE, RECCNT, FILLER,
    CHECKER, MODNUM, VENDORNUM, FILDATE, FINISHED, ORDNUM,
    SRCORDNUM, WRH, GENBILL, GENCLS, GENNUM, SLR,
    TAXRATELMT, DEPT)
    select @Cls, @DirAlcNum, @SettleNo, o.VENDOR, @Sender, @UserGid,
    @OcrDate, o.PSR, 0.0, 0.0, 0.0, 0,
    @UserGid, null, null, @Note, 0, @Filler,
    1, null, null, @OcrDate, 0, @OrdNum,
    o.SRCNUM, o.WRH, 'GOODSRECEIPT', '收货', @Num, 1,
    o.TAXRATELMT, o.DEPT
    from ORD o(nolock)
    where o.NUM = @OrdNum

  --插入直配进货单明细
  
  exec OptReadStr 84, 'ChkOption', '', @optChkOption output
  
  declare
    @d_Line int,
    @d_GdGid int,
    @d_Cases decimal(24,4),
    @d_GdQty decimal(24,4),
    @d_Price decimal(24,4),
    @d_AlcPrc decimal(24,4),
    @d_AlcAmt decimal(24,2),
    @d_Total decimal(24,2),
    @d_Tax decimal(24,2),
    @d_OutTax decimal(24,2),
    @d_Cost decimal(24,2),
    @d_Wrh int,
    @d_OrdLine int,
    @d_BNum char(10),
    @d_ValidDate datetime,
    @g_InPrc decimal(24,4),
    @g_RtlPrc decimal(24,4),
    @g_WhsPrc decimal(24,4),
    @g_Qpc decimal(24,4),
    @g_TaxRate decimal(24,4),
    @g_SaleTax decimal(24,4),
    @g_Sale int
  declare c_GoodsReceiptDtl cursor for
    select grd.LINE, grd.GDGID, grd.GDQTY, isnull(grd.PRICE, od.PRICE),
    od.LINE, od.WRH, od.VALIDDATE, g.QPC, g.TAXRATE, g.INPRC, g.RTLPRC,
    g.SALE, g.WHSPRC, g.SALETAX
    from GOODSRECEIPTDTL grd(nolock), ORDDTL od(nolock), GOODS g(nolock)
    where grd.LINE = od.LINE
    and grd.GDGID = od.GDGID
    and grd.GDGID = g.GID
    and grd.NUM = @Num
    and od.NUM = @OrdNum
    order by grd.LINE
  open c_GoodsReceiptDtl
  fetch next from c_GoodsReceiptDtl into @d_Line, @d_GdGid, @d_GdQty, @d_Price,
    @d_OrdLine, @d_Wrh, @d_ValidDate, @g_Qpc, @g_TaxRate, @g_InPrc, @g_RtlPrc,
    @g_Sale, @g_WhsPrc, @g_SaleTax
  while @@fetch_status = 0
  begin
    --箱数
    if isnull(@g_Qpc, 0) = 0
      set @g_Qpc = 1
    set @d_Cases = @d_GdQty / @g_Qpc
    
    --含税金额
    set @d_Total = @d_GdQty * @d_Price
    
    --税额
    set @d_Tax = @d_Total / (100 + @g_TaxRate) * @g_TaxRate
    
    --配货价
    if substring(@optChkOption, 17, 1) = '1' --配货价是否与单价保持一致
    begin
      set @d_AlcPrc = @d_Price
    end
    else begin
      exec GetStoreOutPrc @StoreGid = @UserGid, @GdGid = @d_GdGid,
        @Wrh = @d_Wrh, @OutPrc = @d_AlcPrc output
      if @d_AlcPrc is null
        set @d_AlcPrc = 0
    end
    
    --配货额
    set @d_AlcAmt = @d_GdQty * @d_AlcPrc
    
    --出货税额
    set @d_OutTax = @d_AlcAmt / (100 + @g_SaleTax) * @g_SaleTax
    
    --成本额
    set @d_Cost = @d_GdQty * @g_InPrc
    
    --批号
    select @d_BNum = isnull(max(BNUM), replicate('0', 10))
      from DIRALCDTL(nolock)
      where CLS = @Cls
    exec NextBN @d_BNum, @d_BNum output

    insert into DIRALCDTL(CLS, NUM, LINE, SETTLENO, GDGID, WRH,
      CASES, QTY, LOSS, PRICE, TOTAL, TAX,
      WSPRC, INPRC, RTLPRC, VALIDDATE, BCKQTY, PAYQTY,
      BCKAMT, PAYAMT, ALCPRC, ALCAMT, BNUM, OUTTAX,
      RCPQTY, RCPAMT, NOTE, COST, COSTPRC, ORDLINE/*,
      SALE*/)
      select @Cls, @DirAlcNum, @d_Line, @SettleNo, @d_GdGid, @d_Wrh,
      @d_Cases, @d_GdQty, 0.0, @d_Price, @d_Total, @d_Tax,
      @g_WhsPrc, @g_InPrc, @g_RtlPrc, convert(varchar, @d_ValidDate, 102), 0.0, 0.0,
      0.0, 0.0, @d_AlcPrc, @d_AlcAmt, @d_BNum, @d_OutTax,
      0.0, 0.0, null, @d_Cost, @g_InPrc, @d_OrdLine/*,
      @g_Sale*/
    
    fetch next from c_GoodsReceiptDtl into @d_Line, @d_GdGid, @d_GdQty, @d_Price,
      @d_OrdLine, @d_Wrh, @d_ValidDate, @g_Qpc, @g_TaxRate, @g_InPrc, @g_RtlPrc,
      @g_Sale, @g_WhsPrc, @g_SaleTax
  end
  close c_GoodsReceiptDtl
  deallocate c_GoodsReceiptDtl

  --更新汇总信息
  select @Total = sum(TOTAL),
    @Tax = sum(TAX),
    @AlcTotal = sum(ALCAMT),
    @OutTax = sum(OUTTAX),
    @RecCnt = count(*)
    from DIRALCDTL(nolock)
    where CLS = @Cls
    and NUM = @DirAlcNum
    
  update DIRALC set
    TOTAL = @Total,
    TAX = @Tax,
    ALCTOTAL = @AlcTotal,
    OUTTAX = @OutTax,
    RECCNT = @RecCnt
    where CLS = @Cls
    and NUM = @DirAlcNum

  --进货单状态
  exec OptReadInt 8067, 'GenInStat', 0, @optGenInStat output
  if @optGenInStat = 7 --已预审
  begin
    update DIRALC set
      STAT = @optGenInStat,
      PRECHECKER = @Filler,
      PRECHKDATE = @OcrDate
      where CLS = @Cls
      and NUM = @DirAlcNum
  end
  else if @optGenInStat = 1 --已审核
  begin
    update DIRALC set
      CHECKER = @Filler
      where CLS = @Cls
      and NUM = @DirAlcNum
    exec @Ret = DirStkInChk @Cls = @Cls, @Num = @DirAlcNum, @Mode = 0
    if @Ret <> 0
      return(@Ret)
  end
  else if @optGenInStat = 6 --已复核
  begin
    update DIRALC set
      VERIFIER = @Filler
      where CLS = @Cls
      and NUM = @DirAlcNum
    exec @Ret = DirStkInChk @Cls = @Cls, @Num = @DirAlcNum, @Mode = 2
    if @Ret <> 0
      return(@Ret)
  end
  
  --锁定定货单
  exec @Ret = ReLockOrdDtl @Old_Num = @OrdNum, @Old_LockNum = @DirAlcNum,
    @Old_LockCls = @Cls
  
  return(0)
end
GO
