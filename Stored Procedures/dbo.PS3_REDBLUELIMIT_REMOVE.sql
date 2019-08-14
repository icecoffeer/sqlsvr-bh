SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_REMOVE]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from PS3REDBLUECARD(nolock) where NUM = @piNUM
  if @vStat not in (0)
  begin
    set @poErrMsg = '红蓝卡限制单 ' + @piNum + ' 不是未审核状态，不允许删除!'
    return(1)
  end
  delete from PS3REDBLUECARD where NUM = @piNum
  delete from PS3REDBLUECARDDTL where NUM = @piNum
  delete from PS3REDBLUECARDSTOREDTL where NUM = @piNum
  delete from PS3REDBLUECARDLOG where NUM = @piNum
  return(0)
end
GO
