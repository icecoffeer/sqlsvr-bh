SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_CHKTO100]
(
  @Num varchar(14),
  @Oper varchar(30),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vStat int,
    @vSettleNo int

  select @vStat = Stat  from ProcTask(nolock) where Num = @Num
  if @@RowCount = 0
  begin
    Set @Msg = '取加工任务单(' + @Num + ')失败！'
    return(1)
  end

  if @vStat <> 0
  begin
    Set @Msg = '此单据不是未审核单据！'
    return(1)
  end

  --更新单据信息
  select @vSettleNo = Max(No) from MonthSettle(nolock)
	update ProcTask set Stat = 100, SettleNo = @vSettleNo, BgnTime = Getdate(), ChkTime = Getdate(), ChkEmp = @Oper, Modifier = @Oper, LstUpdTime = Getdate()
		, EndTime = GetDate() + Cycle  --2006.12.12 edited by zhanglong,审核时修改加工任务单结束为 审核时间＋加工周期
  where Num = @Num
  exec PROCTASK_ADD_LOG @Num, 0, 100, @Oper
  return(0)
end
GO
