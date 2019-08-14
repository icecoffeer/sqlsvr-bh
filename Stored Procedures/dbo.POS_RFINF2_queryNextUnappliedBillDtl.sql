SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_queryNextUnappliedBillDtl]
(
	@piRFNum		varchar(10),	/*输入：RF交易序列号*/
	@piPriorItemNo	integer,		/*输入：前一条RF交易明细编号，查第一个时传0*/
	@poItemNo		integer output,	/*输出：查到的RF交易明细编号*/
	@poOperator		integer output,	/*输出：查到的RF操作员GID*/
	@poFildate		datetime output,/*输出：查到的RF交易开始时间*/
	@poBarCode		varchar(30) output,	/*输出：查到的商品条码*/
	@poName			varchar(30) output,	/*输出：商品名称*/
	@poIsBarCode	smallint output,	/*输出：是否电子秤条码，0-不是（可修改数量），1-是（不可修改数量）*/
	@poPriceType	smallint output,	/*输出：商品价格类型，0-固定价（不可修改单价），1-可变价（可修改单价）*/
	@poQuantity		decimal(24,4) output,/*输出：查到的商品数量*/
	@poPrice		decimal(24,4) output,/*输出：查到的商品单价*/
	@poAmount		decimal(24,2) output,/*输出：查到的商品金额*/
	@poMbrPrice		decimal(24,2) output,/*输出：查到的商品会员价*/
	@poMbrAmount	decimal(24,2) output,/*输出：查到的商品会员金额*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vRowCount int,@vGid int
	Select @poOperator = FILLER, @poFildate = FILDATE
		from RFBILLPOOL(nolock)
		where RFNUM = @piRFNum
	Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
	if @vRet <> 0
		Select @poErrMsg = '查找RFBILLPOOL出错'
	else if @vRowCount = 0
		Select @vRet = 1, @poErrMsg = '查找RFBILLPOOL失败'
	if @vRet <> 0 Return(@vRet)
	Select top 1 @poItemNo = ITEMNO, @vGid = Gid, @poBarCode = BARCODE, @poIsBarCode = CODETYPE, @poQuantity = QTY,
			@poPrice = PRICE, @poAmount = AMOUNT, @poMbrPrice = MBRPRICE, @poMbrAmount = MBRAMOUNT
		from RFBILLDTLPOOL(nolock)
		where RFNUM = @piRFNum and ITEMNO > @piPriorItemNo
		order by ITEMNO
	Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
	if @vRet <> 0
		Select @poErrMsg = '查找RFBILLDTLPOOL出错'
	else if @vRowCount = 0
		Select @vRet = 1, @poErrMsg = ''
	else
	begin
		if @poIsBarCode <> 0
			Select @poIsBarCode = 1
		Select @poName = Name, @poPriceType = PrcType from Goods(nolock) where Gid = @vGid
	end
	Return(@vRet)
end
GO
