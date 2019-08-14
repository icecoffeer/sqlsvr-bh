SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTRANSFER_ON_ADDNEW] (
  @piNum varchar(14),                   --单号
  @piOper varchar(80),                  --操作人
  @poErrMsg varchar(255) output         --出错信息
) as
begin
  update ProcTransfer set
    STAT = 0,
    MODIFIER = @piOper,
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PROCTRANSFER_ADD_LOG @piNum, null, 0, @piOper
  return(0)
end
GO
