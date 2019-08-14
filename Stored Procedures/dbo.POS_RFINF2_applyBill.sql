SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_applyBill]
(
	@piRFNum		varchar(10),/*输入：RF交易序列号*/
	@piOperator	integer,		/*输入：RF操作员GID*/
	@piFildate	datetime,		/*输入：RF交易开始时间*/
	@piBarCode	varchar(30),/*输入：绑定的条码卡号*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vRowCount int,@vRFNum varchar(10),@vReccnt int
	if @piBarCode is null
		Select @vRet = 0
	else
	begin
		--检查条码卡号是否已被绑定
		Select @vRFNum = RFNUM from RFBILL where CARDCODE = @piBarCode and STAT = 0
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '查找RFBILLPOOL出错'
		else if @vRowCount = 1
			Select @vRet = 1, @poErrMsg = '卡号已被待付款的RF交易 ' + @vRFNum + ' 绑定'
	end
	if @vRet <> 0 Return(@vRet)
	Select @vReccnt = RECCNT from RFBILLPOOL where RFNUM = @piRFNum
	begin tran
	if @vRet = 0
	begin
		--尝试插入RFBILL
		insert into RFBILL(RFNUM,STAT,FILLER,FILDATE,RECCNT,TOTAL,MBRTOTAL,CARDCODE)
			select RFNUM,0,@piOperator,@piFildate,RECCNT,TOTAL,MBRTOTAL,@piBarCode
				from RFBILLPOOL where RFNUM = @piRFNum
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '插入RFBILL出错'
		else if @vRowCount = 0
			Select @vRet = 1, @poErrMsg = '插入RFBILL失败'
	end
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
		--尝试插入RFBILLDTL
		insert into RFBILLDTL(RFNUM,ITEMNO,BARCODE,CODETYPE,GID,QTY,PRICE,AMOUNT,MBRPRICE,MBRAMOUNT)
			select RFNUM,ITEMNO,BARCODE,CODETYPE,GID,QTY,PRICE,AMOUNT,MBRPRICE,MBRAMOUNT
				from RFBILLDTLPOOL where RFNUM = @piRFNum
		Select @vRet = @@ERROR, @vRowCount = @@ROWCOUNT
		if @vRet <> 0
			Select @poErrMsg = '插入RFBILLDTL出错'
		else if @vRowCount <> @vReccnt
			Select @vRet = 1, @poErrMsg = '插入RFBILLDTL失败'
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
