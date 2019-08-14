SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*2006.12.19 edited by zhanglong, 增加字段note*/
create procedure [dbo].[PROCEXEC_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @ToStat int,
  @Oper varchar(30),
  @Note VARCHAR(255)
) as
begin
  declare
    @vAct varchar(20)
  select @vAct = ActName from ModuleStat(nolock) where No = @ToStat
  waitfor delay '000:00:01'
  insert into ProcExecLog(Num, Cls, Stat, Modifier, Act, Time, Note)
    values(@Num, '', @Stat, @Oper, @vAct, Getdate(), @Note)
end
GO
