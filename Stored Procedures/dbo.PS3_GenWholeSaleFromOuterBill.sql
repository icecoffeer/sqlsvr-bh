SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_GenWholeSaleFromOuterBill]
(
  @pi_PlatForm VarChar(80), --来源平台: Intra
  @pi_BillNum VarChar(50), --来源单号
  @po_Msg varchar(255) output --错误信息
)
As
Begin
  Declare
    @v_UserGid int,
    @v_NewNum VarChar(10),
    @v_SettleNo int,
    @v_Filler int,
    @v_Line int,
    @v_Wrh int,
    @v_UUID VarChar(100),
    @v_Total Money, --外部单据含税金额=明细的含税金额之和
    @v_EmpCode Varchar(20), --填单人
    @v_CltCode Varchar(20), --客户代码
    @v_BilltoCode Varchar(20), --结算单位代码
    @v_CltGid int,
    @v_BilltoGid int,
    @v_Note VarChar(255),
    @v_GdCode VarChar(40),
    @v_Qty Money, --外部单据商品数量
    @v_DtlTotal Money, --外部单据商品含税金额
    @v_RealPrc Money, --商品价格(含税金额/数量 反算)
    @v_InvQty Money, --商品POS库存可用数量
    @v_GdGid int,
    @v_Ret Int,
    @v_Cls Varchar(10),
    @v_Count int,
    @v_Direction int, /*1:调增 -1:调减*/
    @v_CurDate Datetime

  Select @v_SettleNo = Max(No) from MONTHSETTLE
  Select @v_UserGid = UserGid, @v_Wrh = DFTWRH
    From System(Nolock)
  Set @v_Cls = '批发'
  Select @v_CurDate = Convert(Datetime, Convert(Char, Getdate(), 102))

  Select @v_UUID = UUID, @v_Total = Amount, @v_EmpCode = '-',
    @v_CltCode = '-', @v_BilltoCode = '-', @v_Direction = Direction
  From PS3_OuterOutMst(Nolock)
    Where PLATFORM = @pi_PlatForm and BILLNUM = @pi_BillNum
  IF @@RowCount = 0
  begin
    Set @po_Msg = '外部生成出货单据表中不存在指定的数据'
    Return 1
  end
  --检查已生成单据表
  select @v_Count = count(1)
    from PS3_OuterGenBills(nolock)
  where PlatForm = @pi_PlatForm and UUID = @v_UUID and GenBillName = '批发单'
  if @v_Count <> 0
  begin
    set @po_Msg = '表PS3_OuterGenBills已生成该外部单据的批发单。'
    return 1
  end

  --从外部生成出货单据中获取 填单人,客户和结算单位
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

  --抢占单号
  Select @v_NewNum = Isnull(Max(Num), '0000000001')
    From Stkout(Nolock) Where Cls = @v_Cls
  Exec NEXTBN @v_NewNum, @v_NewNum Output

  --写主表
  Insert Into Stkout (Cls, Num, Settleno, Wrh, Client, Billto, Ocrdate, Total, Tax,
    Fildate, Filler, Stat, Reccnt, Src)
  Values(@v_Cls, @v_NewNum, @v_SettleNo, @v_Wrh, @v_CltGid, @v_BilltoGid, Getdate(), 0, 0,
    Getdate(), @v_Filler, 0, 0, @v_UserGid)

  Set @v_Line = 0
  --读取缓存表
  Declare C_OOGws Cursor Local For
    Select d.GdCode, d.Price, d.Qty, d.Amount
    From PS3_OuterOutGoods d
      Where UUID = @v_UUID
  Open C_OOGws
  Fetch Next From C_OOGws into @v_GdCode, @v_RealPrc, @v_Qty, @v_DtlTotal
  While @@fetch_status = 0
  Begin
    Select @v_Line = @v_Line + 1
    Select @v_GdGid = Gid From GdInput Where Code = @v_GdCode
    --取到商品库存数
    /*Select @v_InvQty = Isnull(AvlQty, 0)
      from V_AlcInv(nolock)
    Where Gdgid = @v_GdGid and Wrh = @v_Wrh and Store = @v_UserGid
    if @v_InvQty is null*/
      Set @v_InvQty = 0
    Declare
      @v_TaxRate Money, @v_WsPrc Money, @v_Inprc Money,
      @v_RtlPrc Money, @v_Qpc Money, @v_Cost Money, @v_Tax Money,
      @v_Sale int, @v_Payrate money, @v_Vdr int
    Select
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
    --Set @v_RealPrc = Convert(Decimal(20, 2), @v_Total / @v_Qty)
    --调增时 金额记录进批发明细的商品销售成本,调减时成本记0
    Set @v_Cost = 0
    If @v_Direction = 1
      Set @v_Cost = @v_DtlTotal
    --插入一条明细
    if @v_Sale = 3
      Select @v_Inprc = @v_DtlTotal / @v_Qty * @v_Payrate / 100
    Select @v_Tax = Convert(Decimal(20, 2), @v_DtlTotal * @v_TaxRate / (100 + @v_TaxRate))
    Insert Into StkoutDtl(Cls, Num, Line, Settleno, Gdgid, Cases, Qty, Price,
      Wsprc, Inprc, Rtlprc, Total, Tax, Wrh, Invqty, Cost)
    Values(@v_Cls, @v_NewNum, @v_Line, @v_SettleNo, @v_GdGid, @v_Qty / @v_Qpc, @v_Qty, @v_RealPrc,
      @v_Wsprc, @v_Inprc, @v_RtlPrc, @v_DtlTotal, @v_Tax, @v_Wrh, @v_InvQty, @v_Cost)
    --记录报表(出货日报和供应商账款日报)
    Exec @v_Ret = StkoutdtlChkCrt @v_Cls, @v_CurDate, @v_SettleNo, @v_CurDate, @v_SettleNo,
      @v_CltGid, 1, @v_Wrh, @v_GdGid, @v_Qty, @v_DtlTotal, @v_Tax, @v_Inprc, @v_RtlPrc, @v_Vdr,
      Null, 1, 0
    If @v_Ret <> 0
    Begin
      Set @po_Msg = '调用过程STKOUTDTLCHKCRT出错.'
      Close C_OOGws
      Deallocate C_OOGws
      Return 1
    End

    Fetch Next From C_OOGws into @v_GdCode, @v_RealPrc, @v_Qty, @v_DtlTotal
  End
  Close C_OOGws
  Deallocate C_OOGws

  --更新已生成的批发单汇总信息及回写中间表及生成单据信息
  Declare
    @v_MTotal Money, @v_MTax Money, @v_Reccnt int
  select
    @v_MTotal = Isnull(Sum(Total), 0),
    @v_MTax = Isnull(Sum(Tax), 0),
    @v_Reccnt = Count(1)
  from Stkoutdtl(nolock)
    Where Num = @v_NewNum and Cls = @v_Cls
  if @v_Reccnt = 0
  begin
    Delete From Stkoutdtl Where Num = @v_NewNum And Cls = @v_Cls
    Delete From Stkout Where Num = @v_NewNum And Cls = @v_Cls
    Return 0
  end else
  begin
    --汇总备注只记录流程号
    Select @v_Note = '调整供应商商品打折付款差额-流程单号:' + RTrim(@pi_BillNum)
    Update Stkout Set
      Total = @v_MTotal,
      Tax = @v_MTax,
      Reccnt = @v_Reccnt,
      Note = @v_Note,
      /* 更新已记录帐款标志 */
      LogAcnt = 1
    Where Num = @v_NewNum and Cls = @v_Cls
    --不审核单据,只影响报表(出货日报和供应商账款日报),记录明细时更改
    /*Exec @v_Ret = STKOUTCHK @v_Cls, @v_NewNum
    if @v_Ret <> 0
    begin
      --回写 外部生成出货单据汇总的 处理备注
      Set @po_Msg = '审核生成的批发单失败:' + @v_NewNum
      UPDATE PS3_OuterOutMst
        SET OPERATIONNOTE = @po_Msg
      WHERE UUID = @v_UUID And OPERATIONSTAT = 0
      Return 1
    end*/
    --更新单据的审核人和预审核人
    Update Stkout Set
      PreChecker = @v_Filler,
      Checker = @v_Filler
    Where Num = @v_NewNum and Cls = @v_Cls
  end
  --记录到生成单据表
  insert into PS3_OuterGenBills(PlatForm, BillNum, GenbillName, GenbillNum, UUID)
    Values(@pi_PlatForm, @pi_BillNum, '批发单', @v_NewNum, @v_UUID)
  if @@Error <> 0
  begin
    Set @po_Msg = '写入表PS3_OuterGenBills失败。'
    Return 1
  end

  --回写 中间表汇总 生成单据信息
  UPDATE PS3_OuterOutMst
    SET OPERATIONSTAT = 1, OPERATIONNOTE = ''
  WHERE UUID = @v_UUID

  Return 0
End
GO
