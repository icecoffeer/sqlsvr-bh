SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_CHKTO300]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Stat int
  select @Stat = STAT from GOODSRECEIPT(nolock) where NUM = @Num
  if @Stat <> 100
  begin
    set @Msg = '不是未审核的单据，不能进行完成操作.'
    return(1)
  end

  update GOODSRECEIPT
    set STAT = 300,  CHKDATE = GETDATE(), LSTUPDTIME = getdate(), LSTUPDOPER = @oper
    where NUM = @num;

  update ORDDTL
  set INUSE = 0
  where exists
   (select 1 from GOODSRECEIPTdtl D(nolock), GOODSRECEIPT m(NOLOCK)
    where M.SRCORDNUM = ORDDTL.NUM
    and D.NUM = @num
    and M.NUM = @num
    and D.GDQTY = 0
    and d.line = orddtl.line
    )

  exec GOODSRECEIPT_ADD_LOG @Num, 300, '完成', @Oper;

  --删除RFEMPLOCKORD表中的相关数据
  delete RFEMPLOCKORD from GOODSRECEIPT
  where RFEMPLOCKORD.ORDNUM = GOODSRECEIPT.SRCORDNUM
    and GOODSRECEIPT.NUM = @Num
  return(0)
end
GO
