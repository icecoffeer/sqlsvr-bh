SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_Add_Log](
  @Num char(14),
  @Stat int,
  @Action varchar(100),
  @Oper char(30)
)
as
begin
  /*记录单据状态变化的日志。*/

  insert into GOODSUPGRADELOG(NUM, STAT, ACTION, MODIFIER, TIME)
    values(@Num, @Stat, @Action, @Oper, getdate())

  return 0
end
GO
