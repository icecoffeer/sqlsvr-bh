SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_TypeRcvOneEx]
(
  @bill_id int,
  @src_id int,
  @OPER	varchar(30),
  @MSG	varchar(255)	output
)
as
begin
  declare @vNType int
  select @vNType = NType from PSNMktIvgtType 
    where id = @bill_id and Src = @src_id 
  if @vNType = 0
  begin
    set @Msg = '是发送记录不能接收'
    return(1)
  end  
  --处理属性
  delete from PSMktIvgtProp 
    where TypeCode in (select TypeCode from PSNMktIvgtProp 
      where id = @bill_id and Src = @src_id)  
  insert into PSMktIvgtProp(TYPECODE, TYPENAME, CODE, NAME, 
    PROPCLS, PROPTYPE, NOTE, CREATOR, CREATETIME)
    select TYPECODE, TYPENAME, CODE, NAME, 
      PROPCLS, PROPTYPE, NOTE, CREATOR, CREATETIME
    from PSNMktIvgtProp 
    where ID = @bill_id and SRC = @src_id
  --处理类型  
  delete PSMktIvgtType from PSNMktIvgtType Net 
    where Net.id = @bill_id and Net.Src = @src_id 
      and Net.Code = PSMktIvgtType.Code 
  insert into PSMktIvgtType
    (CODE, NAME, CREATOR, CREATETIME, NOTE, STAT)
  select CODE, NAME, CREATOR, CREATETIME, NOTE, STAT
    from PSNMktIvgtType 
    where id = @bill_id and src = @src_id 
  exec MktIvgtBasic_AddLog '', 0, '调研类型全量发送', @Oper
  delete from PSNMktIvgtType 
    where id = @bill_id and Src = @src_id
  delete from PSNMktIvgtProp 
    where id = @bill_id and Src = @src_id
  return(0) 
end
GO
