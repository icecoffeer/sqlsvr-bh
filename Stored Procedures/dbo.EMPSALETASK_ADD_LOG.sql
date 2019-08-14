SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPSALETASK_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @Action varchar(401),
  @Oper varchar(30)
) as
begin
  insert into EMPSALETASKLOG(NUM, STAT, MODIFIER, ACTION, TIME)
    values(@Num, @Stat, @Oper, @Action, Getdate());
end
GO
