SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_ObjSendOne]
(
  @piCode	char(14),
  @piRcv	int,
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vStat int,          @ID int,
          @SRC int,            @UserProperty int 
  exec @ID = SeqNextValue 'NMktIvgtBasic'
  select @SRC = usergid, @UserProperty = UserProperty from system
  if @UserProperty & 16 <> 16 
  begin
    set @poErrMsg = '非总部不能发送'
    return(1)
  end
  if @piRcv = @SRC 
  begin
    set @poErrMsg = '本店不能发送'
    return(1)
  end  
  select @vStat = STAT from PSMktIvgtType where Code = @piCode;
  if @vStat not in (0, 1, 2)
  begin
    set @poErrMsg = @piCode + '状态为不能发送状态'
    return(1)
  end
  insert into PSNMktIvgtObj(ID, SRC, RCV, CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT, 
    SNDTIME, NTYPE, NSTAT)--NNOTE
  select @ID, @SRC, @piRcv, CODE, NAME, TYPECODE, TYPENAME, CREATOR, CREATETIME, NOTE, STAT, 
    GETDATE(), 0, 0 from PSMktIvgtObj where Code = @piCode
    
  insert into PSNMktIvgtObjProp(ID, SRC, RCV, PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE,
    SNDTIME, NTYPE, NSTAT)--NNOTE
  select @ID, @SRC, @piRcv, PROPCODE, PROPNAME, OBJCODE, OBJNAME, VALUE, 
    GETDATE(), 0, 0 from PSMktIvgtObjProp where ObjCode = @piCode
  update PSMktIvgtObj set SndTime = GetDate() where Code = @piCode
  --exec MktIvgtBasic_AddLog @piCode, @vStat, '调研对象发送一条', @piOper
  return(0)
end
GO
