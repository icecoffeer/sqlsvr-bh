SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_TypeRcvOne]
(
  @piCode	int,
  @piSrc	int,
  @piID	int,
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vNType int
  select @vNType = NType from PSNMktIvgtType 
    where id = @piID and Src = @piSrc and Code = @piCode
  if @vNType = 0
  begin
    set @poErrMsg = '是发送记录不能接收'
    return(1)
  end  
  --处理属性
  delete from PSMktIvgtProp 
    where TypeCode in (select TypeCode from PSNMktIvgtProp 
      where id = @piID and Src = @piSrc and TypeCode = @piCode)  
  insert into PSMktIvgtProp(TYPECODE, TYPENAME, CODE, NAME, 
    PROPCLS, PROPTYPE, NOTE, CREATOR, CREATETIME)
    select TYPECODE, TYPENAME, CODE, NAME, 
      PROPCLS, PROPTYPE, NOTE, CREATOR, CREATETIME
    from PSNMktIvgtProp 
    where ID = @piID and SRC = @piSRC and TypeCode = @piCode
  --处理类型  
  delete PSMktIvgtType from PSNMktIvgtType Net 
    where Net.id = @piID and Net.Src = @piSrc and Net.Code = @piCode
      and Net.Code = PSMktIvgtType.Code 
  insert into PSMktIvgtType
    (CODE, NAME, CREATOR, CREATETIME, NOTE, STAT)
  select CODE, NAME, CREATOR, CREATETIME, NOTE, STAT
    from PSNMktIvgtType 
    where id = @piID and src = @piSrc and Code = @piCode
  exec MktIvgtBasic_AddLog '', 0, '调研类型全量发送', @piOper
  delete from PSNMktIvgtType 
    where id = @piID and Src = @piSrc and Code = @piCode
  delete from PSNMktIvgtProp 
    where id = @piID and Src = @piSrc and TypeCode = @piCode
  return(0) 
end
GO
