SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_LogIn_VerifyStore](
  @piStoreCode char(10),
  @poErrMsg varchar(255) output
)
as
begin
  if not exists(select * from STORE(nolock) where CODE = @piStoreCode)
  begin
    set @poErrMsg = '门店代码' + rtrim(@piStoreCode) + '在数据库中不存在。'
    return 1
  end

  set @poErrMsg = ''
  return 0
end
GO
