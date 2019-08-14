SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_Employee](
  @poErrMsg varchar(255) output
)
as
begin
  select
    GID,
    rtrim(CODE) CODE,
    rtrim(NAME) NAME,
    rtrim(PASSWORD) PASSWORD
    from EMPLOYEE(nolock)
    order by GID
  return 0
end
GO
