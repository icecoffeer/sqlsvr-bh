SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetVendorName](
  @piVdrCode varchar(10),
  @poVdrName varchar(100) output,
  @poErrMsg varchar(255) output
)
as
begin
  select @poVdrName = rtrim(NAME) from VENDOR(nolock)
    where CODE = @piVdrCode

  if @@rowcount = 0
  begin
    set @poErrMsg = '供应商代码 ' + rtrim(@piVdrCode) + ' 在数据库中不存在。'
    return 1
  end

  return 0
end
GO
