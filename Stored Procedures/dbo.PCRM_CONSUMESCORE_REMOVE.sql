SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CONSUMESCORE_REMOVE] (
  @piNum char(14),                     --单号
  @piOperGid int,                      --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vStat int

  select @vStat = STAT from CRMCONSCORE(nolock) where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '消费积分单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end
  
  delete from CRMCONSCORE where NUM = @piNum
  delete from CRMCONSCORESCODTL where NUM = @piNum
  delete from CRMCONSCORELOG where NUM = @piNum
  return(0)
end
GO
