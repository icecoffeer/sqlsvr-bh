SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_GenWholeSaleBckFromOuterBill]
(
  @pi_PlatForm VarChar(80), --来源平台: Intra
  @pi_BillNum VarChar(50), --来源单号
  @po_Msg varchar(255) output --错误信息
)
As
Begin
  Declare
    @v_Cls Varchar(10),
    @v_SettleNo int,
    @v_UserGid int,
    @v_Filler int,
    @v_UUID VarChar(100),
    @v_NewNum VarChar(14),
    @v_Note VarChar(255),
    @v_SrcPlat Varchar(20),
    @v_Total Money, --中间表金额
    @v_EmpCode Varchar(20), --填单人
    @v_CltCode Varchar(20), --客户代码
    @v_BilltoCode Varchar(20), --结算单位代码
    @v_CltGid int,
    @v_BilltoGid int,

    @v_Line int,
    @v_GdCode VarChar(40),
    @v_Price Money,
    @v_DtlTotal Money,
    @v_Qty Money,
    @v_GdGid int,
    @v_Ret int,
    @v_Wrh int,
    @v_Count int,
    @v_ItemNo int,
    @v_Direction int, /*1:调增 -1:调减*/
    @v_CurDate Datetime

  Select @v_SettleNo = Max(No) from MONTHSETTLE
  Select @v_UserGid = UserGid, @v_Wrh = DFTWRH
    From System(Nolock)
  Select @v_CurDate = Convert(Datetime, Convert(Char, Getdate(), 102))

  Select @v_UUID = UUID, @v_EmpCode = '-', @v_CltCode = '-',
    @v_BilltoCode = '-', @v_Total = Amount, @v_Direction = Direction
  From PS3_OuterOutMst(Nolock)
    Where PlatForm = @pi_PlatForm And BillNum = @pi_BillNum
  --处理状态需是"未处理"才能生成批发退单
  IF @@RowCount = 0
  begin
    Set @po_Msg = '外部生成出货单据表中不存在指定的单据'
    Return 1
  end

  --检查已生成单据表
  select @v_Count = Count(1)
    from PS3_OuterGenBills(nolock)
  where PlatForm = @pi_PlatForm and UUID = @v_UUID and GenBillName = '批发退货单'
  if @v_Count <> 0
  begin
    set @po_Msg = '表PS3_OuterGenBills已生成该外部单据的批发退单'
    return 0
  end

  --从外部生成出货退单据中获取 填单人,客户和结算单位
  Select @v_Filler = Gid From Employee Where Code = @v_EmpCode
  if @@RowCount = 0
  Begin
    Set @po_Msg = 'POS3员工资料中不存在填单人:' + @v_EmpCode
    Return 1
  End
  Select @v_CltGid = Gid From Client Where Code = @v_CltCode
  if @@RowCount = 0
  begin
    Set @po_Msg = 'POS3客户资料中不存在客户:' + @v_CltCode
    Return 1
  end
  Select @v_BilltoGid = GID From Client Where Code = @v_BilltoCode
  IF @v_BilltoGid is null
  begin
    Set @po_Msg = 'POS3客户资料中不存在结算单位:' + @v_BilltoCode
    Return 1
  end

  --生成批发退货单
  Set @v_Cls = '批发'

  --抢占单号
  Select @v_NewNum = Isnull(Max(Num), '0000000001')
    From StkoutBck(Nolock) Where Cls = @v_Cls
  Exec NEXTBN @v_NewNum, @v_NewNum Output

  --写主表
  insert into STKOUTBCK (Cls, Num, Settleno, Wrh, Client, Billto, Ocrdate, Total, Tax,
    Fildate, Filler, Stat, Reccnt, Src)
  Values (@v_Cls, @v_NewNum, @v_SettleNo, @v_Wrh, @v_CltGid, @v_BilltoGid, Getdate(), 0, 0,
    Getdate(), @v_Filler, 0, 0, @v_UserGid)

  Set @v_Line = 0
  --读取中间表缓存表
  Declare C_OOGwsb Cursor Local For
    Select ltrim(rtrim(REPLACE(gdcode,' ',''))), Qty, Price, Amount
      From PS3_OuterOutGoods
    Where UUID = @v_UUID
  Open C_OOGwsb
  Fetch Next From C_OOGwsb into
    @v_GdCode, @v_Qty, @v_Price, @v_DtlTotal
  While @@Fetch_Status = 0
  Begin
    select @v_Line = @v_Line + 1
    Select @v_GdGid = Gid From GdInput Where Code = @v_GdCode
    Declare
      @v_TaxRate Money, @v_WsPrc Money, @v_Inprc Money,
      @v_RtlPrc Money, @v_Qpc Money, @v_Cost Money, @v_Tax Money,
      @v_Sale int, @v_Payrate money, @v_Vdr int
    select
      @v_TaxRate = Taxrate,
      @v_Wsprc = Whsprc,
      @v_Inprc = Inprc,
      @v_Rtlprc = Rtlprc,
      @v_Qpc = IsNull(Qpc, 1),
      @v_Sale = Sale,
      @v_Payrate = PayRate,
      @v_Vdr = Billto
    From Goods(Nolock)
      Where Gid = @v_GdGid
    If @v_Qpc = 0
      Set @v_Qpc = 1
    If @v_Qty = 0
      Set @v_Qty = 1
    --根据商品实付金额反算出商品单价
    --Set @v_RealPrc = Convert(Decimal(20, 2), @v_RealAmount / @v_Qty)
    --调减时 金额记录进批发退明细的商品销售成本,调增时成本记0
    Set @v_Cost = 0
    If @v_Direction = -1
      Set @v_Cost = @v_DtlTotal
    --插入一条明细
    if @v_Sale = 3
      Select @v_Inprc = @v_DtlTotal / @v_Qty * @v_Payrate / 100
    Select @v_Tax = Convert(Decimal(20, 2), @v_DtlTotal * @v_TaxRate / (100 + @v_TaxRate))
    Insert Into StkoutBckDtl(Cls, Num, Line, Settleno, Gdgid, Cases, Qty, Price,
      Wrh, Wsprc, Inprc, Rtlprc, Total, Tax, Cost) --, ItemNo) --增加itemno,防止代联销商品根据该条件查询原批发单时出错
    Values(@v_Cls, @v_NewNum, @v_Line, @v_SettleNo, @v_GdGid, @v_Qty / @v_Qpc, @v_Qty, @v_Price,
      @v_Wrh, @v_Wsprc, @v_Inprc, @v_RtlPrc, @v_DtlTotal, @v_Tax, @v_Cost)--, @v_ItemNo)
    --记录报表(出货日报和供应商账款日报)
    Exec @v_Ret = StkoutBckdtlChkCrt @v_Cls, @v_CurDate, @v_SettleNo, @v_CurDate, @v_SettleNo,
      @v_BilltoGid, 1, @v_Wrh, @v_GdGid, @v_Qty, @v_DtlTotal, @v_Tax, @v_Inprc, @v_RtlPrc, @v_Vdr, 1, 0, Null
    If @v_Ret <> 0
    Begin
      Set @po_Msg = '调用过程StkoutBckdtlChkCrt出错.'
      Close C_OOGwsb
      Deallocate C_OOGwsb
      Return 1
    End

    Fetch Next From C_OOGwsb into
      @v_GdCode, @v_Qty, @v_Price, @v_DtlTotal
  End
  Close C_OOGwsb
  Deallocate C_OOGwsb

  --更新已生成的单据汇总信息及回写中间表生成单据信息
  Declare
    @v_Reccnt int, @v_MTax Money, @v_MTotal Money
  select
    @v_Reccnt = Count(1),
    @v_MTax = IsNull(Sum(Tax), 0),
    @v_MTotal = Isnull(Sum(Total), 0)
  from StkoutBckDtl(nolock)
    Where Cls = @v_Cls and Num = @v_NewNum
  if @v_Reccnt = 0
  begin
    Delete From StkoutBckDtl Where Cls = @v_Cls and Num = @v_NewNum
    Delete From StkoutBck Where Cls = @v_Cls and Num = @v_NewNum
    Return 0
  end else
  begin
    --汇总只记录流程单号
    Select @v_Note = '调整供应商商品打折付款差额-流程单号:' + RTrim(@pi_BillNum)
    Update StkoutBck Set
      Reccnt = @v_Reccnt,
      Tax = @v_MTax,
      Total = @v_MTotal,
      Note = @v_Note
    Where Cls = @v_Cls and Num = @v_NewNum
    --不审核单据,只影响报表(出货日报和供应商账款日报)
    /*EXEC @v_Ret = STKOUTBCKCHK @v_Cls, @v_NewNum
    if @v_Ret <> 0
    begin
      --回写 中间表 汇总 处理备注
      Set @po_Msg = '审核生成的批发退货单失败:' + @v_NewNum
      UPDATE PS3_OuterOutMst
        SET OPERATIONNOTE = @po_Msg
      WHERE UUID = @v_UUID And OPERATIONSTAT = 1
      Return 1
    end*/
    --更新单据的审核人和预审核人
    Update StkoutBck Set
      PreChecker = @v_Filler,
      Checker = @v_Filler
    Where Num = @v_NewNum and Cls = @v_Cls
  end

  --记录到生成单据表
  insert into PS3_OuterGenBills(PLATFORM, BillNum, GenBillName, GenBillNum, UUID)
    Values(@pi_PlatForm, @pi_BillNum, '批发退货单', @v_NewNum, @v_UUID)
  if @@Error <> 0
  begin
    Set @po_Msg = '写入表PS3_OuterGenBills失败'
    Return 1
  end
  --回写 中间表汇总 处理状态(已生成批发退)
  UPDATE PS3_OuterOutMst
    SET OPERATIONSTAT = 2, OPERATIONNOTE = ''
  WHERE UUID = @v_UUID And OPERATIONSTAT = 1

  Return 0
End
GO
