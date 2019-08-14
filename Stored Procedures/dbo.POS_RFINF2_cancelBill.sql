SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_cancelBill]
(
	@piRFNum		varchar(10),	/*输入：RF交易序列号*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vRowCount int,@vRFNum varchar(10),@vReccnt int
	Select @vRet = 0, @vReccnt = RECCNT from RFBILLPOOL where RFNUM = @piRFNum
	if @@ROWCOUNT = 0 Return(0)
	else if @vReccnt = 0
		Select @vRet = 1, @poErrMsg = '删除RFBILLPOOL失败'
	begin tran
	if @vRet = 0
	begin
		--尝试删除RFBILLPOOL
		delete from RFBILLPOOL where RFNUM = @piRFNum
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '删除RFBILLPOOL出错'
		else if @vRowCount = 0
			Select @vRet = 1, @poErrMsg = '删除RFBILLPOOL失败'
	end
	if @vRet = 0
	begin
		--尝试删除RFBILLDTLPOOL
		delete from RFBILLDTLPOOL where RFNUM = @piRFNum
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '删除RFBILLPOOL出错'
		else if @vRowCount <> @vReccnt
			Select @vRet = 1, @poErrMsg = '删除RFBILLPOOL失败'
	end
	if @vRet = 0
		commit
	else
		rollback
	Return(@vRet)
end
GO
