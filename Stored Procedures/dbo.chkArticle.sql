SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[chkArticle]
(
  @piOrdNum varchar(10),               --传入参数：定货单单号。
  @piInputGdCode varchar(40),          --传入参数：商品条码（输入码）。
  @poNameSpec varchar(100) output,     --传出参数（返回值为0时有效）：商品名称规格。
  @poQpc decimal(24,4) output,         --传出参数（返回值为0时有效）：商品包装规格。
  @poMUnit varchar(6) output,          --传出参数（返回值为0时有效）：商品计量单位。
  @poOrdQtyStr varchar(100) output,    --传出参数（返回值为0时有效）：商品定货件数(件数格式：A+B或A.B，A表示箱数，B表示总数中除去A箱外的散件数)。
  @poArvQtyStr varchar(100) output,    --传出参数（返回值为0时有效）：商品到货件数(件数格式：同上)。
  @poNotArvQtyStr varchar(100) output, --传出参数（返回值为0时有效）：商品未到货件数(件数格式：同上)。
  @poPrice decimal(24,4) output,       --传出参数（返回值为0时有效）：商品收货单价。
  @poErrMsg varchar(255) output        --传出参数（返回值为0时有效）：错误信息。
) as
begin
  declare
    @return_status int,        --返回值
    @GdCode varchar(13),       --商品代码
    @GdGid int,                --商品GID，取值：原商品是大包装商品 ? 基本商品GID : 原商品GID。
    @Vendor int,               --供应商
    @OrdQty decimal(24,4),     --定货单定货数(ORDDTL.QTY)
    @OrdArvQty decimal(24,4),  --定货单到货数(ORDDTL.ARVQTY)
    @ReceiptQty decimal(24,4), --收货单收货数
    @ArvQty decimal(24,4),     --到货数(定货单到货数 + 收货单收货数)
    @NotArvQty decimal(24,4)   --未到货数(定货单定货数 - 定货单到货数 - 收货单收货数)

  --检查定货单号的合法性，并查询定货单信息。
  select @Vendor = VENDOR from ORD(nolock) where NUM = @piOrdNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '定单号 ' + rtrim(isnull(@piOrdNum, '')) + ' 无效。'
    return 1
  end

  --获取商品GID。如果商品是大包装商品，将其转换为基本商品，并返回基本商品代码、GID；否则，返回原商品代码、GID。
  exec @return_status = PkgToBasicInput @piInputGdCode, @GdCode output, @GdGid output, @poErrMsg output
  if @return_status <> 0
  begin
    return(1)
  end

  --检查商品合法性。
  if not exists(select * from ORDDTL d(nolock) where d.NUM = @piOrdNum and d.GDGID = @GdGid)
  begin
    set @poErrMsg = @piOrdNum + ' 号定单中没有条码为 ' + @piInputGdCode + ' 的商品。'
    return(1)
  end

  --获取商品信息。
  select
    @poNameSpec = rtrim(g.NAME) + '[' + rtrim(isnull(g.SPEC, '')) + ']',
    @poQpc = g.QPC,
    @poMUnit = rtrim(g.MUNIT)
    from GOODS g(nolock)
    where g.GID = @GdGid

  --获取商品的定货单定货数、定货单到货数。
  select
    @OrdQty = sum(d.QTY),
    @OrdArvQty = sum(isnull(d.ARVQTY, 0))
    from ORDDTL d(nolock)
    where d.NUM = @piOrdNum
    and d.GDGID = @GdGid

  --获取收货单收货数。
  select @ReceiptQty = isnull(sum(d.GDQTY), 0)
    from GOODSRECEIPTDTL d(nolock), GOODSRECEIPT m(nolock)
    where m.NUM = d.NUM
    and m.SRCORDNUM = @piOrdNum
    and m.STAT in (0, 100)
    and d.GDGID = @GdGid

  --计算商品到货数（定货单到货数 + 收货单收货数）。
  set @ArvQty = @OrdArvQty + @ReceiptQty
  if @ArvQty < 0
    set @ArvQty = 0

  --计算商品的未到货数。
  set @NotArvQty = @OrdQty - @ArvQty

  --计算商品的收货单价。
  exec RFIntfForHD_OrdStkin_GetPrice @piOrdNum, @Vendor, @GdGid, @poPrice output

  --将数量转换为件数。
  set @poOrdQtyStr = DBO.QtyToStr(@OrdQty, @poQpc)
  set @poArvQtyStr = DBO.QtyToStr(@ArvQty, @poQpc)
  set @poNotArvQtyStr = DBO.QtyToStr(@NotArvQty, @poQpc)

  return(0)
end
GO
