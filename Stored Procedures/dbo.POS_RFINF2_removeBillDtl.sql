SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_removeBillDtl]
(
	@piRFNum		varchar(10),/*输入：RF交易序列号*/
	@piItemNo		integer,		/*输入：RF交易明细编号*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vRowCount int,@vAmt decimal(24,2),@vMbrAmt decimal(24,2)
	begin tran
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
	if @vRet = 0
	begin
		--删除记录数为零的交易
		delete from RFBILLPOOL where RFNUM = @piRFNum and RECCNT = 0
		Select @vRet = @@ERROR
		if @vRet <> 0
			Select @poErrMsg = '删除RFBILLPOOL出错'
	end
	if @vRet = 0
		commit
	else
		rollback
	Return(@vRet)
end
GO
