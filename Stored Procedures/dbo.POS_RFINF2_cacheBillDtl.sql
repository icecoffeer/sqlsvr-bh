SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_cacheBillDtl]
(
	@piRFNum		varchar(10),/*输入：RF交易序列号*/
	@piItemNo		integer,		/*输入：RF交易明细编号*/
	@piOperator	integer,		/*输入：RF操作员GID*/
	@piFildate	datetime,		/*输入：RF交易开始时间*/
	@piBarCode	varchar(30),	/*输入：商品条码*/
	@piQuantity	decimal(24,4),/*输入：商品数量*/
	@piPrice		decimal(24,4),/*输入：商品单价*/
	@piAmount		decimal(24,2),/*输入：商品金额*/
	@piMbrPrice	decimal(24,2),/*输入：商品会员价*/
	@piMbrAmount	decimal(24,2),/*输入：商品会员金额*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vRowCount int,@vGid int,@vCode varchar(13),@vCodeType int
	declare @vQty decimal(24,4),@vAmt decimal(24,2),@vMbrAmt decimal(24,2)
	exec @vRet = POS_RFINF_AnalyzeBarCode @piBarCode,@vGid output,@vCode output,
		@vCodeType output,@vQty output,@vAmt output,@poErrMsg output
	if @vRet <> 0 Return(@vRet)
	begin tran
	if @vRet = 0
	begin
		--检查记录是否存在
		Select @vAmt = AMOUNT, @vMbrAmt = MBRAMOUNT from RFBILLDTLPOOL
			where RFNUM = @piRFNum and ITEMNO = @piItemNo
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '查找RFBILLDTLPOOL出错'
		else if @vRowCount = 1
		begin
			--记录已存在
			--先修改RFBILLPOOL
			update RFBILLPOOL
				set RECCNT = RECCNT - 1, TOTAL = TOTAL - @vAmt, MBRTOTAL = MBRTOTAL - @vMbrAmt
				where RFNUM = @piRFNum
			Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
			if @vRet <> 0
				Select @poErrMsg = '更新RFBILLPOOL出错'
			else if @vRowCount <> 1
				Select @vRet = 1, @poErrMsg = '更新RFBILLPOOL失败'
			else
			begin
				--再删除RFBILLDTLPOOL
				delete from RFBILLDTLPOOL where RFNUM = @piRFNum and ITEMNO = @piItemNo
				Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
				if @vRet <> 0
					Select @poErrMsg = '更新RFBILLPOOL出错'
				else if @vRowCount <> 1
					Select @vRet = 1, @poErrMsg = '更新RFBILLPOOL失败'
			end
		end
	end
	if @vRet = 0
	begin
		--插入RFBILLDTLPOOL
		insert into RFBILLDTLPOOL(RFNUM,ITEMNO,BARCODE,CODETYPE,GID,QTY,PRICE,AMOUNT,MBRPRICE,MBRAMOUNT)
			values(@piRFNum,@piItemNo,@piBarCode,@vCodeType,@vGid,@piQuantity,@piPrice,@piAmount,@piMbrPrice,@piMbrAmount)
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '插入RFBILLDTLPOOL出错'
		else if @vRowCount <> 1
			Select @vRet = 1, @poErrMsg = '插入RFBILLDTLPOOL失败'
	end
	if @vRet = 0
	begin
		--先尝试更新RFBILLPOOL
		update RFBILLPOOL
			set FILLER = @piOperator, FILDATE = @piFildate, RECCNT = RECCNT + 1,
				TOTAL = TOTAL + @piAmount, MBRTOTAL = MBRTOTAL + @piMbrAmount
			where RFNUM = @piRFNum
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '更新RFBILLPOOL出错'
		else if @vRowCount = 0
		begin
			--RFBILLPOOL无记录，尝试插入
			insert into RFBILLPOOL(RFNUM,FILLER,FILDATE,RECCNT,TOTAL,MBRTOTAL)
				values(@piRFNum, @piOperator, @piFildate, 1, @piAmount, @piMbrAmount)
			Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
			if @vRet <> 0
				Select @poErrMsg = '插入RFBILLPOOL出错'
			else if @vRowCount <> 1
				Select @vRet = 1, @poErrMsg = '插入RFBILLPOOL失败'
		end
	end
	if @vRet = 0
		commit
	else
		rollback
	Return(@vRet)
end
GO
