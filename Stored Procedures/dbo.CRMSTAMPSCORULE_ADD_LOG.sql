SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CRMSTAMPSCORULE_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @Act varchar(400),
  @Oper varchar(30)
) as
begin
  insert into CRMSTAMPSCORULELOG(NUM, STAT, MODIFIER, ACTION, TIME)
    values(@Num, @Stat, @Oper, @Act, Getdate())
end

GO
