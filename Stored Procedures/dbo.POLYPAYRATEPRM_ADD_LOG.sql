SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POLYPAYRATEPRM_ADD_LOG]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Stat int,
  @Act varchar(401),
  @Oper varchar(30)
) as
begin
  insert into POLYPAYRATEPRMLOG(NUM, CLS, STAT, MODIFIER, ACT, TIME)
    values(@Num, @Cls, @Stat, @Oper, @Act, Getdate());
end
GO
