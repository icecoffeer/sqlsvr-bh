SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_ChkArticle](
  @piEmpCode varchar(10),              --登录员工号
  @piWrhCode varchar(10),              --仓位代码
  @piArticleCode varchar(40),          --货品代码
  @poArticleName varchar(50) output,   --货品名称
  @poSpec varchar(40) output,          --规格
  @poMUnit varchar(6) output,          --计量单位
  @poChkQtyStr varchar(50) output,     --已盘数（格式：整件数+零散数）
  @poBarCodeQty decimal(24,4) output,  --电子秤条码（数量、金额、数量金额、金额数量）中包含的数量信息
  @poBarCodeAmt decimal(24,2) output,  --电子秤条码（数量、金额、数量金额、金额数量）中包含的金额信息
  @poErrMsg varchar(255) output        --错误信息
)
as
begin
  declare
    @return_status int,
    @vEmpGid int,
    @vWrhGid int,
    @vArticleGid int,
    @vArticleName varchar(50),
    @vSpec varchar(40),
    @vMUnit varchar(6),
    @vGdQpc decimal(24,4),
    @vChkQty decimal(24,4)

  --获取员工GID

  select @vEmpGid = GID
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '员工代码' + rtrim(@piEmpCode) + '无效。'
    return 1
  end

  --获取仓位GID

  select @vWrhGid = GID
    from WAREHOUSE(nolock)
    where CODE = @piWrhCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '仓位代码' + rtrim(@piWrhCode) + '无效。'
    return 1
  end

  --获取货品GID

  exec @return_status = RFIntfForHD_GetGoods
    @piArticleCode, @vArticleGid output, @poBarCodeQty output, @poBarCodeAmt output, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取货品信息

  select @vArticleName = g.NAME,
    @vMUnit = g.MUNIT,
    @vGdQpc = g.QPC
    from GOODS g(nolock)
    where g.GID = @vArticleGid

  --规格

  set @vSpec = '1*' + convert(varchar, @vGdQpc)

  --货品已盘数量

  select @vChkQty = IsNull(sum(QTY), 0)
    from RFPCK(nolock)
    where FILLER = @vEmpGid
      and WRH = @vWrhGid
      and GDGID = @vArticleGid

  --返回值

  set @poArticleName = @vArticleName
  set @poSpec = @vSpec
  set @poMUnit = @vMUnit
  set @poChkQtyStr = dbo.QtyToStr(@vChkQty, @vGdQpc)
  return 0
end
GO
