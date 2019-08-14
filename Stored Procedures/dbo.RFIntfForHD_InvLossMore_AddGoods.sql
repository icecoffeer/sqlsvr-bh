SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvLossMore_AddGoods](
  @piRFNo varchar(20),
  @piTypeName varchar(20),
  @piWrhCode varchar(10),
  @piGdCode varchar(40),
  @piBarCode varchar(40),
  @piQty decimal(24,4),
  @piFillerCode varchar(10),
  @piCause varchar(40),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @Type int

  if rtrim(@piTypeName) not in ('损耗', '溢余')
  begin
    set @poErrMsg = '未定义的单据类型：' + rtrim(@piTypeName)
    return 1
  end

  if rtrim(@piTypeName) = '损耗'
    set @Type = 1
  else
    set @Type = 2

  insert into RFGOODSPOOL(UUID, STORECODE, RFNO,
    TYPE, TYPENAME, WRHCODE, GDCODE, BARCODE,
    QTY, FILLERCODE, FILDATE, LSTUPDTIME, SUBTIME,
    CAUSE)
    select newid(), USERCODE, @piRFNo,
    @Type, @piTypeName, @piWrhCode, @piGdCode, @piBarCode,
    @piQty, @piFillerCode, getdate(), getdate(), getdate(),
    @piCause
    from SYSTEM(nolock)

  return 0
end
GO
