SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MODIFYCARD_ON_ADDNEW] (
  @piNum char(14),                     --单号
  @piOper varchar(70),                 --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int

  update CRMMODIFYCARD set 
    STAT = 0, 
    MODIFIER = @piOper, 
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_MODIFYCARD_ADD_LOG @piNum, null, 0, @piOper
  return(0)
end
GO
