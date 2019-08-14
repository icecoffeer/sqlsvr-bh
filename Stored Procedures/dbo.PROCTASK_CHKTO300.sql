SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_CHKTO300]
(
  @Num varchar(14),
  @Oper varchar(30),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vStat int

  select @vStat = Stat from ProcTask(nolock) where Num = @Num
  if @@RowCount = 0
  begin
    Set @Msg = '取加工任务单(' + @Num + ')失败！'
    return(1)
  end

  if @vStat = 300
  begin
    Set @Msg = '此单据已完成！'
    return(1)
  end

  if @vStat = 110
  begin
    Set @Msg = '此单据已被其他人作废！'
    return(1)
  end

  --更新单据信息
  if @vStat = 0
  begin
    exec PROCTASK_CHKTO100 @Num, @Oper, @Cls, 100, @Msg output
    update ProcTask set Stat = 300, Modifier = @Oper, LstUpdTime = Getdate() where Num = @Num
    exec PROCTASK_ADD_LOG @Num, 100, 300, @Oper
    return(0)
  end
  update ProcTask set Stat = 300, Modifier = @Oper, LstUpdTime = Getdate() where Num = @Num
  exec PROCTASK_ADD_LOG @Num, 100, 300, @Oper
  return(0)
end
GO
