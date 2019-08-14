SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprmrule_addlog]
(
  @piNum	char(18),
  @act varchar(20),
  @piOper	char(30)
)
as
begin
  insert into gftprmrulelog(RCode, cls, modifier, time) 
  select @piNum, @act, @piOper, getdate()

  return 0
end
GO
