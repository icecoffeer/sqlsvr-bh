SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetGoods](
  @piBarCode varchar(40),       --条码
  @poGdGid int output,          --商品内码
  @poQty decimal(24,4) output,  --条码中包含的数量信息。如果条码中没有包含该种信息，则返回0。
  @poAmt decimal(24,2) output,  --条码中包含的金额信息。如果条码中没有包含该种信息，则返回0。
  @poErrMsg varchar(255) output --错误信息
)
as
begin
  declare @return_status int

  --判断是否普通条码，不是则继续其他判断

  set @return_status = 1
  set @poGdGid = 0
  set @poQty = 0.0
  set @poAmt = 0.0
  exec @return_status = RFIntfForHD_GetGoods_General
    @piBarCode, @poGdGid output, @poErrMsg output
  if @return_status = 0 and @poGdGid > 0
    return 0

  --判断是否电子秤条码，不是则继续其他判断

  set @return_status = 1
  set @poGdGid = 0
  set @poQty = 0.0
  set @poAmt = 0.0
  exec @return_status = RFIntfForHD_GetGoods_AmtQty
    @piBarCode, @poGdGid output, @poQty output, @poAmt output, @poErrMsg output
  if @return_status = 0 and @poGdGid > 0
    return 0

  --否则，为无效条码

  set @poErrMsg = '该商品条码无效'
  return 1
end
GO
