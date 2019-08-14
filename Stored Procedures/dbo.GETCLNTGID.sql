SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GETCLNTGID] (
  @gid int output
) with encryption as
begin
  select @gid = CLNGID from SYSTEM
  update SYSTEM set CLNGID = CLNGID + 1
end
GO
