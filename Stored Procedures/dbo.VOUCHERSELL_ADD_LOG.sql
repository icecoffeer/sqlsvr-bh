SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERSELL_ADD_LOG]
(
  @Num varchar(14),
  @Stat int,
  @Act varchar(401),
  @Oper varchar(30)
) as
begin
  if (@Act = '修改') and (select count(1) from VOUCHERSELLLOG where NUM = @Num) > 0
    insert into VOUCHERSELLLOG(Num, Stat, Modifier, Action, Time)
      values(@Num,  @Stat, @Oper, '新增', Getdate())
  else
    insert into VOUCHERSELLLOG(Num, Stat, Modifier, Action, Time)
      values(@Num, @Stat, @Oper, @Act, Getdate());
end
GO
