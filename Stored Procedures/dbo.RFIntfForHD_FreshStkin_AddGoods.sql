SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_FreshStkin_AddGoods](
  @piEmpCode varchar(10),
  @piPDANum varchar(40),
  @piVdrCode varchar(10),
  @piWrhCode varchar(10),
  @piDeptCode varchar(10),
  @piTaxRateLmt decimal(24,4),
  @piNote varchar(255),
  @piGdCode varchar(13),
  @piQty decimal(24,4),
  @piPrice decimal(24,4),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @UUID varchar(38),
    @Opt_MstInputDept int,
    @Opt_MstInputTaxRateLmt int

  --读取选项的值。
  if exists(select 1 from SYSTEM(nolock) where USERGID = ZBGID)
  begin
    exec OPTREADINT 52, 'MstInputDept', 0, @Opt_MstInputDept output
    exec OPTREADINT 52, 'MstInputTaxRateLmt', 0, @Opt_MstInputTaxRateLmt output
  end
  else begin
    exec OPTREADINT 84, 'MstInputDept', 0, @Opt_MstInputDept output
    exec OPTREADINT 84, 'MstInputTaxRateLmt', 0, @Opt_MstInputTaxRateLmt output
  end

  --检查货品的合法性。
  set @return_status = 0
  if exists(select 1 from SYSTEM(nolock) where USERGID = ZBGID)
  begin
    exec @return_status = RFIntfForHD_FreshStkin_ChkGoods_Stkin @piVdrCode,
      @piWrhCode, @piDeptCode, @piTaxRateLmt, @piNote, @piGdCode,
      @poErrMsg output
  end
  else begin
    exec @return_status = RFIntfForHD_FreshStkin_ChkGoods_Dirin @piVdrCode,
      @piWrhCode, @piDeptCode, @piTaxRateLmt, @piNote, @piGdCode,
      @poErrMsg output
  end
  if @return_status <> 0
    return 1

  --插入RFFRESHSTKIN.GDCODE的值限定为GOODS.CODE，以后读取该值时就无需再做解析。
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
  if @Opt_MstInputDept = 0 and rtrim(isnull(@piDeptCode, '')) = ''
    set @piDeptCode = null
  if @Opt_MstInputTaxRateLmt = 0 and isnull(@piTaxRateLmt, 0) = 0
    set @piTaxRateLmt = null
  insert into RFFRESHSTKIN(UUID, OPERATORCODE, OPERATIONTIME, PDANUM, VDRCODE,
    WRHCODE, TAXRATELMT, DEPT, GDCODE, QTY,
    PRICE, NOTE)
    select @UUID, @piEmpCode, getdate(), @piPDANum, @piVdrCode,
    @piWrhCode, @piTaxRateLmt, @piDeptCode, @piGdCode, @piQty,
    @piPrice, @piNote

  return 0
end
GO
