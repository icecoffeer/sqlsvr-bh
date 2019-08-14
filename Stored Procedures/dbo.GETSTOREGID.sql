SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GETSTOREGID] (
  @storegid int output
) with encryption as
begin
  select @storegid = STOREGID from SYSTEM
  update SYSTEM set STOREGID = STOREGID + 1000000
end
GO
