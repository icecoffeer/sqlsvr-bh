SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[SUSER_SNAMEex]() returns varchar(100)
as
begin
  declare @empcode varchar(100), @loginname varchar(100)
  select @loginname = suser_sname()
  select @empcode = sUBSTRING(@loginname, CHARINDEX('_', @loginname) + 1, 20)
  return(@empcode)
end
GO
