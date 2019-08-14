SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_TypeREMOVE]
(
  @piCode	char(14),
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vStat int
  select @vStat = STAT from PSMktIvgtType where Code = @piCode;
  if @vStat not in (0, 1, 2)
  begin
    set @poErrMsg = @piCode + '状态为不能删除状态'
    return(1)
  end
  if exists(select top 1 1 from PSMktIvgtDtl where TypeCode = @piCode)
  begin
    set @poErrMsg = @piCode + '类型不能删除，因为有市场调研单据使用。'
    return(1)
  end
  delete from PSMktIvgtProp where TypeCode = @piCode;
  delete from PSMktIvgtType where CODE = @piCode;
  exec MktIvgtBasic_AddLog @piCode, @vStat, '调研类型删除', @piOper
  return(0)
end
GO
