SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_add_BillDtl]
(
	@piRFNum	varchar(10),		/*输入：RF交易序列号*/
	@piItemNo	integer,			/*输入：RF交易明细编号*/
	@piBarCode	varchar(30),		/*输入：商品条码*/
	@piQuantity	decimal(24,4),		/*输入：商品数量*/
	@piPrice	decimal(24,4),		/*输入：商品单价*/
	@piAmount	decimal(24,2),		/*输入：商品金额*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vGid int,@vCode varchar(13),@vCodeType int,@vQty decimal(24,4),@vAmt decimal(24,2)
	exec @vRet = POS_RFINF_AnalyzeBarCode @piBarCode,@vGid output,@vCode output,
		@vCodeType output,@vQty output,@vAmt output,@poErrMsg output
	if @vRet <> 0 Return(@vRet)
	insert into RFBILLDTL(RFNUM,ITEMNO,BARCODE,CODETYPE,GID,QTY,PRICE,AMOUNT)
		values(@piRFNum,@piItemNo,@piBarCode,@vCodeType,@vGid,@piQuantity,@piPrice,@piAmount)
end
GO
