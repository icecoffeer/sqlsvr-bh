SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPSALETASK_MODIFYTO100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vRet int,
    @Stat int

  select @Stat = STAT from EMPSALETASK(nolock) where NUM = @Num;
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  update EMPSALETASK
  set STAT = @ToStat, CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num

  exec EMPSALETASK_ADD_LOG @Num, @ToStat, '审核', @Oper;
  return(0)
end
GO
