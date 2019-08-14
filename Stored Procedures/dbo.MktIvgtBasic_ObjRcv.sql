SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_ObjRcv]
(
  @piCode varchar(6),
  @piSrc int,
  @piID	int,
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vNType int
  select @vNType = NType from PSNMktIvgtObj 
    where id = @piID and Src = @piSrc and Code = @piCode
  if @vNType = 0
  begin
    set @poErrMsg = '是发送记录不能接收'
    return(1)
  end
  delete from PSMktIvgtObjProp 
    where ObjCode in (select ObjCode from PSNMktIvgtObjProp 
      where id = @piID and Src = @piSrc and ObjCode = @piCode)  
  delete PSMktIvgtObj from PSNMktIvgtObj Net 
    where Net.id = @piID and Net.Src = @piSrc and Net.Code = @piCode
      and Net.Code = PSMktIvgtObj.Code

  insert into PSMktIvgtObj
    (CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT)
  select CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT
    from PSNMktIvgtObj where id = @piID and src = @piSrc and Code = @piCode
  insert into PSMktIvgtObjProp(PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE)
  select PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE
    from PSNMktIvgtObjProp where ObjCode = @piCode and id = @piID and src = @piSrc

  exec MktIvgtBasic_AddLog '', 0, '调研对象接收', @piOper
  delete from PSNMktIvgtObj 
    where id = @piID and Src = @piSrc and Code = @piCode
  return(0) 
end
GO
