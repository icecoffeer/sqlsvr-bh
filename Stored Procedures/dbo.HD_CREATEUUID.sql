SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HD_CREATEUUID]
	@poUUID varchar(32) output
as
begin
  select @poUUID = replace(newid(), '-', '') 
end
GO
