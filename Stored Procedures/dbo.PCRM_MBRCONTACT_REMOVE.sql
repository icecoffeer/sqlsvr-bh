SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MBRCONTACT_REMOVE]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from CRMMBRCONTACT where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '会员沟通记录 ' + @piNum + ' 不是未审核状态，不允许删除.'
    return(1)
  end

  delete from CRMMBRCONTACT where NUM = @piNum

  return(0)
end
GO
