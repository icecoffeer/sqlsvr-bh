SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_CHECK]
(
  @Num varchar(14),
  @Oper varchar(30),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vRet int
  set @vRet = 1
  if @ToStat = 100
    exec @vRet = PROCTASK_CHKTO100 @Num, @Oper, @Cls, 100, @Msg output
  else if @ToStat = 110
    exec @vRet = PROCTASK_CHKTO110 @Num, @Oper, @Cls, 110, @Msg output
  else if @ToStat = 300
    exec @vRet = PROCTASK_CHKTO300 @Num, @Oper, @Cls, 300, @Msg output
  else
  begin
     Set @Msg = '未知状态！'
     return(1)
  end
  if @vRet = 1
  begin
    Set @Msg = '保存单据失败！'
    return(1)
  end
  return(0)
end
GO
