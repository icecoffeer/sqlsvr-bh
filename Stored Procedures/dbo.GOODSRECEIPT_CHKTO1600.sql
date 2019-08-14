SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_CHKTO1600]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Stat int
  select @Stat = STAT from GOODSRECEIPT(nolock) where NUM = @Num
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行预审操作.'
    return(1)
  end

  update GOODSRECEIPT
    set STAT = 1600, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
    where NUM = @num
  exec GOODSRECEIPT_ADD_LOG @Num, 1600, '预审', @Oper

  return(0)
end
GO
