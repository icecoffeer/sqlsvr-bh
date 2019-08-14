SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SEQNEXTVALUE](
	@piObjName char(32)
) with encryption as
begin
  declare @ret int

  if exists (select 1 from seq where objname=@piObjName)
  begin
	  select @ret = NEXTVALUE from SEQ where objname = @piObjName
	  update SEQ with (rowlock) set NEXTVALUE = NEXTVALUE + INC
	  where objname = @piObjName
	  return(@ret)
  end
  else
  begin
      raiserror('指定的SEQUENCE不存在', 16, 1)
      return(1)
  end  
end
GO
