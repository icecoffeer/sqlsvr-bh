SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetDept](
  @poErrMsg varchar(255) output
)
as
begin
  select rtrim(CODE) 部门代码, rtrim(NAME) 部门名称
    from DEPT(nolock)
    order by CODE
  return 0
end
GO
