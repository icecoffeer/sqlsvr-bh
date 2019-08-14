SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_TypeSendOne]
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
  insert into PSNMktIvgtType(ID, SRC, RCV, CODE, NAME, CREATOR, CREATETIME, NOTE, STAT, 
    SNDTIME, NTYPE, NSTAT)--NNOTE
  select @ID, @SRC, @piRcv, CODE, NAME, CREATOR, CREATETIME, NOTE, STAT, 
    GETDATE(), 0, 0 from PSMktIvgtType where Code = @piCode

  insert into PSNMktIvgtProp(ID, SRC, RCV, CODE, NAME, TYPECODE, TYPENAME, 
    PROPCLS, PROPTYPE, CREATOR, CREATETIME, NOTE)
  select @ID, @SRC, @piRcv, CODE, NAME, TYPECODE, TYPENAME, 
    PROPCLS, PROPTYPE, CREATOR, CREATETIME, NOTE 
    from PSMktIvgtProp where TypeCode = @piCode

  update PSMktIvgtType set SndTime = GetDate() where Code = @piCode
  exec MktIvgtBasic_AddLog @piCode, @vStat, 'SENDONETYPE', @piOper
  return(0)
end
GO
