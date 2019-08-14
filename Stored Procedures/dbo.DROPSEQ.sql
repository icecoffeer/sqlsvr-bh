SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DROPSEQ](
	@pi_objname char(32)		--对象名称
) with encryption as
begin
  if exists (select 1 from seq where objname=@pi_objname)
      delete from seq where objname=@pi_objname
  else
  begin
      --raiserror('指定的SEQUENCE不存在', 16, 1)
      print 'WARNING: 指定的SEQUENCE已经存在'
      return(1)
  end
end
GO
