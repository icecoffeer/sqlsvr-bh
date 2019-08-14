SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GETVDRGID] (
  @gid int output
) with encryption as
begin
  select @gid = VDRGID from SYSTEM
  update SYSTEM set VDRGID = VDRGID + 1
end
GO
