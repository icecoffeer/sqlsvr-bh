SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_Sort](
  @poErrMsg varchar(255) output
)
as
begin
  select rtrim(CODE) CODE, rtrim(NAME) NAME from SORT(nolock)
    order by CODE
  return 0
end
GO
