SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GETGDGID] (
  @gid int output
) with encryption as
begin
  select @gid = GDGID from SYSTEM
  update SYSTEM set GDGID = GDGID + 1
end
GO
