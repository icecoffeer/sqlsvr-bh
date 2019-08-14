SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MODIFYCARD_REMOVE] (
  @piNum char(14),                     --单号
  @piOper varchar(70),                 --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vStat int

  select @vStat = STAT from CRMMODIFYCARD(nolock) where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '卡修正单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end
  
  delete from CRMMODIFYCARD where NUM = @piNum
  delete from CRMMODIFYCARDDTL where NUM = @piNum
  delete from CRMMODIFYCARDLOG where NUM = @piNum
  return(0)
end
GO
