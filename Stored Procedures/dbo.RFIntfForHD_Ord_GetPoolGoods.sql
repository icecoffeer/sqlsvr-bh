SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GetPoolGoods](
  @piEmpCode varchar(10),
  @piUUID varchar(38),
  @poType int output, --1：定货，2：叫货申请
  @poWrhCode varchar(10) output,
  @poVdrCode varchar(10) output,
  @poStoreOrdApplyType int output,
  @poGdGid int output,
  @poGdCode varchar(40) output,
  @poNameSpec varchar(90) output,
  @poMUnit varchar(6) output,
  @poQpc decimal(24,4) output,
  @poSort varchar(255) output,
  @poBrand varchar(255) output,
  @poAlc varchar(10) output,
  @poLowInv decimal(24,4) output,
  @poHighInv decimal(24,4) output,
  @poN int output,
  @poNSumSaleQty decimal(24,4) output,
  @poNAvgSaleQty decimal(24,4) output,
  @poInvQty decimal(24,4) output,
  @poOrdQty decimal(24,4) output, --在单量
  @poSuggestQty decimal(24,4) output,
  @poQty decimal(24,4) output,
  @poPrice decimal(24,4) output,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vOrderType varchar(10),
    @vType int,
    @vWrhCode varchar(10),
    @vVdrCode varchar(10),
    @vStoreOrdApplyType int,
    @vGdCode varchar(10),
    @vQty decimal(24,4),
    @vPrice decimal(24,4),
    @vDefOrdPrice decimal(24,4),
    @vTmpVdrCode varchar(10),
    @vTmpVdrName varchar(100)

  --在定货池中找到叫货记录

  select @vOrderType = op.ORDERTYPE,
    @vWrhCode = w.CODE,
    @vVdrCode = v.CODE,
    @vGdCode = g.CODE,
    @vQty = op.QTY,
    @vPrice = op.PRICE,
    @vStoreOrdApplyType = op.STOREORDAPPLYTYPE
    from ORDERPOOL op(nolock)
      join GOODS g(nolock) on op.GDGID = g.GID
      join WAREHOUSE w(nolock) on op.WRH = w.GID
      join VENDOR v(nolock) on op.VDRGID = v.GID
    where op.UUID = @piUUID

  if @@rowcount = 0
  begin
    set @poErrMsg = '叫货记录不存在。'
    return 1
  end
  else if @vOrderType = 'RF定货'
  begin
    set @vType = 1
  end
  else if @vOrderType = 'RF叫货申请'
  begin
    set @vType = 2
  end
  else begin
    set @poErrMsg = '不是RF设备生成的叫货记录，不能查看。'
    return 1
  end

  --获取商品信息

  exec @return_status = RFIntfForHD_Ord_GetGoods
    @piEmpCode,
    @vType,
    @vWrhCode,
    @vGdCode,
    @poGdGid output,
    @poGdCode output,
    @poNameSpec output,
    @poMUnit output,
    @poQpc output,
    @poSort output,
    @poBrand output,
    @poAlc output,
    @poLowInv output,
    @poHighInv output,
    @poN output,
    @poNSumSaleQty output,
    @poNAvgSaleQty output,
    @poInvQty output,
    @poOrdQty output,
    @poSuggestQty output,
    @vDefOrdPrice output,
    @vTmpVdrCode output,
    @vTmpVdrName output,
    @poErrMsg output
  if @return_status <> 0
    return @return_status

  set @poType = @vType
  set @poWrhCode = @vWrhCode
  set @poVdrCode = @vVdrCode
  set @poQty = @vQty
  set @poPrice = @vPrice
  set @poStoreOrdApplyType = @vStoreOrdApplyType

  return 0
end
GO
