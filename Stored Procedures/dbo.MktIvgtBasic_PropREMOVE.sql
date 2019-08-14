SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_PropREMOVE]
(
  @piTypeCode	char(14),
  @piCode	char(14),
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @tmp varchar(50)
  if exists(select top 1 1 from PSMktIvgtDtl mst, PSMktIvgtDtlDtl Dtl 
    where mst.num = dtl.num and mst.Line = dtl.Line 
      and mst.TypeCode = @piTypeCode and PropCode = @piCode)
  begin
    set @poErrMsg = @piCode + '属性不能删除，因为有市场调研单据使用。'
    return(1)
  end
  delete from PSMktIvgtProp where TypeCode = @piTypeCode and Code = @piCode;
  set @tmp =  '调研属性[' + @piCode + ']删除'
  exec MktIvgtBasic_AddLog @piTypeCode, 0, @tmp, @piOper
  return(0)
end
GO
