SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GenBills](
  @piEmpCode varchar(10),
  @piType int, --1：定货，2：叫货申请，位与操作
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vEmpGid int

  --传入参数

  if @piType & 1 = 0 and @piType & 2 = 0
  begin
    set @poErrMsg = '@piType无效。'
    return 1
  end

  --员工信息

  select @vEmpGid = GID from EMPLOYEE(nolock)
    where CODE = @piEmpCode

  --生成单据

  exec @return_status = OrderPool_GenBill '', @vEmpGid, @piType, 'RF',
    @poErrMsg output

  return @return_status
end
GO
