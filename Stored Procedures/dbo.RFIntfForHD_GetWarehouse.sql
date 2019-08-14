SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetWarehouse](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  select rtrim(CODE) 仓位代码, rtrim(NAME) 仓位名称
    from WAREHOUSE(nolock)
    order by CODE
  return 0
end
GO
