SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_pause_Bill]
(
	@piRFNum	varchar(10),		/*输入：RF交易序列号*/
	@piOperator	integer,			/*输入：操作人GID*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vStat int
	begin tran
	Select @vStat = Stat from RFBILL(updlock) where RFNUM = @piRFNum
	if @@RowCount = 0
	begin
		Select @poErrMsg = '找不到RF交易' + @piRFNum
		Return(1)
	end
	if @vStat = 3
	begin
		commit tran
		Return(0)
	end
	else if @vStat <> 0
	begin
		commit tran
		Select @poErrMsg = 'RF交易状态(' + convert(varchar(2), @vStat)
					+ ')不是待付款(0)'
		Return(1)
	end
	Update RFBILL Set Stat = 3 where RFNUM = @piRFNum
	exec POS_RFINF_add_BillLog @piRFNum, @piOperator, '暂停RF交易'
	commit tran
	Return(0)
end
GO
