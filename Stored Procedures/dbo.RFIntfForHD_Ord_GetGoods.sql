SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GetGoods](
  @piEmpCode varchar(10),
  @piType int, --1：定货，2：叫货申请
  @piWrhCode varchar(10),
  @piArticleCode varchar(40),
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
  @poPrice decimal(24,4) output,
  @poVdrCode varchar(10) output,
  @poVdrName varchar(100) output,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vUserGid int,
    @vEmpGid int,
    @vWrhGid int,
    @vBillTo int,
    @vIsLtd int,
    @vNegN int,
    @vToday datetime,
    @vSingleVdr int,
    @vBarCodeQty decimal(24,4),
    @vBarCodeAmt decimal(24,2),
    @optOrdOrdTP int

  --检查传入参数：调用者类型。

  if not @piType in (1, 2)
  begin
    set @poErrMsg = '@piType无效。'
    return 1
  end

  --获取一般变量的值。

  set @vToday = convert(datetime, convert(varchar, getdate(), 102))

  --获取系统变量。

  select @vUserGid = USERGID from SYSTEM(nolock)

  --获取员工GID。

  select @vEmpGid = GID
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '员工代码' + rtrim(@piEmpCode) + '无效。'
    return 1
  end

  --获取商品GID。

  exec @return_status = RFIntfForHD_GetGoods
    @piArticleCode, @poGdGid output, @vBarCodeQty output, @vBarCodeAmt output, @poErrMsg output
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
      set @poErrMsg = '仓位代码' + rtrim(@piWrhCode) + '无效。'
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

  --获取一般商品信息。

  select @poGdCode = g.CODE,
    @poNameSpec = rtrim(isnull(g.NAME, '')) + '[' + rtrim(isnull(g.SPEC, '')) + ']',
    @poMUnit = g.MUNIT,
    @poQpc = g.QPC,
    @poSort = rtrim(isnull(s.NAME, '')) + '[' + rtrim(g.SORT) + ']',
    @poBrand = rtrim(isnull(b.NAME, '')) + '[' + rtrim(g.BRAND) + ']',
    @poAlc = g.ALC,
    @poLowInv = g.LOWINV,
    @poHighInv = g.HIGHINV,
    @vBillTo = g.BILLTO,
    @vIsLtd = g.ISLTD
    from GOODS g(nolock)
    left join SORT s(nolock) on g.SORT = s.CODE
    left join BRAND b(nolock) on g.BRAND = b.CODE
    where g.GID = @poGdGid

  --一些检查。

  --统配商品是否可以定货，选项控制。

  exec OptReadInt 8146, 'OrdOrdTP', 0, @optOrdOrdTP output
  if @optOrdOrdTP = 0 and rtrim(@poAlc) = '统配' and @piType = 1
  begin
    set @poErrMsg = '商品的配货方式为统配，不允许定货。'
    return 1
  end

  --限制业务的判断。

  if @vIsLtd & 1 = 1
  begin
    if rtrim(@poAlc) = '统配'
    begin
      set @poErrMsg = '商品为统配商品，且为限制配货商品，不允许定货。'
      return 1
    end
  end
  else if @vIsLtd & 2 = 2
  begin
    set @poErrMsg = '商品为限制定货商品，不允许定货。'
    return 1
  end
  else if @vIsLtd & 4 = 4
  begin
    set @poErrMsg = '商品为限制销售商品，不允许定货。'
    return 1
  end

  --过去N天，过去N天总销量，过去N天平均销量。

  exec OptReadInt 8146, 'OrdN', 30, @poN output
  if @poN > 0
  begin
    set @vNegN = -1 * @poN
    select @poNSumSaleQty = isnull(sum(DQ1 - DQ5 + DQ2 - DQ6), 0)
      from OUTDRPT(nolock)
      where ADATE >= dateadd(day, @vNegN, @vToday)
        and ADATE <= dateadd(day, -1, @vToday)
        and BGDGID = @poGdGid
        and BWRH = @vWrhGid
        and ASTORE = @vUserGid
    set @poNAvgSaleQty = @poNSumSaleQty / @poN
  end
  else begin
    set @poN = 0
    set @poNSumSaleQty = 0
    set @poNAvgSaleQty = 0
  end

  --库存数，在单量。

  select @poInvQty = isnull(sum(QTY), 0),
    @poOrdQty = isnull(sum(ORDQTY), 0)
    from INV(nolock)
    where WRH = @vWrhGid
    and GDGID = @poGdGid
    and STORE = @vUserGid

  --建议叫货数。

  set @poSuggestQty = isnull(@poHighInv, 0) - @poInvQty - @poOrdQty
  if @poSuggestQty < 0
  begin
    set @poSuggestQty = 0
  end

  --单价。

  exec GetGoodsOrderPrc @poGdGid, @vBillTo, @poPrice output

  --如果候选供应商只有一个，则返回之，否则返回Null。

  exec @return_status = RFIntfForHD_Ord_SearchVendor @piType, @vWrhGid, @poGdGid,
    @poErrMsg output
  if @return_status <> 0
    return @return_status

  if (select count(*) from TMPRFORDVDR(nolock)
    where SPID = @@spid) = 1
  begin
    select @poVdrCode = rtrim(VDRCODE), @poVdrName = rtrim(VDRNAME)
      from TMPRFORDVDR(nolock)
      where SPID = @@spid
  end

  if @poVdrCode is null
    set @poVdrCode = ''
  if @poVdrName is null
    set @poVdrName = ''

  return 0
end
GO
