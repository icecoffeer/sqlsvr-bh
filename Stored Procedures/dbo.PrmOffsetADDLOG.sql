SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrmOffsetADDLOG]
(
  @Num varchar(14),
  @Stat int,
  @ToStat int,
  @Oper varchar(30)
) as
begin
  declare
    @vAct varchar(100),
    @vPrmSeq int
  select @vAct = ActName from ModuleStat(nolock) where No = @ToStat
  select @vPrmSeq = 0
  select @vPrmSeq = PRMSEQ from PRMDIRPRMOFFSET where PRMOFFSETNO = @Num
  if @vPrmSeq <> 0
  begin
    select @vAct = @vAct + '促销补差单' + '(' + @num + ')'
    exec PrmDir_ADD_LOG @vPrmSeq, @vAct, null, @Oper
  end
  waitfor delay '000:00:01'
  insert into PRMOFFSETLOG(Num, Cls, Stat, Modifier, Action, Time)
    values(@Num, '', @ToStat, @Oper, @vAct, Getdate())
end
GO
