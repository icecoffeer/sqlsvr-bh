SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_AddLog](
  @Num char(14),
  @Stat int,
  @Action varchar(100),
  @Modifier varchar(30)
)
as
begin
  insert into POLYPRCPRMLOG(NUM, STAT, ACTION, MODIFIER, TIME)
    values(@Num, @Stat, @Action, @Modifier, GetDate())
  return 0
end
GO
