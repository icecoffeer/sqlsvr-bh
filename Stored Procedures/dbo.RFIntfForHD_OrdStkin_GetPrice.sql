SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_OrdStkin_GetPrice](
  @piOrdNum varchar(10),        --传入参数：定货单号。
  @piVdrGid int,                --传入参数：供应商GID。
  @piGdGid int,                 --传入参数：商品GID。
  @poPrice decimal(24,4) output --传出参数（返回值为0时有效）：收货单价。
)
as
begin
  declare
    @return_status int,
    @UserGid int,
    @ZBGid int,
    @InModuleNo int,
    @optNewInUseDefaultPrc int,
    @optImportBillIsUseDefPrc int,
    @optPriceType int,
    @optLessRtlPrc int,
    @optChkOption varchar(255),
    @optTopPrcType int,
    @optLowPrcType int,
    @optPrcHighLmt decimal(24,4), --单价上限系数
    @optPrcLowLmt decimal(24,4),  --单价下限系数
    @DefPrc decimal(24,4),
    @PrmInPrc decimal(24,4),
    @OrdPrc decimal(24,4),
    @RtlPrc decimal(24,4),
    @TopPrcBase decimal(24,4),    --单价上限基数
    @LowPrcBase decimal(24,4),    --单价下限基数
    @TopPrc decimal(24,4),
    @LowPrc decimal(24,4)

  --读取系统设定。
  select @UserGid = USERGID, @ZBGid = ZBGID from SYSTEM(nolock)

  --获取进货单明细模块的编号。RF收货操作区分总部和门店：总部收货，产生自营进货单；门店收货，产生直配进货单。
  if @UserGid = @ZBGid
    set @InModuleNo = 52 --自营进明细
  else
    set @InModuleNo = 84 --直配进明细

  --读取选项。
  exec OptReadInt 0, 'NewInUseDefaultPrc', 0, @optNewInUseDefaultPrc output
  exec OptReadInt 0, 'PS3_IMPORTBILLISUSEDEFPRC', 0, @optImportBillIsUseDefPrc output
  exec OptReadInt @InModuleNo, 'PriceType', 0, @optPriceType output
  exec OptReadInt @InModuleNo, 'LessRtlPrc', 0, @optLessRtlPrc output
  exec OptReadStr @InModuleNo, 'ChkOption', '110000000000000000', @optChkOption output
  exec OptReadInt @InModuleNo, 'TopPrcType', 0, @optTopPrcType output
  exec OptReadInt @InModuleNo, 'LowPrcType', 0, @optLowPrcType output
  exec OptReadStr @InModuleNo, 'PrcHighLmt', '0', @optPrcHighLmt output
  exec OptReadStr @InModuleNo, 'PrcLowLmt', '0', @optPrcLowLmt output

  --初始化传出参数的值。
  set @poPrice = null

  --获取系统默认价，取不到则为Null。
  exec GetGoodsStkInDefPrc @optPriceType, @piVdrGid, @piGdgid, @DefPrc output

  --获取促销进价，取不到则为Null。
  exec @return_status = GetGoodsPrmStkInPrc @piVdrGid, @UserGid, @piGdgid, @PrmInPrc output
  if @return_status <> 0 and @PrmInPrc is not null
    set @PrmInPrc = null

  --定货价（暂只考虑非赠品），取不到则为Null。
  select @OrdPrc = max(PRICE)
    from ORDDTL(nolock)
    where NUM = @piOrdNum
    and GDGID = @piGdGid

  --根据选项，从系统默认价、促销进价及定货价中选出一种，作为进货价。
  if @optImportBillIsUseDefPrc = 0 --系统默认价。
  begin
    if @optNewInUseDefaultPrc = 1 --系统默认价与促销进价中的较小者，取不到则取定货价。
    begin
      set @poPrice = @DefPrc
      if @poPrice is null or @PrmInPrc < @poPrice
        set @poPrice = @PrmInPrc
      if @poPrice is null
        set @poPrice = @OrdPrc
    end
    else begin --定货价。
      set @poPrice = @OrdPrc
    end
  end
  else if @optImportBillIsUseDefPrc = 1 --系统默认价、促销进价及定货价中的较小者。
  begin
    set @poPrice = @DefPrc
    if @poPrice is null or @PrmInPrc < @poPrice
      set @poPrice = @PrmInPrc
    if @poPrice is null or @OrdPrc < @poPrice
      set @poPrice = @OrdPrc
  end
  else begin --定货价。
    set @poPrice = @OrdPrc
  end

  --与核算售价作比较。
  if @optLessRtlPrc = 1
  begin
    select @RtlPrc = RTLPRC from GOODS(nolock) where GID = @piGdGid
    if @poPrice > @RtlPrc
      set @poPrice = @RtlPrc
  end

  --与单价上下限作比较。
  if substring(@optChkOption, 6/*单价上下限*/, 1) = '1'
  begin
    --获取单价上限的基数，取不到则为Null。
    exec GetGoodsStkInDefPrc @optTopPrcType, @piVdrGid, @piGdgid, @TopPrcBase output
    --单价上限。
    set @TopPrc = isnull(@TopPrcBase/*基数*/ * @optPrcHighLmt/*系数*/, 0)
    --与单价上限作比较。
    if @TopPrc <> 0 and @poPrice > @TopPrc
      set @poPrice = @TopPrc

    --获取单价下限的基数，取不到则为Null。
    exec GetGoodsStkInDefPrc @optLowPrcType, @piVdrGid, @piGdgid, @LowPrcBase output
    --单价下限。
    set @LowPrc = isnull(@LowPrcBase/*基数*/ * @optPrcLowLmt/*系数*/, 0)
    --与单价下限作比较。
    if @LowPrc <> 0 and @poPrice < @LowPrc
      set @poPrice = @LowPrc
  end

  return 0
end
GO
