SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[TaxSortAdj_ADD_LOG]
(
  @Num varchar(14),
  @ToStat int,
  @Oper varchar(30)
) as
begin
  declare
    @vAct varchar(20)
  select @vAct = ActName from ModuleStat(nolock) where No = @ToStat
  waitfor delay '000:00:01'
  insert into TaxSortAdjLOG(Num, Stat, Modifier, Action, Time)
    values(@Num, @ToStat, @Oper, @vAct, Getdate())
end
GO
