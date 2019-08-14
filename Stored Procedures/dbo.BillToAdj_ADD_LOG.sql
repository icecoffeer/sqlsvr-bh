SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BillToAdj_ADD_LOG]
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
  insert into BILLTOADJLOG(Num, Stat, Modifier, Time, Action, Note)
    values(@Num, @ToStat, @Oper, Getdate(), @vAct, @vAct + '商品缺省供应商调整单')
end
GO
