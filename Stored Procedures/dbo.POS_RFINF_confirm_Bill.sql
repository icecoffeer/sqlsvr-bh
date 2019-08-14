SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_confirm_Bill]
(
	@piRFNum	varchar(10),		/*输入：RF交易序列号*/
	@piOperator	integer,			/*输入：操作人GID*/
	@piPosNo	varchar(10),		/*输入：POS机号*/
	@piFlowno	varchar(12),		/*输入：POS机流水号*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vStat int,@vNote varchar(200)
	begin tran
	Select @vStat = Stat from RFBILL(updlock) where RFNUM = @piRFNum
	if @@RowCount = 0
	begin
		Select @poErrMsg = '找不到RF交易' + @piRFNum
		Return(1)
	end
	Select @vNote = '确认RF交易, POSNO=' + @piPosNo + ', FLOWNO=' + @piFlowno
	if @vStat = 2
	begin
		Select @vRet = Count(*) from RFBILLLOG(nolock)
		 where RFNUM = @piRFNum and Note = @vNote
		if @vRet > 0
		begin
			commit tran
			Return(1)
		end
	end
	else if @vStat <> 0
	begin
		commit tran
		Select @poErrMsg = 'RF交易状态(' + convert(varchar(2), @vStat)
					+ ')不是待付款(0)'
		Return(1)
	end
	Update RFBILL Set Stat = 2 where RFNUM = @piRFNum
	exec POS_RFINF_add_BillLog @piRFNum, @piOperator, @vNote
	commit tran
	Return(0)
end
GO
