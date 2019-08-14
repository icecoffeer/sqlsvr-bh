SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MBRCONTACT_ON_MODIFY]
(
  @piNum varchar(14),
  @piToStat int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from CRMMBRCONTACT where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '会员沟通记录不存在'
    return(1)
  end
  if @piToStat = 100
  begin
    if @vStat not in (0, 100)
    begin
      set @poErrMsg = '不是未审核单据，不能审核'
      return(1)
    end
  end else if @piToStat = 110
  begin
    if @vStat <> 100
    begin
      set @poErrMsg = '不是已审核单据，不能作废'
      return(1)
    end
  end

  --状态调度
  if (@piToStat = 100) and (@vStat = 0)
  begin
    exec @vRet = PCRM_MBRCONTACT_STAT_TO_100 @piNum, @piOperGid, @poErrMsg output
    return(@vRet)
  end
  if (@piToStat = 110) and (@vStat = 100)
  begin
    exec @vRet = PCRM_MBRCONTACT_STAT_TO_110 @piNum, @piOperGid, @poErrMsg output
    return(@vRet)
  end

  return(0)
end
GO
