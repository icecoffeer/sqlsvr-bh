SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_ApplyRFNum]
(
	@poRFNum	varchar(10) output,	/*输出：RF序列号*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @RFNum varchar(20),@datePrefix varchar(4)
	declare @vi int,@vN int,@vM int,@vCD varchar(2)
	Select @datePrefix = convert(varchar(4),convert(integer, getdate()-convert(char(10),installdate,102))) from System(nolock)
	Select @RFNum = RFNum from RFNum(nolock)
	if @@RowCount = 0
		Insert into RFNum(RFNum) values(@datePrefix + '000')
	begin tran
	Select @RFNum = RFNum from RFNum(updlock)
	if SubString(@RFNum, 1, 4) <> @datePrefix
		Select @RFNum = @datePrefix + '001'
	else
	begin
		Select @RFNum = convert(char(7),convert(integer, SubString(@RFNum, 1, 7)) + 1)
	end
	Select @vi = Len(@RFNum), @vN = 0, @vM = 3
	while @vi > 0
	begin
		Select @vN = @vN + @vM * convert(integer, SubString(@RFNum, @vi, 1))
		Select @vM = @vM * 10
		Select @vM = @vM - floor(@vM / 97.0) * 97
		Select @vi = @vi - 1
	end
	Select @vCD = 98 - @vN + floor(@vN / 97.0) * 97
	if Len(@vCD) = 1
		Select @vCD = '0' + @vCD
	Select @RFNum = @RFNum + @vCD
	Update RFNum Set RFNum = @RFNum
	commit tran
	Select @poRFNum = @RFNum
	Return(0)
end
GO
