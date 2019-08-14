SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CouponExchange_AddLog](
  @Num char(14),
  @Stat int,
  @Modifier varchar(30),
  @Action varchar(100)
)
as
begin
  waitfor delay '00:00:00.003'
  insert into COUPONEXCHANGELOG(NUM, STAT, MODIFIER, TIME, ACTION)
    values(@Num, @Stat, @Modifier, getdate(), @Action)
  return 0
end
GO
