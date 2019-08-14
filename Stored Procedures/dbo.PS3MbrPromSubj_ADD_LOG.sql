SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3MbrPromSubj_ADD_LOG]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Stat int,
  @Act varchar(400),
  @Oper varchar(30)
) as
begin
  insert into PS3MBRPROMSUBJLOG(NUM, CLS, STAT, MODIFIER, ACTION, TIME)
  values(@Num, @Cls, @Stat, @Oper, @Act, Getdate())

  Return 0
end
GO
