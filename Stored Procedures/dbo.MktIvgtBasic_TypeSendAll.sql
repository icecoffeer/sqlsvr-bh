SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_TypeSendAll]
(
  @piRcv	int,
  @piOper	varchar(30),
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @ID int,          @SRC int,
          @UserProperty int, @str varchar(20)
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
  insert into PSNMktIvgtType(ID, SRC, RCV, CODE, NAME, CREATOR, CREATETIME, NOTE, STAT, 
    SNDTIME, NTYPE, NSTAT)--NNOTE
  select @ID, @SRC, @piRcv, CODE, NAME, CREATOR, CREATETIME, NOTE, STAT, 
    GETDATE(), 0, 0 from PSMktIvgtType where Rtrim(Code) <> '-'

  insert into PSNMktIvgtProp(ID, SRC, RCV, CODE, NAME, TYPECODE, TYPENAME, 
    PROPCLS, PROPTYPE, CREATOR, CREATETIME, NOTE)
  select @ID, @SRC, @piRcv, CODE, NAME, TYPECODE, TYPENAME, 
    PROPCLS, PROPTYPE, CREATOR, CREATETIME, NOTE 
    from PSMktIvgtProp where TypeCode in (select Code from PSMktIvgtType)
    and Rtrim(TypeCode) <> '-'
    
  update PSMktIvgtType set SndTime = GetDate()
  set @str = Convert(char, @piRcv)
  exec MktIvgtBasic_AddLog @str, 0, '调研类型全量发送', @piOper
  return(0)
end
GO
