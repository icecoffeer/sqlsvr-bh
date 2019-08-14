SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERBCKSTGRCV_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @Act varchar(401),
  @Oper varchar(30)
) as
begin
  insert into VOUCHERBCKSTGRCVLOG(Num, Stat, Modifier, Act, Time)
    values(@Num, @Stat, @Oper, @Act, Getdate());
end
GO
