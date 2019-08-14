SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CouponExchange_Remove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @Stat int

  set @Stat = null
  select @Stat = STAT from COUPONEXCHANGE(nolock) where NUM = @Num
  if @Stat is null
  begin
    set @Msg = '未找到该单据：' + isnull(@Num, '')
    return 1
  end
  else if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能删除。'
    return 1
  end

  exec @return_status = CouponExchange_DoRemove @Num, @Msg output
  if @return_status <> 0
    return @return_status

  delete from COUPONEXCHANGELOG where NUM = @Num
  return 0
end
GO
