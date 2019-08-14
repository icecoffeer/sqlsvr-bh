SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_OrdStkin_GenGR](
  @piEmpGid int,                --传入参数：操作员GID。
  @piOrdNum char(10),           --传入参数：定货单号。
  @poGRNum char(14) output,     --传出参数（返回值为0时有效）：收货单号。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
) as
begin
  declare
    @SettleNo int,
    @Oper varchar(30)

  --获取收货单新单号。
  exec GenNextBillNumEx '', 'GOODSRECEIPT', @poGRNum output
  --获取期号。
  select @SettleNo = max(NO) from MONTHSETTLE(nolock)
  --获取操作员。
  exec Utils_OperFromGid @piEmpGid, @Oper output

  --新增收货单汇总。
  insert into GOODSRECEIPT(NUM, SETTLENO, STAT, RECEIVER, SRCORDNUM, FILLER, FILDATE, LSTUPDOPER, LSTUPDTIME)
    select @poGRNum, @SettleNo, 0/*未审核*/, @piEmpGid, @piOrdNum, @Oper, getdate(), @Oper, getdate()

  --新增收货单明细。
  insert into GOODSRECEIPTDTL(NUM, LINE, GDGID, GDQTY)
    select @poGRNum, LINE, GDGID, 0
    from ORDDTL(nolock)
    where NUM = @piOrdNum
    order by LINE

  --新增收货单日志。
  exec GOODSRECEIPT_ADD_LOG @poGRNum, 0/*未审核*/, null, @Oper

  return 0
end
GO
