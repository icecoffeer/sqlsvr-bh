SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_AllocByStkOut_ChkGoods](
  @piStkOutNum varchar(10),     --传入参数：配出单号。
  @piInputGdCode varchar(40),   --传入参数：货品码（代码、输入码）。
  @poErrMsg varchar(255) output --传出参数：错误消息。返回值不为0时有效。
)
as
begin
  declare
    @GdGid int

  --检查传入参数。
  if @piStkOutNum is null or rtrim(@piStkOutNum) = ''
  begin
    set @poErrMsg = '配出单号不能为空。'
    return 1
  end
  if @piInputGdCode is null or rtrim(@piInputGdCode) = ''
  begin
    set @poErrMsg = '货品码不能为空。'
    return 1
  end

  --检查货品码是否在商品表中。
  select @GdGid = gi.GID from GDINPUT gi(nolock) where gi.CODE = @piInputGdCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '货品码' + rtrim(@piInputGdCode) + '不在商品表中。'
    return 1
  end

  --检查货品是否在配出单明细中。
  if not exists(select 1 from STKOUTDTL(nolock)
    where CLS = '配货'
    and NUM = @piStkOutNum
    and GDGID = @GdGid)
  begin
    set @poErrMsg = '货品码' + rtrim(@piInputGdCode) + '不在配出单' + rtrim(@piStkOutNum) + '中。'
    return 1
  end

  return 0
end
GO
