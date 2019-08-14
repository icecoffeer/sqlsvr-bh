SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_GenSaleOrdFromOnLineOrd]
(
  @pi_PlatForm VarChar(80),
  @pi_OrdNo VarChar(50),
  @pi_Direction int, --0:生成订货单; 1:修改订货单状态为已取消
  @po_Msg varchar(255) output
)
As
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
    @v_OperationStat int,
    @v_SrcPlat Varchar(20),

    @v_OriNum Varchar(14), --要取消集货的POS销售订单号
    @v_OriStat int, --要取消集货的POS销售订单号的状态

    @v_Line int,
    @v_GdCode VarChar(40),
    @v_Price Money,
    @v_Total Money,
    @v_RealPrc Money,
    @v_RealAmount Money,
    @v_Qty Money,
    @v_GdGid int,
    @v_Score money,
    @v_Ret Int

  Select @v_UUID = UUID, @v_StoreCode = ShopNo,
    @v_OperationStat = OPERATIONSTAT, @v_SrcPlat = BillFrom
  From PS3_OnLineOrd(Nolock)
    Where PLATFORM = @pi_PlatForm And ORDNO = @pi_OrdNo
  --处理状态需是"已集货"才能生成销售订单
  IF (@@RowCount = 0) or ( (@pi_Direction = 0) and (@v_OperationStat <> 1) )
  begin
    Set @po_Msg = '线上订单表中不存在指定的订单'
    Return 1
  end
  --取消集货
  if @pi_Direction = 1
  begin
    --如果处理状态是"未处理",说明集货取消指令先于集货到达POS3;
    --此时直接将线上订单操作状态修改为集货取消,不生成线上销售订货单;
    --如果后续对应的集货指令进来,同样不会做任何处理
    If @v_OperationStat = 0
    begin
      --回写 线上订单汇总 处理状态
      UPDATE PS3_OnLineOrd
        SET OPERATIONSTAT = 2, OPERATIONNOTE = ''
      WHERE UUID = @v_UUID
      Return 0
    end else if @v_OperationStat <> 1
    begin
      Set @po_Msg = '无法进行集货取消的操作状态:' + Str(@v_OperationStat)
      Return 1
    end
    Select @v_OriStat = -1
    Select @v_OriStat = Stat, @v_OriNum = Num From OnlineSaleOrd
      Where Num = (Select GenBillNum From PS3_OnLineOrdGenBills Where GenBillName = '线上销售订货单'
        and UUID = @v_UUID)
    if (@v_OriStat <> 3700) and (@v_OriStat <> -1)
    begin
      Set @po_Msg = '集货生成的线上销售订货单已不是"待取货"状态,无法取消集货'
      UPDATE PS3_OnLineOrd
        SET OPERATIONNOTE = @po_Msg
      WHERE UUID = @v_UUID

      Return 1
    end
    --修改集货时生成的线上销售订货单状态为 已取消
    Update OnlineSaleOrd Set Stat = 2010
      Where Num = @v_OriNum
    --回写 线上订单汇总 处理状态
    UPDATE PS3_OnLineOrd
      SET OPERATIONSTAT = 2, OPERATIONNOTE = ''
    WHERE UUID = @v_UUID
    Return 0
  end else
  --生成订货单
  if @pi_Direction = 0
  begin
    Set @v_StoreGid = -1
    Select @v_StoreGid = Gid From Store(Nolock)
      Where Code = @v_StoreCode
    if @v_StoreGid = -1
    begin
      Set @po_Msg = '线上订单的门店号在本地不存在'
      UPDATE PS3_OnLineOrd
        SET OPERATIONNOTE = @po_Msg
      WHERE UUID = @v_UUID And OPERATIONSTAT = 0

      Return 1
    end
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
  Exec GenNextBillNumex '', 'OnlineSaleOrd', @v_NewNum Output

  --写主表
  Select @v_Note = '由' + @pi_PlatForm + '订单' + @pi_OrdNo + '集货生成'
  Insert Into OnlineSaleOrd(Num, Settleno, Fildate, Filler, StoreGid, MbrGid, MbrCardNo, Stat,
    Reccnt, Note, LstUpdTime, LstUpdOper, BillFrom, DlvMode, OrdNum, SrcNum, CltName, CltPhone,
    RcvName, RcvPhone, RcvAddress, DlverName, DlverPhone, OrdDate)
  Select @v_NewNum, @v_SettleNo, Getdate(), @v_Filler, @v_StoreGid, MbrGid, MbrCardNo, 3700,
    0, @v_Note, Getdate(), @v_Filler, BillFrom, DlvType, @pi_OrdNo, SrcOrdNo, CstName, CstPhone,
    RcvctName, RcvctPhone, RcvCtAddress, DlvMan, DlvPhone, CreateDate
  From PS3_OnLineOrd(nolock)
    Where UUID = @v_UUID

  --写付款方式明细表(根据对照表转换为本地付款方式)
  if not exists (Select 1 From PayChannlDtl Where SrcPlat = @v_SrcPlat)
  begin
    Set @po_Msg = @v_SrcPlat + '平台对应的付款方式映射关系未配置'
    Return 1
  end
  if exists( Select 1 from PS3_OnLineOrdPayment d, PayChannlDtl m
    where d.UUID = @v_UUID and m.SrcPlat = @v_SrcPlat and m.CName='微电汇' ---微电汇过来的付款方式统计用微电汇 by jzhu
      and m.PayCode not in (Select Code From Currency(nolock)) )
  begin
    Set @po_Msg = @v_SrcPlat + '平台对应的付款方式映射关系未正确配置'
    Return 1
  end
  if exists (select 1 from PS3_OnLineOrdPayment(nolock) where uuid=@v_UUID)
    insert into OnlineSaleOrdCurrency(Num, Line, Currency, Amount)
    Select @v_NewNum, Itemno, m.PayCode, PayAmount
      From PS3_OnLineOrdPayment d, PayChannlDtl m
    where d.UUID = @v_UUID  and m.SrcPlat = @v_SrcPlat and m.CName = '微电汇' ---微电汇过来的付款方式统计用微电汇 by jzhu
  else
    insert into OnlineSaleOrdCurrency(Num, Line, Currency, Amount)
    select @v_NewNum, 1, '57', realamount
      from PS3_OnLineOrd(nolock) where uuid=@v_UUID

  if (@v_SrcPlat = '微店汇')
    And Exists (Select 1 From PS3_OnLineOrdGoods a, PS3_OnLineOrd b
      Where a.UUID = @v_UUID and a.Uuid = b.Uuid
        And Not Exists (select 1 from goodsh b(nolock) where a.GdCode=b.gid) )
  begin
    Set @po_Msg = @v_SrcPlat + '平台商品资料在门店库不存在'
    Return 1
  end

  Set @v_Line = 0
  if exists(select * from master..syscursors where cursor_name = 'C_OlOrd')
    Deallocate C_OlOrd
  --读取线上订单缓存表
  Declare C_OlOrd Cursor For
    Select GdCode, Qty, Price, Total, SinglePrice, RealAmount, Score
      From PS3_OnLineOrdGoods
    Where UUID = @v_UUID
  Open C_OlOrd
  Fetch Next From C_OlOrd into
    @v_GdCode, @v_Qty, @v_Price, @v_Total, @v_RealPrc, @v_RealAmount, @v_Score
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

    --插入一条明细
    Insert Into OnlineSaleOrdDtl(NUM, LINE, GDGID, GdCode, QTY, RealPrc, RealAmount,
      Price, Total, Score)
    Values(@v_NewNum, @v_Line, @v_GdGid, @v_GdCode, @v_Qty, @v_RealPrc, @v_RealAmount,
      @v_Price, @v_Total, @v_Score)

    Fetch Next From C_OlOrd into
      @v_GdCode, @v_Qty, @v_Price, @v_Total, @v_RealPrc, @v_RealAmount, @v_Score
  End
  Close C_OlOrd
  Deallocate C_OlOrd

  --更新已生成的单据汇总信息及回写线上订单生成单据信息
  Declare
    @v_Reccnt int
  select
    @v_Reccnt = Count(1)
  from OnlineSaleOrdDtl(nolock)
    Where Num = @v_NewNum
  if @v_Reccnt = 0
  begin
    Delete From OnlineSaleOrdDtl Where Num = @v_NewNum
    Delete From OnlineSaleOrd Where Num = @v_NewNum
    Return 0
  end else
  begin
    Update OnlineSaleOrd
      Set Reccnt = @v_Reccnt
    Where Num = @v_NewNum
  end

  --记录到生成单据表
  insert into PS3_OnLineOrdGenBills(PLATFORM, OrdNO, GenBillName, GenBillNum, UUID)
    Values(@pi_PlatForm, @pi_OrdNo, '线上销售订货单', @v_NewNum, @v_UUID)
  --回写 线上订单汇总 处理状态 SET OPERATIONSTAT = 1 改为=2  by jzhu
  UPDATE PS3_OnLineOrd
    SET OPERATIONSTAT = 2, OPERATIONNOTE = ''
  WHERE UUID = @v_UUID And OPERATIONSTAT = 1

  Return 0
end
GO
