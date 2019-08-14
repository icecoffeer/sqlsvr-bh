SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STOREOPERSCHEME_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @Act varchar(401),
  @Oper varchar(30)
) as
begin
  insert into STOREOPERSCHEMELOG(NUM, MODIFIER, TIME, STAT, ACTION, NOTE)
    values(@Num, @Oper, Getdate(), @Stat, @Act, @Act + '单据')
end
GO
