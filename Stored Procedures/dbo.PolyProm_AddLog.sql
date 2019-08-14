SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_AddLog](
  @Num char(14),
  @Cls char(10),
  @Stat int,
  @Action varchar(100),
  @Modifier varchar(30)
)
as
begin
  insert into POLYPROMLOG(NUM, CLS, STAT, ACTION, MODIFIER, TIME)
    values(@Num, @Cls, @Stat, @Action, @Modifier, GetDate())
  return 0
end
GO
