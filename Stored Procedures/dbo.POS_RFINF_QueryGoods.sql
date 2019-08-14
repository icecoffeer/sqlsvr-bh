SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_QueryGoods]
(
	@piFildate		datetime,			/*输入：RF交易开始时间，以单笔交易扫入的第一个条码时间为准*/
	@piBarCode		varchar(30),		/*输入：商品条码*/
	@poName			varchar(30) output,	/*输出：商品名称*/
	@poIsBarCode	smallint output,	/*输出：是否电子秤条码，0-不是（可修改数量），1-是（不可修改数量）*/
	@pioQuantity	decimal(24,4) output,/*输入：RF设备录入商品数。输出：商品数量*/
	@poPrice		decimal(24,4) output,/*输出：商品单价*/
	@poAmount		decimal(24,2) output,/*输出：商品金额*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	declare @vRet int,@vStore int,@vGid int,@vCode varchar(13),@vCodeType int
	exec @vRet = POS_RFINF_AnalyzeBarCode @piBarCode,@vGid output,@vCode output,
		@vCodeType output,@pioQuantity output,@poAmount output,@poErrMsg output
	if @vRet <> 0 Return(@vRet)
	Select @poName = Name, @poPrice = RtlPrc from Goods(nolock) where Gid = @vGid
	if @@RowCount = 0
	begin
		Select @poErrMsg = '不存在GID为' + convert(varchar(20), @vGid) + '的商品'
		Return(10)
	end
	if @vCodeType = 1
		Select @pioQuantity = Round(@poAmount / @poPrice, 4)
	Select @vStore = UserGid from System(nolock)
	exec @vRet = GetGoodsPrmRtlPrc @vStore, @vGid, @piFildate, @pioQuantity, @poPrice output
	if @vCodeType in (3, 4)
		Select @poIsBarCode = 1, @poPrice = Round(@poAmount / @pioQuantity, 4)
	else if @vCodeType = 1
		Select @poIsBarCode = 1, @pioQuantity = Round(@poAmount / @poPrice, 4)
	else if @vCodeType = 2
		Select @poIsBarCode = 1, @poAmount = Round(@pioQuantity * @poPrice, 2)
	else if @vCodeType = 0
		Select @poIsBarCode = 0, @poAmount = Round(@pioQuantity * @poPrice, 2)
	Return(0)
end
GO
