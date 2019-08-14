SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREPRIZE_REMOVE]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from CRMSCOREPRIZE where NUM = @piNUM
  if @vStat not in (0, 1600)
  begin
    set @poErrMsg = '积分兑奖单 ' + @piNum + ' 不是未审核状态，不允许删除.'
    return(1)
  end

  delete from CRMSCOREPRIZE where NUM = @piNum
  delete from CRMSCOREPRIZECARDDTL where NUM = @piNum
  delete from CRMSCOREPRIZEPRZDTL where NUM = @piNum
  delete from CRMSCOREPRIZELOG where NUM = @piNum

  return(0)
end
GO
