SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_STAT_TO_110] (
  @piNum varchar(14),                    --单号
  @piOper varchar(40),                   --操作人
  @poErrMsg varchar(255) output          --出错信息
) as
begin
  /*declare
    @vOper varchar(80)

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid*/

  delete from CRMMBRPROMSUBJINVDTL where RULEUUID in(select uuid from CRMMBRPROMSUBJINV where srcnum = @piNum)
  delete from CRMMBRPROMSUBJINV where srcnum = @piNum

  update CRMMBRPROMTYPEBILL set Stat = 110, Modifier = @piOper, LstUpdTime = getdate()
    where Num = @piNum
  exec PCRM_MBRPROMTYPE_ADD_LOG @piNum, 100, 110, @piOper

  return(0)
end
GO
