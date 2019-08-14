SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrmTopicDel]
(
  @piNum  varchar(14),
  @piOper char(30),
  @poErrMsg varchar(255) output
)
as
begin
  declare @stat int
  if rtrim(@piNum) = '-' 
  begin
    set @poErrMsg = '主题：[' + @piNum + ']缺省主题不能删除'
    return 1
  end
  if exists( select 1 from prmtopic t, gftprm g where g.topic = t.code and t.code = @piNum )
  begin
    set @poErrMsg = '主题：[' + @piNum + ']被赠品促销规则单引用，不能删除'
    return 1
  end
  delete from prmtopic where rtrim(code) = rtrim(@piNum)
  return 0
end
GO
