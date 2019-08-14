SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alloc_AddGoods](
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @piPDANum varchar(40),        --传入参数：手持设备编号。
  @piClientCode varchar(10),    --传入参数：配往单位代码，对应于STORE.CODE。
  @piWrhCode varchar(10),       --传入参数：仓位代码，对应于WAREHOUSE.CODE。
  @piGdCode varchar(13),        --传入参数：商品代码（GOODS.CODE）。
  @piQty decimal(24,4),         --传入参数：配货单品数量。
  @piPrice decimal(24,4),       --传入参数：配货单价。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @return_status int,
    @UUID varchar(38)

  --检查传入参数：配往单位、仓位和货品代码。
  exec @return_status = RFIntfForHD_Alloc_ChkGoods @piEmpCode, @piClientCode,
    @piWrhCode, @piGdCode, @poErrMsg output
  if @return_status <> 0
    return 1

  --插入RFALLOC的值限定为GOODS.CODE，以后读取该值时就无需再做解析。
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
  insert into RFALLOC(UUID, OPERATORCODE, OPERATIONTIME, PDANUM, CLIENTCODE,
    WRHCODE, GDCODE, QTY, PRICE)
    select @UUID, @piEmpCode, getdate(), @piPDANum, @piClientCode,
    @piWrhCode, @piGdCode, @piQty, @piPrice

  return 0
end
GO
