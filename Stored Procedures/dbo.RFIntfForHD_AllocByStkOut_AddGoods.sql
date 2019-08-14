SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_AllocByStkOut_AddGoods](
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @piPDANum varchar(40),        --传入参数：手持设备编号。
  @piStkOutNum varchar(10),     --传入参数：配出单号。
  @piGdCode varchar(13),        --传入参数：商品代码（GOODS.CODE）。
  @piQty decimal(24,4),         --传入参数：配货单品数量。
  @piPrice decimal(24,4),       --传入参数：配货单价。
  @poErrMsg varchar(255) output --传出参数：错误消息。返回值不为0时有效。
)
as
begin
  declare
    @return_status int,
    @UUID varchar(38)

  --检查货品的合法性。
  exec @return_status = RFIntfForHD_AllocByStkOut_ChkGoods @piStkOutNum,
    @piGdCode, @poErrMsg output
  if @return_status <> 0
    return 1

  --插入RFALLOCBYSTKOUT的值限定为GOODS.CODE，以后读取该值时就无需再做解析。
  if not exists(select 1 from GOODS(nolock) where CODE = @piGdCode)
  begin
    set @poErrMsg = '货品代码' + rtrim(@piGdCode) + '不是商品代码。'
    return 1
  end

  --检查传入参数合法性。
  if @piQty is null or @piQty = 0
  begin
    set @poErrMsg = '单品数不能为空或等于0。'
    return 1
  end
  if @piPrice is null or @piPrice < 0
  begin
    set @poErrMsg = '单价不能为空或小于0。'
    return 1
  end

  --提交记录
  exec HD_CREATEUUID @UUID output
  insert into RFALLOCBYSTKOUT(UUID, OPERATORCODE, OPERATIONTIME, PDANUM,
    STKOUTNUM, GDCODE, QTY, PRICE, FINISHTIME)
    select @UUID, @piEmpCode, getdate(), @piPDANum,
    @piStkOutNum, @piGdCode, @piQty, @piPrice, null

  return 0
end
GO
