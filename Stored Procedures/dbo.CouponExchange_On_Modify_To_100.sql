SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CouponExchange_On_Modify_To_100](
  @Num char(14),
  @ToStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @Stat int

  --检查单据状态。
  set @Stat = null
  select @Stat = STAT from COUPONEXCHANGE(nolock) where NUM = @Num
  if @Stat is null
  begin
    set @Msg = '未找到该单据：' + isnull(@Num, '')
    return 1
  end
  else if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能审核。'
    return 1
  end

  --修改单据信息。
  update COUPONEXCHANGE set
    STAT = @ToStat,
    LSTUPDOPER = @Oper,
    LSTUPDTIME = getdate(),
    CHECKER = @Oper,
    CHKDATE = getdate()
    where NUM = @Num

  --记录审核日志。
  exec CouponExchange_AddLog @Num, @ToStat, @Oper, null

  return 0
end
GO
