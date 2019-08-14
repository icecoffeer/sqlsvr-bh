SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_queryNextUnappliedBill]
(
	@piOperator		integer,		/*输入：RF操作员GID*/
	@piPriorRFNum	varchar(10),/*输入：前一笔RF交易序列号，查第一个时传空字符串*/
	@poRFNum			varchar(10) output,	/*输出：查到的RF交易序列号*/
	@poFildate		datetime output,		/*输出：查到的RF交易开始时间*/
	@poRecCnt			integer output,			/*输出：查到的RF交易明细数*/
	@poErrMsg			varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vRowCount int
	if @piPriorRFNum is null or @piPriorRFNum = ''
		Select top 1 @poRFNum = RFNUM, @poFildate = FILDATE, @poRecCnt = RECCNT
			from RFBILLPOOL(nolock)
			where FILLER = @piOperator
			order by RFNUM
	else
		Select top 1 @poRFNum = RFNUM, @poFildate = FILDATE, @poRecCnt = RECCNT
			from RFBILLPOOL(nolock)
			where FILLER = @piOperator and RFNUM > @piPriorRFNum
			order by RFNUM
	Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
	if @vRet <> 0
		Select @poErrMsg = '查找RFBILLPOOL出错'
	else if @vRowCount = 0
		Select @vRet = 1, @poErrMsg = ''
	Return(@vRet)
end
GO
