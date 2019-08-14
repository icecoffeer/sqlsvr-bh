SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_On_Modify_To_0](
  @Num char(14),
  @Oper char(30),
  @Msg varchar(255) output
)
as
begin
  /*未审核保存单据。*/

  declare
    @Stat int

  select @Stat = STAT from GOODSUPGRADE(nolock) where NUM = @Num

  if @@rowcount = 0
  begin
    set @Msg = '单据 ' + @Num + ' 不存在。'
    return 1
  end
  else if @Stat is null or @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能未审核保存。'
    return 1
  end

  update GOODSUPGRADE set
    LSTUPDOPER = @Oper,
    LSTUPDTIME = getdate()
    where NUM = @Num

  exec GoodsUpgrade_Add_Log @Num, 0, '未审核', @Oper

  return 0
end
GO
