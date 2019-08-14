SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDSALE_ON_ADDNEW] (
  @piNum char(14),                     --单号
  @piOperGid int,                      --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int
  declare @vOper varchar(50)

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  update CRMCARDSALE set 
    STAT = 0, 
    MODIFIER = @vOper, 
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_CARDSALE_ADD_LOG @piNum, null, 0, @piOperGid
  return(0)
end
GO
