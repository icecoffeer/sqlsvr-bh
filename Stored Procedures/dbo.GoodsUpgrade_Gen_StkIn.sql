SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_Gen_StkIn](
  @GoodsUpgradeNum char(14),
  @Oper char(30),
  @Msg varchar(255) output
)
as
begin
  /*当单据的“参加结算”属性的值是1时，就要生成自营进货单。*/

  declare
    @Return_Status smallint,
    @GoodsUpgradeStat smallint,
    @IsToSettle smallint,
    @StkInStat smallint,
    @StkInNum char(10),
    @SettleNo int,
    @Filler int,
    @Finished int,
    @OcrDate datetime,
    @VdrGid int,
    @VdrCode varchar(10),
    @VdrName varchar(100),
    @Return_Status_GetPayDate smallint,
    @PayTerm int,
    @PayDate datetime,
    @TaxRateLmt decimal(24,4),
    @DeptLmt varchar(64),
    @Total decimal(24,2),
    @Tax decimal(24,2),
    @RecCnt int,
    @Note varchar(255),
    @d_Line int,
    @d_GdGid int,
    @d_Qty decimal(24,4),
    @d_Total decimal(24,2),
    @d_Wrh int,
    @d_LastWrh int,
    @d_SNewFlag int,
    @g_BillTo int,
    @g_LastBillTo int,
    @g_F1 varchar(64),
    @g_LastF1 varchar(64),
    @g_TaxRate decimal(24,4),
    @g_LastTaxRate decimal(24,4),
    @g_InPrc decimal(24,4),
    @g_RtlPrc decimal(24,4),
    @g_Qpc decimal(24,4),
    @optMstInputDept int,
    @optMstInputTaxRateLmt int,
    @optGenBillStat int,
    @fetch_status int

  set @Return_Status = 0

  /*校验换货单合法性。*/

  select @GoodsUpgradeStat = STAT, @IsToSettle = ISTOSETTLE
    from GOODSUPGRADE(nolock)
    where NUM = @GoodsUpgradeNum

  if @@rowcount = 0
  begin
    set @Msg = '单据 ' + @GoodsUpgradeNum + ' 不存在。'
    return 1
  end
  else if @GoodsUpgradeStat is null or @GoodsUpgradeStat <> 100
  begin
    set @Msg = '不是已审核的单据，不能生成进货单。'
    return 1
  end
  else if exists(select 1 from GOODSUPGRADEGENBILLS(nolock)
    where NUM = @GoodsUpgradeNum
    and GENCLS = '自营进')
  begin
    set @Msg = '单据已经生成过自营进货单，不能再次生成。'
    return 1
  end

  --选项：部门限制
  exec OptReadInt 52, 'MstInputDept', 0, @optMstInputDept output

  --选项：税率限制
  exec OptReadInt 52, 'MstInputTaxRateLmt', 0, @optMstInputTaxRateLmt output

  --选项：生成单据的状态
  exec OptReadInt 8152, 'GENBILLSTAT', 0, @optGenBillStat output

  --结转期号
  select @SettleNo = max(NO) from MONTHSETTLE(nolock)

  --填单人
  exec Utils_GetOperGid @Oper, @Filler output

  --根据业务要求，如果不参与结算，直接审核生成的单据，且将已结标识设置为是
  if @IsToSettle = 0
  begin
    set @StkInStat = 1
    set @Finished = 1
    set @Note = '由商品换货单 ' + @GoodsUpgradeNum + ' 在审核时自动生成，不参与结算。'
  end
  else begin
    set @StkInStat = @optGenBillStat
    set @Finished = 0
    set @Note = '由商品换货单 ' + @GoodsUpgradeNum + ' 在审核时自动生成，参与结算。'
  end

  --生成单据
  declare c_GoodsUpgradeInDtl cursor for
    select d.GDGID, d.QTY, d.TOTAL, d.WRH, g.BILLTO,
    g.F1, g.TAXRATE, g.INPRC, g.RTLPRC, g.QPC
    from GOODSUPGRADEINDTL d(nolock), GOODS g(nolock)
    where d.GDGID = g.GID
    and d.NUM = @GoodsUpgradeNum
    order by d.WRH, g.BILLTO, g.F1, g.TAXRATE
  open c_GoodsUpgradeInDtl

  fetch next from c_GoodsUpgradeInDtl into
    @d_GdGid, @d_Qty, @d_Total, @d_Wrh, @g_BillTo,
    @g_F1, @g_TaxRate, @g_InPrc, @g_RtlPrc, @g_QPC
  set @fetch_status = @@fetch_status

  --初始化分单条件
  set @d_LastWrh = -99999
  set @g_LastBillTo = -99999
  set @g_LastF1 = 'never'
  set @g_LastTaxRate = -9.9

  --遍历换货单换入明细商品
  while @fetch_status = 0
  begin
    --当遇到新的仓位、缺省供应商、部门或税率时，则新建一张单据
    if (@d_Wrh <> @d_LastWrh)
      or (@g_LastBillTo <> @g_BillTo)
      or (@optMstInputTaxRateLmt = 1 and @g_LastTaxRate <> @g_TaxRate)
      or (@optMstInputDept = 1 and @g_LastF1 <> @g_F1)
    begin
      --准备汇总数据

      --付款期限
      select @VdrCode = v.CODE from VENDOR v(nolock) where v.GID = @g_BillTo
      set @OcrDate = getdate()

      exec @Return_Status_GetPayDate = GetPayDate @VdrCode, @OcrDate, @VdrGid output,
        @VdrName output, @PayTerm output, @PayDate output

      if isnull(@Return_Status_GetPayDate, 0) <> 1 or isnull(@PayTerm, 0) <> 1
      begin
        set @PayDate = null
      end

      --税率限制
      if @optMstInputTaxRateLmt = 1
        set @TaxRateLmt = @g_TaxRate
      else
        set @TaxRateLmt = null

      --部门限制
      if @optMstInputDept = 1
        set @DeptLmt = @g_F1
      else
        set @DeptLmt = null

      --新单号
      exec GENNEXTBILLNUMOLD '自营', 'STKIN', @StkInNum output

      --插入汇总，抢占单号
      insert into STKIN(CLS, NUM, ORDNUM, SETTLENO, VENDOR,
        VENDORNUM, BILLTO, OCRDATE, TOTAL, TAX,
        NOTE, FILDATE, PAYDATE, FINISHED, FILLER,
        CHECKER, STAT, MODNUM, PSR, RECCNT,
        SRC, SRCNUM, SNDTIME, PRNTIME, WRH,
        GENBILL, GENCLS, GENNUM, TAXRATELMT, DEPT)
        select '自营', @StkInNum, null, @SettleNo, @g_BillTo,
        null, @g_BillTo, getdate(), 0.0, 0.0,
        @Note, getdate(), @PayDate, @Finished, @Filler,
        @Filler, 0, null, 1, 0,
        s.USERGID, null, null, null, @d_Wrh,
        'GOODSUPGRADE', null, @GoodsUpgradeNum, @TaxRateLmt, @DeptLmt
        from SYSTEM s(nolock)

      --登记生成的单据
      insert into GOODSUPGRADEGENBILLS(NUM, GENCLS, GENNUM)
        select @GoodsUpgradeNum, '自营进', @StkInNum

      --更新分单条件
      set @d_LastWrh = @d_Wrh
      set @g_LastBillTo = @g_BillTo
      set @g_LastF1 = @g_F1
      set @g_LastTaxRate = @g_TaxRate
    end

    --插入明细，相同的商品要合并成一行
    if exists(select 1 from STKINDTL(nolock) where CLS = '自营' and NUM = @StkInNum and GDGID = @d_GdGid)
    begin
      select @d_Line = LINE
        from STKINDTL(nolock)
        where CLS = '自营'
        and NUM = @StkInNum
        and GDGID = @d_GdGid
    end
    else begin
      --获取行号
      select @d_Line = isnull(max(LINE), 0) + 1
        from STKINDTL(nolock)
        where CLS = '自营'
        and NUM = @StkInNum

      --首次上架标识
      if exists(select 1 from INYRPT(nolock) where ASETTLENO = @SettleNo and BGDGID = @d_GdGid)
        set @d_SNewFlag = 0
      else
        set @d_SNewFlag = 1

      insert into STKINDTL(CLS, SETTLENO, NUM, LINE, GDGID, CASES,
        QTY, LOSS, PRICE, TOTAL, TAX, VALIDDATE,
        WRH, BCKQTY, PAYQTY, INPRC, RTLPRC, PAYAMT,
        BCKAMT, BNUM, SUBWRH, NOTE, ORDLINE, SNEWFLAG,
        CHECKOUTFLAG, DECORDQTY)
        select '自营', @SettleNo, @StkInNum, @d_Line, @d_GdGid, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, null,
        @d_Wrh, 0.0, 0.0, @g_InPrc, @g_RtlPrc, 0.0,
        0.0, null, null, null, 0, @d_SNewFlag,
        null, null
    end

    update STKINDTL set
      QTY = QTY + @d_Qty,
      TOTAL = TOTAL + @d_Total
      where CLS = '自营'
      and NUM = @StkInNum
      and LINE = @d_Line

    if isnull(@g_Qpc, 0) = 0
      set @g_Qpc = 1

    update STKINDTL set
      CASES = round(QTY / @g_QPC, 3),
      PRICE = TOTAL / QTY,
      TAX = round(TOTAL * @g_TaxRate / (100.0 + @g_TaxRate), 2)
      where CLS = '自营'
      and NUM = @StkInNum
      and LINE = @d_Line

    --取下一条商品信息
    fetch next from c_GoodsUpgradeInDtl into
      @d_GdGid, @d_Qty, @d_Total, @d_Wrh, @g_BillTo,
      @g_F1, @g_TaxRate, @g_InPrc, @g_RtlPrc, @g_QPC
    set @fetch_status = @@fetch_status

    --如果不存在下一条商品，或者从下一条商品开始需要新建单据，则更新当前单据的几个属性，并审核进货单
    if @fetch_status <> 0
      or (@d_LastWrh <> @d_Wrh)
      or (@g_LastBillTo <> @g_BillTo)
      or (@optMstInputTaxRateLmt = 1 and @g_LastTaxRate <> @g_TaxRate)
      or (@optMstInputDept = 1 and @g_LastF1 <> @g_F1)
    begin
      select @Total = isnull(sum(TOTAL), 0), @Tax = isnull(sum(TAX), 0), @RecCnt = count(1)
        from STKINDTL(nolock)
        where CLS = '自营'
        and NUM = @StkInNum

      update STKIN set
        TOTAL = @Total,
        TAX = @Tax,
        RECCNT = @RecCnt
        where CLS = '自营'
        and NUM = @StkInNum

      --改变单据状态
      if @StkInStat = 7 --已预审
      begin
        update STKIN set
          STAT = @StkInStat,
          PRECHECKER = @Filler,
          PRECHKDATE = getdate()
          where CLS = '自营'
          and NUM = @StkInNum
      end
      else if @StkInStat = 1 --已审核
      begin
        update STKIN set
          CHECKER = @Filler
          where CLS = '自营'
          and NUM = @StkInNum
        exec @Return_Status = STKINCHK @Cls = '自营', @Num = @StkInNum, @Mode = 0, @ChkFlag = 0, @ErrMsg = @Msg output
        if @Return_Status <> 0
          goto LABEL_BEFORE_EXIT
      end
      else if @StkInStat = 6 --已复核
      begin
        update STKIN set
          VERIFIER = @Filler
          where CLS = '自营'
          and NUM = @StkInNum
        exec @Return_Status = STKINCHK @Cls = '自营', @Num = @StkInNum, @Mode = 2, @ChkFlag = 0, @ErrMsg = @Msg output
        if @Return_Status <> 0
          goto LABEL_BEFORE_EXIT
      end
    end
  end

LABEL_BEFORE_EXIT:
  close c_GoodsUpgradeInDtl
  deallocate c_GoodsUpgradeInDtl
  if @Return_Status <> 0
    return @Return_Status

  return 0
end
GO
