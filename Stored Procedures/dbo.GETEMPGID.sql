SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GETEMPGID] (
  @gid int output
) with encryption as
begin
  select @gid = EMPGID from SYSTEM
  update SYSTEM set EMPGID = EMPGID + 1
end
GO
