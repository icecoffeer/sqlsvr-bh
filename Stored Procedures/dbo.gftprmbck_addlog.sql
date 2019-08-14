SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprmbck_addlog]
(
  @piNum	char(14),
  @stat int,
  @piOper	char(30)
)
as
begin
  insert into gftprmbcklog(num, stat, modifier, time)
  select @piNum, @stat, @piOper, getdate()

  return 0
end
GO
