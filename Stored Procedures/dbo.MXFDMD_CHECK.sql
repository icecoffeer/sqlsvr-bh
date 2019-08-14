SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFDMD_CHECK]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
 declare @vRet int

  if @ToStat = 401
  begin
    exec @vRet = MXFDMD_CHKTO401 @Num, @Oper,  401, @Msg output
    return(@vRet)
  end
  else if @ToStat = 400
  begin
    exec @vRet = MXFDMD_CHKTO400 @Num, @Oper,  400, @Msg output
    return(@vRet)
  end
  else if @ToStat = 402
  begin
    exec @vRet = MXFDMD_CHKTO402 @Num, @Oper,  402, @Msg output
    return(@vRet)
  end
  else if @ToStat = 411
  begin
    exec @vRet = MXFDMD_CHKTO411 @Num, @Oper,  411, @Msg output
    return(@vRet)
  end
  else if @ToStat = 300
  begin
    exec @vRet = MXFDMD_CHKTO300 @Num, @Oper,  300, @Msg output
    return(@vRet)
  end
  else
  begin
     Set @Msg = '未知状态！'
     return(1)
  end
  return(0)
end
GO
