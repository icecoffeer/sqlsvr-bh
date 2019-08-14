SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_check_Operator]
(
	@piOperator		varchar(10),		/*输入：RF操作员代码*/
	@piPassword		varchar(64),		/*输入：RF操作员密码*/
	@poEmpGid		integer output,		/*输出：RF操作员GID*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @EmpPwd varchar(32), @pwd varchar(32)
	Select @poEmpGid = Gid,@EmpPwd = Password from Employee(nolock)
	 where Code = @piOperator
	if @@RowCount = 0
	begin
		Select @poErrMsg = '找不到员工代码' + @piOperator
		Return(1)
	end
	Select @pwd = @piPassword
	exec POS_RFINF_LockPassword @pwd output
	if @EmpPwd <> @pwd
	begin
		Select @poErrMsg = '密码不对'
		Return(1)
	end
	Return(0)
end
GO
