SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_AllocByStkOut_GetGoods](
  @piEmpCode varchar(10),            --传入参数：操作员代码。
  @piStkOutNum varchar(10),          --传入参数：配出单号。
  @piInputGdCode varchar(40),        --传入参数：货品码（代码、输入码）。
  @poGdCode varchar(13) output,      --传出参数（返回值为0时有效）：货品代码（GOODS.CODE）。
  @poGdName varchar(50) output,      --传出参数（返回值为0时有效）：货品名称（GOODS.NAME）。
  @poGdQpc decimal(24,4) output,     --传出参数（返回值为0时有效）：货品包装规格（GOODS.QPC）。
  @poGdMUnit varchar(6) output,      --传出参数（返回值为0时有效）：货品计量单位（GOODS.MUNIT）。
  @poStkOutQty decimal(24,4) output, --传出参数（返回值为0时有效）：货品在配出单中的单品数量（STKOUTDTL.QTY）合计。
  @poAllocQty decimal(24,4) output,  --传出参数（返回值为0时有效）：经由指定操作员配出的指定货品的数量之合计。
  @poPrice decimal(24,4) output,     --传出参数（返回值为0时有效）：货品在配出单中的单品单价（STKOUTDTL.PRICE）。
  @poErrMsg varchar(255) output      --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @return_status int,
    @GdGid int

  --检查货品的合法性。
  exec @return_status = RFIntfForHD_AllocByStkOut_ChkGoods @piStkOutNum,
    @piInputGdCode, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取货品信息。
  select
    @GdGid = g.GID,
    @poGdCode = rtrim(g.CODE),
    @poGdName = rtrim(g.NAME),
    @poGdQpc = g.QPC,
    @poGdMUnit = rtrim(g.MUNIT)
    from GDINPUT gi(nolock)
      inner join GOODS g(nolock) on g.GID = gi.GID
    where gi.CODE = @piInputGdCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '货品码' + rtrim(@piInputGdCode) + '不在商品表中。'
    return 1
  end

  --获取配货数量及配货单价。
  select @poStkOutQty = isnull(sum(d.QTY), 0),
    @poPrice = isnull(min(PRICE), 0)
    from STKOUTDTL d(nolock)
    where d.CLS = '配货'
    and d.NUM = @piStkOutNum
    and d.GDGID = @GdGid

  --获取历史配货数量合计
  select @poAllocQty = isnull(sum(QTY), 0)
    from RFALLOCBYSTKOUT(nolock)
    where OPERATORCODE = @piEmpCode
    and STKOUTNUM = @piStkOutNum
    and GDCODE = @poGdCode

  return 0
end
GO
