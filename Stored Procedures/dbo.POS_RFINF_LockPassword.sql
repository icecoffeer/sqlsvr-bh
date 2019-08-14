SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_LockPassword]
(
	@poPassword	varchar(32) output
)
with encryption as
begin
	declare @vi int,@vj int,@vOdd smallint,@vn int,@vintLen int,@vPwd varchar(64)
	Select @vPwd = @poPassword
	if @vPwd = '' or @vPwd is null
		Select @vPwd = '###############################'
	while len(@vPwd) <= 30
		Select @vPwd = @vPwd + '$' + @vPwd
	Select @vintLen = len(@vPwd), @vi = 1, @vOdd = 1
	while @vi <= @vintLen - 30
	begin
		Select @vj = 1
		while @vj <= @vintLen - @vi
		begin
			if @vOdd = 1
				Select @vn = (ASCII(SubString(@vPwd, @vj, 1)) + ASCII(SubString(@vPwd, @vj + 1, 1))) * 2 + 1
			else
				Select @vn = ABS(ASCII(SubString(@vPwd, @vj, 1)) - ASCII(SubString(@vPwd, @vj + 1, 1))) * 2 + 1
			Select @vn = @vn - floor(@vn / 95.0) * 95 + 32
			Select @vPwd = SubString(@vPwd, 1, @vj - 1) + char(@vn)
				+ SubString(@vPwd, @vj + 1, @vintLen)
			Select @vj = @vj + 1
		end
		Select @vi = @vi + 1, @vOdd = 1 - @vOdd
	end
	Select @poPassword = LTrim(RTrim((SubString(@vPwd, 1, 30))))
end
GO
