SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_ObjSendAll]
(
  @piRcv	int,
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @ID int,          @SRC int,
          @UserProperty int
  exec @ID = SeqNextValue 'NMktIvgtBasic'
  select @SRC = usergid, @UserProperty = UserProperty from system
  if @UserProperty & 16 <> 16 
  begin
    set @poErrMsg = '非总部不能发送'
    return(1)
  end
  if @SRC = @piRcv 
  begin
    set @poErrMsg = '本店不能发送'
    return(1)
  end
  insert into PSNMktIvgtObj(ID, SRC, RCV, CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT, 
    SNDTIME, NTYPE, NSTAT)--NNOTE
  select @ID, @SRC, @piRcv, CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT, 
    GETDATE(), 0, 0 from PSMktIvgtObj 

  insert into PSNMktIvgtObjProp(ID, SRC, RCV, PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE,
    SNDTIME, NTYPE, NSTAT)--NNOTE
  select @ID, @SRC, @piRcv, PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE, 
    GETDATE(), 0, 0 from PSMktIvgtObjProp where ObjCode in (select CODE from PSMktIvgtObj)

  update PSMktIvgtObj set SndTime = GetDate()
  --exec MktIvgtBasic_AddLog '', 0, '调研对象全量发送', @piOper
  return(0)
end
GO
