SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_CHKTO110]
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

  select @vStat = Stat  from ProcTask(nolock) where Num = @Num
  if @@RowCount = 0
  begin
    Set @Msg = '取加工任务单(' + @Num + ')失败！'
    return(1)
  end

  if @vStat = 300
  begin
    Set @Msg = '此单据已完成，不能被作废！'
    return(1)
  end

  if @vStat = 110
  begin
    Set @Msg = '此单据已被其他人作废，不能保存！'
    return(1)
  end

  --更新单据信息
  update ProcTask set Stat = 110, Modifier = @Oper, LstUpdTime = Getdate() where Num = @Num
  exec PROCTASK_ADD_LOG @Num, @vStat, 110, @Oper
  return(0)
end
GO
