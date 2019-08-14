SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_Clear](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vEmpGid int
  select @vEmpGid = GID from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  delete from RFPCK where FILLER = @vEmpGid
  return 0
end
GO
