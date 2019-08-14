SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CouponExchange_On_Modify](
  @Num char(14),
  @ToStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint

  set @return_status = 0
  if @ToStat = 0
  begin
    exec @return_status = CouponExchange_On_Modify_To_0 @Num, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 100
  begin
    exec @return_status = CouponExchange_On_Modify_To_100 @Num, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 110
  begin
    exec @return_status = CouponExchange_On_Modify_To_110 @Num, @ToStat, @Oper, @Msg output
  end
  else begin
    set @Msg = '未定义的目标状态：' + convert(varchar, isnull(@ToStat, '空'))
    set @return_status = 1
  end
  return @return_status
end
GO
