SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_query_Bill]
(
	@piRFNum	varchar(10),		/*输入：RF交易序列号*/
	@poOperator	integer output,		/*输出：RF操作员GID*/
	@poFildate	datetime output,	/*输出：RF交易开始时间*/
	@poRecCnt	integer output,		/*输出：RF交易明细数*/
	@poTotal	decimal(24,2) output,/*输出：RF交易金额合计*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vStat int
	Select @poOperator = Filler, @poFildate = Fildate, @poRecCnt = RecCnt, @poTotal = Total, @vStat = Stat
	  from RFBILL(nolock) where RFNUM = @piRFNum
	if @@RowCount = 0
	begin
		Select @poErrMsg = '不存在RF交易(RFNUM=' + @piRFNum + ')'
		Return(1)
	end
	if @vStat = 1
	begin
		Select @poErrMsg = 'RF交易(RFNUM=' + @piRFNum + ')已取消'
		Return(1)
	end
	else if @vStat <> 0
	begin
		Select @poErrMsg = 'RF交易(RFNUM=' + @piRFNum + ')不是待付款状态'
		Return(1)
	end
	Return(0)
end
GO
