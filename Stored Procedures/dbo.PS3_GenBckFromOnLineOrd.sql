SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_GenBckFromOnLineOrd]
(
  @pi_PlatForm Varchar(30) = 'UPOWER', --订单平台: 默认UPOWER,支持扩展
  @pi_OrdNo VarChar(50), --鼎力云退货单号
  @po_Msg varchar(255) output
)
as
begin
  declare
    @v_SettleNo int,
    @v_StoreCode Varchar(8),
    @v_StoreGid int,
    @v_DefGenBillEmpCode Varchar(10),
    @v_Filler int,
    @v_UUID VarChar(100),
    @v_NewNum VarChar(14),
    @v_Note VarChar(255),
    @v_SrcPlat Varchar(20),
    @v_OriNum Varchar(50), --退货的原鼎力云订单号
    @v_OriLocalNum Varchar(14), --退货的原本地线上销售订单号

    @v_Line int,
    @v_GdCode VarChar(40),
    @v_GdName Varchar(100),
    @v_Price Money,
    @v_Total Money,
    @v_RealAmount Money,
    @v_Qty Money,
    @v_GdGid int,
    @v_Score money,
    @v_Count int

  Select @v_UUID = UUID, @v_StoreCode = ShopNo, @v_SrcPlat = BillFrom,
    @v_OriNum = ORDID
  From PS3_OnlineReturnOrd(Nolock)
  Where PlatForm = @pi_PlatForm And OrdNo = @pi_OrdNo
    And OperationStat = 0
  --处理状态需是"未处理"才能生成销售订单
  IF @@RowCount = 0
  begin
    Set @po_Msg = '线上退换货单表中不存在指定的单据'
    Return 1
  end
  --检查已生成单据表
  select @v_Count = count(1)
    from PS3_OnLineOrdGenBills(nolock)
  where PlatForm = @pi_PlatForm and UUID = @v_UUID and GenBillName = '线上销售订货退货单'
  if @v_Count <> 0
  begin
    set @po_Msg = '表PS3_OnLineOrdGenBills已生成该订单的线上销售订货退货数据。'
    return 1
  end

  --生成线上销售退货单
  Set @v_StoreGid = -1
  Select @v_StoreGid = Gid From Store(Nolock)
    Where Code = @v_StoreCode
  if @v_StoreGid = -1
  begin
    Set @po_Msg = '线上订单的门店号在本地不存在'
    UPDATE PS3_OnlineReturnOrd
      SET OPERATIONNOTE = @po_Msg
    WHERE UUID = @v_UUID And OPERATIONSTAT = 0

    Return 1
  end

  Select @v_SettleNo = Max(No) from MONTHSETTLE
  --选项设定 生成单据的填单人代码
  Exec OptReadStr 14, 'PS3_DefGenBillEmpCode', '', @v_DefGenBillEmpCode output
  --取得用户GID
  Select @v_Filler = IsNull(Gid, 1) From Employee
    Where Code = @v_DefGenBillEmpCode
  IF @v_Filler is null
  begin
    Set @po_Msg = '选项[PS3_DefGenBillEmpCode]未正确配置。';
    Return 1
  end
  --抢占单号
  Exec GenNextBillNumex '', 'OnlineSaleBckOrd', @v_NewNum Output

  --写主表(会员及卡号从原订单取)
  Select @v_Note = '由' + @pi_PlatForm + '退换货单' + @pi_OrdNo + '生成'
  Insert Into OnlineSaleBckOrd(Num, Settleno, Fildate, Filler, StoreGid, MbrGid, Mbrcardno, Stat,
    Reccnt, Note, LstUpdTime, LstUpdOper, BillFrom, AMOUNT, OrdNum, SrcNum, ORIORDNUM, CltName, CltPhone,
    RtnName, RtnPhone, RtnAddress, DlverName, DlverPhone, OrdDate)
  Select @v_NewNum, @v_SettleNo, Getdate(), @v_Filler, @v_StoreGid, n.MbrGid, n.Mbrcardno, 3100, /*待退货状态*/
    0, @v_Note, Getdate(), @v_Filler, m.BillFrom, m.AMOUNT, @pi_OrdNo, m.SrcOrdNo, @v_OriNum, m.CstName, m.CstPhone,
    m.RtnctName, m.RtnctPhone, m.RtnctAddress, m.DlvMan, m.DlvPhone, m.CreateDate
  From PS3_OnlineReturnOrd m(nolock), OnlineSaleOrd n(nolock)
    Where m.UUID = @v_UUID and m.ORDID = n.OrdNum

  Select @v_OriLocalNum = Num From OnlineSaleOrd
    Where OrdNum = @v_OriNum
  --写付款方式明细表(由于暂只有整单退,因此鼎力云退货数据中未返回,取原订单的付款方式)
  insert into OnlineSaleBckOrdCurrency(Num, Line, Currency, Amount, Note)
  Select @v_NewNum, Line, Currency, Amount, Note
    From OnlineSaleOrdCurrency
  where Num = @v_OriLocalNum

  If (@v_SrcPlat = '微店汇')
    And Exists (Select 1 From PS3_OnLineReturnOrdGoods a(Nolock), PS3_OnLineReturnOrd b(Nolock)
      Where a.Uuid = b.Uuid And a.Uuid = @v_UUID
        And Not Exists (Select 1 From Goodsh c(Nolock) Where a.Gdcode = c.Gid))
  begin
    Set @po_Msg = @v_SrcPlat + '平台商品资料在门店库不存在'
    Return 1
  end

  Set @v_Line = 0
  if exists(select * from master..syscursors where cursor_name = 'C_OlbOrd')
    Deallocate C_OlbOrd
  --读取线上订单缓存表
  Declare C_OlbOrd Cursor For
    Select GdCode, GdName, Qty, Price, Total, RefundAmount
      From PS3_OnLineReturnOrdGoods
    Where UUID = @v_UUID
  Open C_OlbOrd
  Fetch Next From C_OlbOrd into
    @v_GdCode, @v_GdName, @v_Qty, @v_Price, @v_Total, @v_RealAmount
  While @@Fetch_Status = 0
  Begin
    select @v_Line = @v_Line + 1
    --微店汇传过来数据中记录的GdCode是商品内码
    if @v_SrcPlat = '微店汇'
    begin
      Set @v_GdGid = @v_GdCode
      Select @v_GdCode = RTrim(Code) From Goodsh(Nolock) Where Gid = @v_GdGid
    end else
      Select @v_GdGid = Gid From GdInput Where Code = @v_GdCode

    Select @v_Score = Score From OnlineSaleOrdDtl
      Where Num = @v_OriLocalNum and GdGid = @v_GdGid

    --插入一条明细
    Insert Into OnlineSaleBckOrdDtl(NUM, LINE, GDGID, GdCode, GdName, QTY, Price, RealAmount,
      Total, Score)
    Values(@v_NewNum, @v_Line, @v_GdGid, @v_GdCode, @v_GdName, @v_Qty, @v_Price, @v_RealAmount,
      @v_Total, @v_Score)

    Fetch Next From C_OlbOrd into
      @v_GdCode, @v_GdName, @v_Qty, @v_Price, @v_Total, @v_RealAmount
  End
  Close C_OlbOrd
  Deallocate C_OlbOrd

  --更新已生成的单据汇总信息及回写线上订单生成单据信息
  Declare
    @v_Reccnt int
  select
    @v_Reccnt = Count(1)
  from OnlineSaleBckOrdDtl(nolock)
    Where Num = @v_NewNum
  if @v_Reccnt = 0
  begin
    Delete From OnlineSaleBckOrdDtl Where Num = @v_NewNum
    Delete From OnlineSaleBckOrd Where Num = @v_NewNum
    Return 0
  end else
  begin
    Update OnlineSaleBckOrd
      Set Reccnt = @v_Reccnt
    Where Num = @v_NewNum
  end

  --记录到生成单据表
  insert into PS3_OnLineOrdGenBills(PLATFORM, OrdNO, GenBillName, GenBillNum, UUID)
    Values(@pi_PlatForm, @pi_OrdNo, '线上销售订货退货单', @v_NewNum, @v_UUID)
  --回写 线上订单汇总 处理状态(已退货)
  UPDATE PS3_OnLineReturnOrd
    SET OPERATIONSTAT = 1, OPERATIONNOTE = ''
  WHERE UUID = @v_UUID And OPERATIONSTAT = 0

  Return 0
end
GO
