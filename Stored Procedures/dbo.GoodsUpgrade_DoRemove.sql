SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_DoRemove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  /*保存单据之前先删除单据的数据。*/

  delete from GOODSUPGRADE where NUM = @Num
  delete from GOODSUPGRADEOUTDTL where NUM = @Num
  delete from GOODSUPGRADEINDTL where NUM = @Num

  return 0
end
GO
