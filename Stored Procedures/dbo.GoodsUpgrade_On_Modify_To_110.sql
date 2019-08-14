SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_On_Modify_To_110](
  @Num char(14),
  @Oper char(30),
  @Msg varchar(255) output
)
as
begin
  /*作废单据。*/

  declare
    @Return_Status smallint,
    @Stat int,
    @GenCls char(10),
    @GenNum char(14),
    @IsToSettle smallint

  /*校验商品换货单的合法性。*/

  select @Stat = STAT, @IsToSettle = ISTOSETTLE
    from GOODSUPGRADE(nolock)
    where NUM = @Num

  if @@rowcount = 0
  begin
    set @Msg = '单据 ' + @Num + ' 不存在。'
    return 1
  end
  else if @Stat is null or @Stat <> 100
  begin
    set @Msg = '不是已审核的单据，不能作废。'
    return 1
  end

  /*作废之前，要保证生成的单据已经被删除（未审核）或冲单（已审核）了。*/

  if @IsToSettle in (0, 1)
  begin
    set @Return_Status = 0
  
    declare c_GoodsUpgradeGenBills cursor for
      select GENCLS, GENNUM from GOODSUPGRADEGENBILLS(nolock)
      where NUM = @Num
    open c_GoodsUpgradeGenBills
  
    fetch next from c_GoodsUpgradeGenBills into @GenCls, @GenNum
    while @@fetch_status = 0
    begin
      if rtrim(@GenCls) = '自营进'
      begin
        select @Stat = STAT
          from STKIN(nolock)
          where CLS = '自营'
          and NUM = @GenNum
          and GENBILL = 'GOODSUPGRADE'
          and GENNUM = @Num
        if not (@@rowcount = 0 or @Stat = 2)
        begin
          set @Msg = '检查到生成的单据中有未被删除或（和）未被冲单的，请先删除或（并）冲单这些单据，然后再来作废本单据。'
          set @Return_Status = 1
          goto LABEL_EXIT_OF_CURSOR
        end
      end
      else if rtrim(@GenCls) = '自营进退'
      begin
        select @Stat = STAT
          from STKINBCK(nolock)
          where CLS = '自营'
          and NUM = @GenNum
          and GENBILL = 'GOODSUPGRADE'
          and GENNUM = @Num
        if not (@@rowcount = 0 or @Stat = 2)
        begin
          set @Msg = '检查到生成的单据中有未被删除或（和）未被冲单的，请先删除或冲单这些单据，然后再来作废本单据。'
          set @Return_Status = 1
          goto LABEL_EXIT_OF_CURSOR
        end
      end
  
      fetch next from c_GoodsUpgradeGenBills into @GenCls, @GenNum
    end
  
LABEL_EXIT_OF_CURSOR:
    close c_GoodsUpgradeGenBills
    deallocate c_GoodsUpgradeGenBills
    if @Return_Status <> 0
      return @Return_Status
  end

  /*更新单据的汇总信息（状态、最后修改人等）。*/

  update GOODSUPGRADE set
    STAT = 110,
    LSTUPDOPER = @Oper,
    LSTUPDTIME = getdate()
    where NUM = @Num

  /*记录日志。*/

  exec GoodsUpgrade_Add_Log @Num, 110, '作废', @Oper

  return 0
end
GO
