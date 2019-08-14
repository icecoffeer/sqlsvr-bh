SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_GEN_IN_STK]
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
    @StkInNum char(10),
    @SettleNo int,
    @Filler int,
    @VdrGid int,
    @VdrCode varchar(10),
    @VdrName varchar(100),
    @PayTerm int,
    @PayDate datetime,
    @OcrDate datetime,
    @Note varchar(255),
    @Total decimal(24,2),
    @Tax decimal(24,2),
    @RecCnt int,
    @RstWrh int,
    @UserGid int,
    @optGenInStat int,
    @optMstInputDept int,
    @optMstInputTaxRateLmt int

  set @Cls = '自营'

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
    set @Msg = '收货单状态不是已审核，不能生成自营进货单'
    return(1)
  end
  else if exists(select * from STKIN(nolock)
    where CLS = @Cls
    and STAT in (0, 7)
    and GENBILL = 'GOODSRECEIPT'
    and GENNUM = @Num)
  begin
    set @Msg = '收货单已被其他单导入，不能生成自营进货单'
    return(1)
  end

  --检查来源定单的数据合法性

  exec OptReadInt 52, 'MstInputDept', 0, @optMstInputDept output
  exec OptReadInt 52, 'MstInputTaxRateLmt', 0, @optMstInputTaxRateLmt output
  
  select @RstWrh = RSTWRH,
    @UserGid = USERGID
    from SYSTEM(nolock)

  select @OrdNum = o.NUM,
    @OrdDept = o.DEPT,
    @OrdTaxRateLmt = o.TAXRATELMT,
    @OrdFinished = o.FINISHED,
    @OrdStat = o.STAT,
    @OrdRecCnt = o.RECCNT,
    @VdrGid = o.VENDOR
    from GOODSRECEIPT gr(nolock), ORD o(nolock)
    where gr.SRCORDNUM = o.NUM
    and gr.NUM = @Num
  if @@rowcount = 0
  begin
    set @Msg = '来源定单不存在'
    return(1)
  end
  else if @optMstInputDept = 1 and @OrdDept is null
  begin
    set @Msg = '来源定单没有限制部门，不能生成自营进货单'
    return(1)
  end
  else if @optMstInputTaxRateLmt = 1 and @OrdTaxRateLmt is null
  begin
    set @Msg = '来源定单没有限制税率，不能生成自营进货单'
    return(1)
  end
  else if @OrdFinished <> 0
  begin
    set @Msg = '来源定单已经全部到货，不能生成自营进货单'
    return(1)
  end
  else if @RstWrh = 1 and (
    select count(*) from ORDDTL od(nolock)
    where od.NUM = @OrdNum
    and od.WRH in (select GID from V_WAREHOUSEH(nolock))) < @OrdRecCnt
  begin
    set @Msg = '来源定单要求高级别权限，不能生成自营进货单'
    return(1)
  end
  else if @RstWrh = 2 and (
    select count(*) from ORDDTL od(nolock)
    where od.NUM = @OrdNum
    and od.GDGID in (select GID from V_GOODSH(nolock))) < @OrdRecCnt
  begin
    set @Msg = '来源定单要求高级别权限，不能生成自营进货单'
    return(1)
  end
  else if @OrdStat <> 1
  begin
    set @Msg = '来源定单不是已审核状态，不能生成自营进货单'
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
  
  --备注
  set @Note = '由收货单 ' + @Num + ' 在审核时自动生成。'
  
  --抢占单号
  exec GENNEXTBILLNUMOLD @Cls, 'STKIN', @StkInNum output
  
  --插入自营进货单汇总
  insert into STKIN(CLS, NUM, ORDNUM, SETTLENO, VENDOR, VENDORNUM,
    BILLTO, OCRDATE, TOTAL, TAX, NOTE, FILDATE,
    PAYDATE, FINISHED, FILLER, CHECKER, STAT, MODNUM,
    PSR, RECCNT, SRC, SRCNUM, SNDTIME, PRNTIME,
    WRH, GENBILL, GENCLS, GENNUM, TAXRATELMT, DEPT)
    select @Cls, @StkInNum, o.NUM, @SettleNo, o.VENDOR, null,
    o.VENDOR, @OcrDate, 0, 0, @Note + o.NOTE, @OcrDate,
    @PayDate, 0, @Filler, @Filler, 0, null,
    o.PSR, 0, @UserGid, null, null, null,
    o.WRH, 'GOODSRECEIPT', '收货', @Num, @OrdTaxRateLmt, @OrdDept
    from ORD o(nolock)
    where NUM = @OrdNum

  --插入自营进货单明细
  declare
    @d_Line int,
    @d_GdGid int,
    @d_Cases decimal(24,4),
    @d_GdQty decimal(24,4),
    @d_Price decimal(24,4),
    @d_Total decimal(24,2),
    @d_Tax decimal(24,2),
    @d_Wrh int,
    @d_OrdLine int,
    @g_InPrc decimal(24,4),
    @g_RtlPrc decimal(24,4),
    @g_Qpc decimal(24,4),
    @g_TaxRate decimal(24,4),
    @g_Sale int
  declare c_GoodsReceiptDtl cursor for
    select grd.LINE, grd.GDGID, grd.GDQTY, isnull(grd.PRICE, od.PRICE),
      od.LINE, od.WRH, g.QPC, g.TAXRATE, g.INPRC, g.RTLPRC, g.SALE
    from GOODSRECEIPTDTL grd(nolock), ORDDTL od(nolock), GOODS g(nolock)
    where grd.LINE = od.LINE
    and grd.GDGID = g.GID
    and grd.NUM = @Num
    and od.NUM = @OrdNum
    order by grd.LINE
  open c_GoodsReceiptDtl
  fetch next from c_GoodsReceiptDtl into @d_Line, @d_GdGid, @d_GdQty, @d_Price,
    @d_OrdLine, @d_Wrh, @g_Qpc, @g_TaxRate, @g_InPrc, @g_RtlPrc, @g_Sale
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

    insert into STKINDTL(CLS, SETTLENO, NUM, LINE, GDGID, CASES,
      QTY, LOSS, PRICE, TOTAL, TAX, VALIDDATE,
      WRH, BCKQTY, PAYQTY, INPRC, RTLPRC, PAYAMT,
      BCKAMT, BNUM, SUBWRH, NOTE, ORDLINE, SNEWFLAG,
      CHECKOUTFLAG, DECORDQTY/*, SALE*/)
      select @Cls, @SettleNo, @StkInNum, @d_Line, @d_GdGid, @d_Cases,
      @d_GdQty, 0, @d_Price, @d_Total, @d_Tax, null,
      @d_Wrh, 0, 0, @g_InPrc, @g_RtlPrc, 0,
      0, null, null, null, @d_OrdLine, 0,
      null, null/*, @g_Sale*/
    
    fetch next from c_GoodsReceiptDtl into @d_Line, @d_GdGid, @d_GdQty, @d_Price,
      @d_OrdLine, @d_Wrh, @g_Qpc, @g_TaxRate, @g_InPrc, @g_RtlPrc, @g_Sale
  end
  close c_GoodsReceiptDtl
  deallocate c_GoodsReceiptDtl

  --更新汇总信息
  select @Total = sum(TOTAL),
    @Tax = sum(TAX),
    @RecCnt = count(*)
    from STKINDTL(nolock)
    where CLS = @Cls
    and NUM = @StkInNum
    
  update STKIN set
    TOTAL = @Total,
    TAX = @Tax,
    RECCNT = @RecCnt
    where CLS = @Cls
    and NUM = @StkInNum

  --进货单状态
  exec OptReadInt 8067, 'GenInStat', 0, @optGenInStat output
  if @optGenInStat = 7 --已预审
  begin
    update STKIN set
      STAT = @optGenInStat,
      PRECHECKER = @Filler,
      PRECHKDATE = @OcrDate
      where CLS = @Cls
      and NUM = @StkInNum
  end
  else if @optGenInStat = 1 --已审核
  begin
    update STKIN set
      CHECKER = @Filler
      where CLS = @Cls
      and NUM = @StkInNum
    exec @Ret = STKINCHK @Cls = @Cls, @Num = @StkInNum, @Mode = 0, @ChkFlag = 0,
      @ErrMsg = @Msg output
    if @Ret <> 0
      return(@Ret)
  end
  else if @optGenInStat = 6 --已复核
  begin
    update STKIN set
      VERIFIER = @Filler
      where CLS = @Cls
      and NUM = @StkInNum
    exec @Ret = STKINCHK @Cls = @Cls, @Num = @StkInNum, @Mode = 2, @ChkFlag = 0,
      @ErrMsg = @Msg output
    if @Ret <> 0
      return(@Ret)
  end
  
  --锁定定货单
  exec @Ret = ReLockOrdDtl @Old_Num = @OrdNum, @Old_LockNum = @StkInNum,
    @Old_LockCls = @Cls
  
  return(0)
end
GO
