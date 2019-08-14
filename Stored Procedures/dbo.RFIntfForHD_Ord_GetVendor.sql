SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GetVendor](
  @piEmpCode varchar(10),
  @piType int, --1：定货，2：叫货申请，位与操作
  @piWrhCode varchar(10),
  @piArticleCode varchar(40),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vWrhGid int,
    @vGdGid int,
    @vBarCodeQty decimal(24,4),
    @vBarCodeAmt decimal(24,2)

  --检查传入参数：调用者类型。

  if not @piType in (1, 2)
  begin
    set @poErrMsg = '@piType无效。'
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

  --搜索供应商。

  exec @return_status = RFIntfForHD_Ord_SearchVendor @piType, @vWrhGid, @vGdGid,
    @poErrMsg output
  if @return_status <> 0
    return @return_status

  --返回搜索到的供应商的数据集。

  select distinct v.VDRCODE 代码, v.VDRNAME 名称
   from TMPRFORDVDR v(nolock)
    where v.SPID = @@spid

  return 0
end
GO
