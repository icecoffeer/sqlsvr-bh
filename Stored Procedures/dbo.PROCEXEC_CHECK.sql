SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_CHECK]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vRet int,
    @OptAutoSend varchar(2)
  set @vRet = 1
  if @ToStat = 100
    begin --ShenMin
      exec @vRet = PROCEXEC_CHKTO100 @Num, @Oper, @Cls, 100, @Msg output;
      select @OptAutoSend = IsNull(optionvalue, '0')
       from hdoption
       where moduleno = 647 and optioncaption = 'AutoSend';
      if @OptAutoSend = '1'
        exec PROCEXEC_ON_SEND @piNum = @Num, @piOper = @Oper, @poErrMsg = @Msg output;
    end
  else if @ToStat = 110
    exec @vRet = PROCEXEC_CHKTO110 @Num, @Oper, @Cls, 110, @Msg output
  else if @ToStat = 834
    exec @vRet = PROCEXEC_CHKTO834 @Num, @Oper, @Cls, 834, @Msg output
  else if @ToStat = 300
    exec @vRet = PROCEXEC_CHKTO300 @Num, @Oper, @Cls, 300, @Msg output
  else
  begin
     Set @Msg = '未知状态！'
     return(1)
  end
  if @vRet <> 0
  begin
    return(1)
  end
  return(0)
end
GO
