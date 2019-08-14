SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_VDRPAYRTN_REMOVE] (
  @piNum varchar(14),                     --单号
  @piOperGid integer,                     --操作人
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vStat integer

  --数据检查
  select @vStat = STAT from CTVDRPAYRTN where NUM = @piNum
  if @vStat <> 0
  begin
    set @poErrMsg = '交款退款单 ' + @piNum + ' 不是未审核状态，不允许删除.'
    return(1)
  end

  delete from CTVDRPAYRTN where NUM = @piNum
  delete from CTVDRPAYRTNLOG where NUM = @piNum

  return(0)
end
GO
