SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GoodsUpgrade_On_Modify_To_100](
  @Num char(14),
  @Oper char(30),
  @Msg varchar(255) output
)
as
begin
  /*审核单据。*/

  declare
    @Return_Status smallint,
    @Stat int,
    @IsToSettle int

  select @Stat = STAT, @IsToSettle = ISTOSETTLE
    from GOODSUPGRADE(nolock)
    where NUM = @Num

  if @@rowcount = 0
  begin
    set @Msg = '单据 ' + @Num + ' 不存在。'
    return 1
  end
  else if @Stat is null or @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能审核。'
    return 1
  end
  else if @IsToSettle is null or @IsToSettle not in (0, 1)
  begin
    set @Msg = '是否参与结算属性的值（' + isnull(convert(varchar, @IsToSettle), '') + '）不是0和1，不能审核。'
    return 1
  end
  else if exists(select 1 from GOODSUPGRADEOUTDTL d(nolock), GOODS g(nolock)
    where d.GDGID = g.GID
    and d.NUM = @Num
    and g.SALE <> 1)
  begin
    set @Msg = '换出商品中存在营销方式不是经销的商品，不能审核。'
    return 1
  end
  else if exists(select 1 from GOODSUPGRADEINDTL d(nolock), GOODS g(nolock)
    where d.GDGID = g.GID
    and d.NUM = @Num
    and g.SALE <> 1)
  begin
    set @Msg = '换入商品中存在营销方式不是经销的商品，不能审核。'
    return 1
  end

  /*更新单据的汇总信息（状态、审核人等）。*/

  update GOODSUPGRADE set
    STAT = 100,
    LSTUPDOPER = @Oper,
    LSTUPDTIME = getdate(),
    CHECKER = @Oper,
    CHKDATE = getdate()
    where NUM = @Num

  /*更新明细商品的核算价、核算售价和营销方式。*/

  update GOODSUPGRADEOUTDTL set
    INPRC = g.INPRC,
    RTLPRC = g.RTLPRC,
    SALE = g.SALE,
    BILLTO = g.BILLTO,
    TAXRATE = g.TAXRATE,
    DEPT = g.F1
    from GOODS g
    where GDGID = g.GID
    and NUM = @Num

  update GOODSUPGRADEINDTL set
    INPRC = g.INPRC,
    RTLPRC = g.RTLPRC,
    SALE = g.SALE,
    BILLTO = g.BILLTO,
    TAXRATE = g.TAXRATE,
    DEPT = g.F1
    from GOODS g
    where GDGID = g.GID
    and NUM = @Num

  /*记录日志。*/

  exec GoodsUpgrade_Add_Log @Num, 100, '审核', @Oper

  /*生成自营进货单和自营退货单。*/

  if @IsToSettle in (0, 1)
  begin
    exec @Return_Status = GoodsUpgrade_Gen_StkIn @Num, @Oper, @Msg output
    if @Return_Status <> 0
      return @Return_Status
    exec @Return_Status = GoodsUpgrade_Gen_StkInBck @Num, @Oper, @Msg output
    if @Return_Status <> 0
      return @Return_Status
  end

  return 0
end
GO
