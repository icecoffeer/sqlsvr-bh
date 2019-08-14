SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_ON_ADDNEW] (
  @piNum varchar(14),                     --单号
  @piOperGid int,                         --操作人
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare
    @vRet int,
    @vOper varchar(80)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  update CRMMBRPROMTYPEBILL set STAT = 0, MODIFIER = @vOper, LSTUPDTIME = getdate() where NUM = @piNum
  exec PCRM_MBRPROMTYPE_ADD_LOG @piNum, null, 0, @vOper
  return(0)
end
GO
