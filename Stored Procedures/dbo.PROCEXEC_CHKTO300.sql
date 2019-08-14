SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_CHKTO300]
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

  select @vStat = Stat  from ProcExec(nolock) where Num = @Num
  if @@RowCount = 0
  begin
    Set @Msg = '取加工入库单(' + @Num + ')失败！'
    return(1)
  end

  if @vStat <> 100
  begin
    Set @Msg = '此单据不是审核单据, 不能完成！'
    return(1)
  end

  --更新单据信息
  update ProcExec set Stat = 300, Modifier = @Oper, LstUpdTime = Getdate()
  where Num = @Num
  exec PROCEXEC_ADD_LOG @Num, 100, 300, @Oper, ''
  return(0)
end
GO
