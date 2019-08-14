SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_AddGoods](
  @piEmpCode varchar(10),
  @piType int, --1：定货，2：叫货申请
  @piWrhCode varchar(10),
  @piArticleCode varchar(40),
  @piVdrCode varchar(10),
  @piStoreOrdApplyType int, --@piType=1时，该参数无效
  @piOrdQty decimal(24,4), --定货数量
  @piOrdPrice decimal(24,4), --定货单价
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vGdGid int,
    @vWrhGid int,
    @vVdrGid int,
    @vBillto int,
    @vToday datetime,
    @vPresent datetime,
    @vOper varchar(30),
    @vOrderType varchar(10),
    @vOrdMaxPrice decimal(24,4),
    @vOrdMaxQty decimal(24,4),
    @vStoreOrdApplyType int,
    @vStoreOrdApplyStat int,
    @vBarCodeQty decimal(24,4),
    @vBarCodeAmt decimal(24,2),
    @optUseVdrAgmt int,
    @optSingleVdr int,
    @optUserGid int,
    @optLimitPrc int,
    @optMaxPriceChar varchar(255),
    @optSetQtyMax int,
    @optOrderQtyMax varchar(255)

  --检查传入参数定货类型。

  if not @piType in (1, 2)
  begin
    set @poErrMsg = '@piType无效。'
    return 1
  end

  --获取一般变量的值。

  set @vToday = convert(datetime, convert(varchar, getdate(), 102))
  set @vPresent = getdate()

  --获取系统变量的值。

  select @optSingleVdr = SINGLEVDR,
    @optUserGid = USERGID
    from SYSTEM(nolock)

  --检查员工代码，并获取员工信息。

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '员工代码' + rtrim(@piEmpCode) + '无效。'
    return 1
  end

  --获取商品GID。

  exec @return_status = RFIntfForHD_GetGoods
    @piArticleCode, @vGdGid output, @vBarCodeQty output, @vBarCodeAmt output, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取仓位GID。

  if @piType = 1 --定货
  begin
    select @vWrhGid = GID
      from WAREHOUSE(nolock)
      where CODE = @piWrhCode
    if @@rowcount = 0
    begin
      set @poErrMsg = '仓位代码' + rtrim(isnull(@piWrhCode, '')) + '无效。'
      return 1
    end
  end
  else begin --叫货申请
    exec OptReadInt 700, 'DefaultWrhGid', 1, @vWrhGid output
    if @vWrhGid is null
    begin
      set @vWrhGid = 1
    end
  end

  --获取商品信息。

  select @vBillto = g.BILLTO
    from GOODS g(nolock)
    where g.GID = @vGdGid

  --检查供应商
  select @vVdrGid = GID from VENDOR(nolock)
    where CODE = @piVdrCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '供应商代码' + rtrim(@piVdrCode) + '无效。'
    return 1
  end

  exec @return_status = RFIntfForHD_Ord_SearchVendor @piType, @vWrhGid, @vGdGid,
    @poErrMsg output
  if @return_status <> 0
    return @return_status

  if not exists(select * from TMPRFORDVDR(nolock)
    where SPID = @@spid
    and VDRGID = @vVdrGid)
  begin
    set @poErrMsg = '供应商不符合规则'
    return 1
  end

  --检查门店叫货申请单类型。

  if @piType = 2 and not exists(select * from STOREORDAPPLYTYPE(nolock)
    where TYPE = @piStoreOrdApplyType)
  begin
    set @poErrMsg = '类型代码无效。'
    return 1
  end

  --定货单检查单价、数量。

  if @piType = 1
  begin
    --检查单价

    exec OPTREADINT 114, 'LIMITPRC', 0, @optLimitPrc output
    exec OPTREADSTR 114, 'MAXPRICE', '', @optMaxPriceChar output
    set @optMaxPriceChar = rtrim(@optMaxPriceChar)
    if @optLimitPrc = 1 and @optMaxPriceChar <> ''
    begin
      exec GetGoodsOrderMaxPrc @vGdGid, @vVdrGid, @vOrdMaxPrice output
      if @vOrdMaxPrice is not null and @piOrdPrice > @vOrdMaxPrice
      begin
        set @poErrMsg = '单价不能高于' + convert(varchar, @vOrdMaxPrice)
        return 1
      end
    end

    --检查数量

    exec OptReadInt 114, 'SetQtyMax', 0, @optSetQtyMax output
    exec OptReadStr 114, 'OrderQtyMax', '0', @optOrderQtyMax output
    if @optSetQtyMax = 1
    begin
      set @vOrdMaxQty = convert(decimal(24,4), @optOrderQtyMax)
      if @piOrdQty > @vOrdMaxQty
      begin
        set @poErrMsg = '数量不能高于' + convert(varchar, @vOrdMaxQty)
        return 1
      end
    end
  end

  --根据不同的调用者，设定一些字段的值。

  if @piType = 1
  begin
    set @vOrderType = 'RF定货'
    set @vStoreOrdApplyType = null
    set @vStoreOrdApplyStat = null
  end
  else begin
    set @vOrderType = 'RF叫货申请'
    set @vStoreOrdApplyType = isnull(@piStoreOrdApplyType, 0)
    set @vStoreOrdApplyStat = 0
  end

  --插入定货池。

  exec @return_status = OrderPool_Append
    @piUUID = null,
    @piGdGid = @vGdGid,
    @piVdrGid = @vVdrGid,
    @piWrh = @vWrhGid,
    @piCombineType = '',
    @piSendDate = @vToday,
    @piQty = @piOrdQty,
    @piPrice = @piOrdPrice,
    @piOrderType = @vOrderType,
    @piImpTime = @vPresent,
    @piImporter = @vOper,
    @piOrderDate = @vToday,
    @piSplitDays = 0,
    @piNote = null,
    @piRoundType = '不变',
    @piStoreOrdApplyType = @vStoreOrdApplyType,
    @piStoreOrdApplyStat = @vStoreOrdApplyStat,
    @poErrMsg = @poErrMsg output

  if @return_status <> 0
    return @return_status

  return 0
end
GO
