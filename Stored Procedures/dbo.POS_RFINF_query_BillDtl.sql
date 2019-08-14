SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_query_BillDtl]
(
	@piRFNum	varchar(10),		/*输入：RF交易序列号*/
	@piItemNo	integer,			/*输入：RF交易明细编号*/
	@poBarCode	varchar(30) output,	/*输出：商品条码*/
	@poName		varchar(30) output,	/*输出：商品名称*/
	@poQuantity	decimal(24,4) output,/*输出：商品数量*/
	@poPrice	decimal(24,4) output,/*输出：商品单价*/
	@poAmount	decimal(24,2) output,/*输出：商品金额*/
	@poErrMsg	varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vGid int
	Select @vGid = GID,@poBarCode = BARCODE,@poQuantity = QTY,@poPrice = PRICE,@poAmount = AMOUNT
	  from RFBILLDTL(nolock) where RFNUM = @piRFNum and ITEMNO = @piItemNo
	if @@RowCount = 0
	begin
		Select @poErrMsg = '不存在RF交易明细(RFNUM=' + @piRFNum + ',ITEMNO=' + convert(varchar(3), @piItemNo) + ')'
		Return(1)
	end
	Select @poName = Name from Goods(nolock) where Gid = @vGid
	Return(0)
end
GO
