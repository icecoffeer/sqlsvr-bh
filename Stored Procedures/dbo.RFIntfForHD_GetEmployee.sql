SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetEmployee](
  @poErrMsg varchar(255) output
)
as
begin
  select rtrim(CODE) 员工代码, rtrim(NAME) 员工名称
    from EMPLOYEE(nolock)
    order by CODE
  return 0
end
GO
