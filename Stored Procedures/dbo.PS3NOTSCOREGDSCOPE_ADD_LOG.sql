SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3NOTSCOREGDSCOPE_ADD_LOG]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Stat int,
  @Act varchar(400),
  @Oper varchar(30)
) as
begin
  insert into PS3NOTSCOREGDSCOPELOG(NUM, CLS, STAT, MODIFIER, ACTION, TIME)
    values(@Num, @Cls, @Stat, @Oper, @Act, Getdate())
end
GO
