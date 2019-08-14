SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SEQEXISTS] (
	@pi_objname char(32),		--对象名称
	@po_exists smallint output	--返回是否存在，0=不存在，1=存在
) with encryption as
begin
  if exists (select 1 from seq where objname=@pi_objname)
     select @po_exists = 1
  else
     select @po_exists = 0
end
GO
