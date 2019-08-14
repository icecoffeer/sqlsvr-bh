SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetVendor](
  @poErrMsg varchar(255) output
)
as
begin
  select rtrim(CODE) 供应商代码, rtrim(NAME) 供应商名称
    from VENDOR(nolock)
    order by CODE
  return 0
end
GO
