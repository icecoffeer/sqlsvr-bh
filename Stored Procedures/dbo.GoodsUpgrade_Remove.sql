SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_Remove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  /*彻底删除一张未审核的单据。*/

  declare
    @Return_Status smallint,
    @Stat int

  select @Stat = STAT from GOODSUPGRADE(nolock) where NUM = @Num

  if @@rowcount = 0
  begin
    set @Msg = '单据 ' + @Num + ' 不存在。'
    return 1
  end
  else if @Stat is null or @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能删除。'
    return 1
  end

  exec @Return_Status = GoodsUpgrade_DoRemove @Num, @Msg output
  if @Return_Status <> 0
    return @Return_Status

  delete from GOODSUPGRADELOG where NUM = @Num

  return 0
end
GO
