SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_On_Modify](
  @Num char(14),
  @ToStat int,
  @Oper char(30),
  @Msg varchar(255) output
)
as
begin
  /*单据状态变化的接口。凡是要更改单据状态的，都请调用这个接口。*/

  declare
    @Return_Status smallint

  if @ToStat = 0
  begin
    exec @Return_Status = GoodsUpgrade_On_Modify_To_0 @Num, @Oper, @Msg output
  end
  else if @ToStat = 100
  begin
    exec @Return_Status = GoodsUpgrade_On_Modify_To_100 @Num, @Oper, @Msg output
  end
  else if @ToStat = 110
  begin
    exec @Return_Status = GoodsUpgrade_On_Modify_To_110 @Num, @Oper, @Msg output
  end
  else begin
    set @Msg = '未定义的目标状态：' + convert(varchar, @ToStat)
    set @Return_Status = 1
  end

  if @Return_Status is null
  begin
    set @Msg = '没有给存储过程GoodsUpgrade_On_Modify指定返回值。'
    set @Return_Status = 1
  end

  return @Return_Status
end
GO
