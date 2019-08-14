SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_ScheduleOnLineOrder]
(
  @pi_PlatForm Varchar(30) = 'UPOWER', --平台: UPOWER,支持扩展
  @pi_Operation Varchar(30), --操作:集货,取消集货,销售,销售退货
  @po_Msg varchar(255) output
)
as
begin
  Declare
    @v_ID VarChar(60),
    @v_Topic VarChar(150),
    @v_Operation VarChar(100),
    @v_OrdNo VarChar(50),
    @v_Ret Int,
    @vOptSaleFromOrd int,
    @vOptReturnFromOrd int,
    @v_Sql Varchar(4000)

  Exec OptReadStr 0, 'PS3_SaleFromOnLineOrd', 0, @vOptSaleFromOrd output
  --支持退货逻辑
  Exec OptReadStr 0, 'PS3_ReturnFromOnLineOrd', 0, @vOptReturnFromOrd output

  Set @v_Ret = 0
  Set @po_Msg = ''
  --根据操作设置查询条件
  Set @v_Topic = ''
  Set @v_Operation = ''
  If @pi_Operation = '集货'
  begin
    Set @v_Topic = 'store.order.operation'
    Set @v_Operation = 'shipping'
  end else If @pi_Operation = '取消集货'
  begin
    Set @v_Topic = 'store.order.operation'
    Set @v_Operation = 'cancelShipping'
  end else If @pi_Operation = '销售'
    Set @v_Topic = 'store.order.shipped'
  else If @pi_Operation = '销售退货'
    Set @v_Topic = 'store.return.received'

  if exists(select * from master..syscursors where cursor_name = 'C_UPowerNtf')
    Deallocate C_UPowerNtf
  --读取线上定单缓存表
  Set @v_Sql = ' Declare C_UPowerNtf Cursor For
    Select ID, Businesskey
      From PSUPOWERNOTIFICATION
    Where Stat = 1 '--POS3服务已处理了该通知(已获取订单信息)
  if @v_Topic <> ''
    Set @v_Sql = @v_Sql + ' And TOPIC = ''' + @v_Topic + ''''
  if @v_Operation <> ''
    Set @v_Sql = @v_Sql + ' And Operation = ''' + @v_Operation + ''''
  Set @v_Sql = @v_Sql + ' Order By TOPIC'
  Exec (@v_Sql)

  Open C_UPowerNtf
  Fetch Next From C_UPowerNtf into @v_ID, @v_OrdNo
  While @@Fetch_Status = 0
  Begin
    If @pi_Operation = '集货'
    begin
      Exec @v_Ret = PS3_CollectFromOnLineOrd @pi_PlatForm, @v_OrdNo, 0, @po_Msg Output
      if @v_Ret = 0
      begin
        Update PSUPOWERNOTIFICATION Set Stat = 2
          Where ID = @v_ID and (Topic = @v_Topic) and (OPERATION = @v_Operation)
        Set @po_Msg = '集货成功'
      end else
        Set @po_Msg = '集货失败:' + @po_Msg
    end else if @pi_Operation = '取消集货'
    begin
      Exec @v_Ret = PS3_CollectFromOnLineOrd @pi_PlatForm, @v_OrdNo, 1, @po_Msg Output
      if @v_Ret = 0
      begin
        Update PSUPOWERNOTIFICATION Set Stat = 2
          Where ID = @v_ID and (Topic = @v_Topic) and (OPERATION = @v_Operation)
        Set @po_Msg = '取消集货成功'
      end  else
        Set @po_Msg = '取消集货失败:' + @po_Msg
    end else if @pi_Operation = '销售'
    begin
      if @vOptSaleFromOrd = 0
      --未支持销售指令
      begin
        Fetch Next From C_UPowerNtf into @v_ID, @v_OrdNo
        Continue
      end
      Exec @v_Ret = PS3_GenWholeSaleFromOnLineOrd @pi_PlatForm, @v_OrdNo, @po_Msg Output
      if @v_Ret = 0
      begin
        Update PSUPOWERNOTIFICATION Set Stat = 2
          Where ID = @v_ID and (Topic = @v_Topic)
        Set @po_Msg = '销售成功'
      end  else
        Set @po_Msg = '销售失败:' + @po_Msg
    end else if @pi_Operation = '销售退货'
    begin
      if @vOptReturnFromOrd = 0
        --未支持退货指令
      begin
        Fetch Next From C_UPowerNtf into @v_ID, @v_OrdNo
        Continue
      end
      Exec @v_Ret = PS3_GenBckFromOnLineOrd @pi_PlatForm, @v_OrdNo, @po_Msg Output
      if @v_Ret = 0
      begin
        Update PSUPOWERNOTIFICATION Set Stat = 2
          Where ID = @v_ID and (Topic = @v_Topic)
        Set @po_Msg = '处理退货指令成功'
      end  else
        Set @po_Msg = '处理退货指令失败:' + @po_Msg
    end
    --记录日志
    Exec PS3_UPowerNotifyWriteLog @v_ID, @po_Msg

    Fetch Next From C_UPowerNtf into @v_ID, @v_OrdNo
  End
  close C_UPowerNtf
  deallocate C_UPowerNtf

  Return @v_Ret
end
GO
