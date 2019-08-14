SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VdrLeDel](
  @piNum VARCHAR(14),
  @poErrMsg varchar(255) output
)as
begin
  declare
    @vStat int
  select @vStat = STAT from VDRLESSEE(nolock)
    where NUM = @piNum
  if @@RowCount = 0
  begin
    set @poErrMsg = '单据' + @piNum + '不存在。'
    return 1
  end
  if @vStat <> 0
  begin
    set @poErrMsg = '不是未审核的单据，不能删除。'
    return 1
  end
  delete from VDRLESSEE where NUM = @piNum
  delete from VDRLESSORTD where NUM = @piNum
  delete from VDRLESSORTBRAND where NUM = @piNum
  return 0
end
GO
