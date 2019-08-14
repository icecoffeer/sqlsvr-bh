SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_ObjRcvEx]
(
  @bill_id int,
  @src_id int,
  @OPER	varchar(30),
  @MSG	varchar(255)	output
)
as
begin
  declare @vNType int
  select @vNType = NType from PSNMktIvgtObj 
    where id = @bill_id and Src = @src_id
  if @vNType = 0
  begin
    set @Msg = '是发送记录不能接收'
    return(1)
  end
  delete from PSMktIvgtObjProp 
    where ObjCode in (select ObjCode from PSNMktIvgtObjProp 
      where id = @bill_id and Src = @src_id)  
  delete PSMktIvgtObj from PSNMktIvgtObj Net 
    where Net.id = @bill_id and Net.Src = @src_id
      and Net.Code = PSMktIvgtObj.Code
  insert into PSMktIvgtObj
    (CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT)
  select CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT
    from PSNMktIvgtObj where id = @bill_id and src = @src_id
  insert into PSMktIvgtObjProp(PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE)
  select PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE
    from PSNMktIvgtObjProp where id = @bill_id and src = @src_id
  exec MktIvgtBasic_AddLog '', 0, '调研对象接收', @Oper
  delete from PSNMktIvgtObj 
    where id = @bill_id and Src = @src_id
  return(0) 
end
GO
