SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERGIVEOUT_CHKTO100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Stat int

  select @Stat = STAT from VOUCHERGIVE(nolock) where NUM = @Num
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  update VOUCHERGIVE
    set STAT = 100, CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @Oper
    where NUM = @Num

  exec VOUCHERGIVEOUT_ADD_LOG @Num, 100, '审核', @Oper

  return(0)
end
GO
