SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @ToStat int,
  @Oper varchar(30)
) as
begin
  declare
    @vAct varchar(20)
  select @vAct = ActName from ModuleStat(nolock) where No = @ToStat

  waitfor delay '000:00:01'
  insert into ProcTaskLog(Num, Cls, Stat, Modifier, Act, Time)
    values(@Num, '', @Stat, @Oper, @vAct, Getdate())
end
GO
