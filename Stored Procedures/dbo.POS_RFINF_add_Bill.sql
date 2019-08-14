SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_add_Bill]
(
	@piRFNum	varchar(10),		/*输入：RF交易序列号*/
	@piOperator	integer,			/*输入：RF操作员GID*/
	@piFildate	datetime,			/*输入：RF交易开始时间*/
	@piRecCnt	integer,			/*输入：RF交易明细数*/
	@piTotal	decimal(24,2),		/*输入：RF交易金额合计*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	insert into RFBILL(RFNUM,STAT,FILLER,FILDATE,RECCNT,TOTAL)
		values(@piRFNum,0,@piOperator,@piFildate,@piRecCnt,@piTotal)
end
GO
