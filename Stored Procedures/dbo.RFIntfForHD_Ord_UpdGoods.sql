SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_UpdGoods](
  @piEmpCode varchar(10), --员工代码
  @piType int, --1：定货，2：叫货申请
  @piUUID varchar(38), --定货池记录编号
  @piStoreOrdApplyType int, --@piType=1时，该参数无效
  @piOrdQty decimal(24,4), --定货数量
  @piOrdPrice decimal(24,4), --定货单价
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vOper varchar(30),
    @vStoreOrdApplyType int

  --传入参数

  if not @piType in (1, 2)
  begin
    set @poErrMsg = '@piType无效。'
    return 1
  end

  --检查记录是否存在

  if not exists(select * from ORDERPOOL(nolock)
    where UUID = @piUUID)
  begin
    set @poErrMsg = '叫货记录不存在。'
    return 1
  end

  --门店叫货申请单类型及状态

  if @piType = 1
  begin
    set @vStoreOrdApplyType = null
  end
  else begin
    set @vStoreOrdApplyType = @piStoreOrdApplyType
    if @vStoreOrdApplyType is null or not exists(select * from STOREORDAPPLYTYPE(nolock)
      where TYPE = @vStoreOrdApplyType)
    begin
      set @poErrMsg = '叫货记录不存在。'
      return 1
    end
  end

  --更新叫货记录

  update ORDERPOOL set
    STOREORDAPPLYTYPE = @vStoreOrdApplyType,
    QTY = @piOrdQty,
    PRICE = @piOrdPrice
    where UUID = @piUUID

  return 0
end
GO
