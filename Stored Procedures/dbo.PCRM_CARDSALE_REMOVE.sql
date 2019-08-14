SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDSALE_REMOVE] (
  @piNum char(14),                     --单号
  @piOperGid int,                      --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vStat int

  select @vStat = STAT from CRMCARDSALE(nolock) where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '发售单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end
  
  delete from CRMCARDSALE where NUM = @piNum
  delete from CRMCARDSALEDTL where NUM = @piNum
  delete from CRMCARDSALELOG where NUM = @piNum
  return(0)
end
GO
