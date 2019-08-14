SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_AnalyzeBarCode]
(
	@piBarCode		varchar(30),		/*输入：商品条码*/
	@poGdGid		integer output,		/*输出：商品GID*/
	@poGdCode		varchar(13) output,	/*输出：商品代码*/
	@poCodeType		smallint output,	/*输出：条码类型，0-普通码，1-金额码，2-数量码，3-数量金额码，4-金额数量码*/
	@poQuantity		decimal(24,4) output,/*输出：商品数量*/
	@poAmount		decimal(24,2) output,/*输出：商品金额*/
	@poErrMsg		varchar(200) output	/*输出：错误信息*/
)
as
begin
	Select @poGdGid = Gid, @poGdCode = Code, @poCodeType = 0
	  from GdInput(nolock) where Code = @piBarCode
	if @@RowCount > 0
		Return(0)
	declare @vCodeLen int,@vQtyLen int,@vAmtLen int
	declare @vsQty varchar(20),@vsAmt varchar(20)
	Select @vCodeLen = CodeLen,@vQtyLen = QtyLen,@vAmtLen = AmtLen
	  from BarCodeLen(nolock) where Flag = SubString(@piBarCode, 1, 1)
	if @@RowCount = 0
	begin
		Select @poErrMsg = '不能解析的条码' + @piBarCode
		Return(1)
	end
	Select @poGdGid = Gid, @poGdCode = Code, @poCodeType = CodeType
	  from GdInput(nolock) where Code = SubString(@piBarCode, 1, @vCodeLen)
	if @@RowCount = 0
	begin
		Select @poErrMsg = '不能解析的条码' + @piBarCode
		Return(2)
	end
	if @poCodeType = 1  /*金额码*/
	begin
		Select @poErrMsg = @piBarCode + '是错误的金额条码'
		Select @vsAmt = SubString(@piBarCode, @vCodeLen + 1, @vAmtLen)
		if Len(@vsAmt) <> @vAmtLen
			Return(4)
		Select @poAmount = convert(decimal(24, 2), @vsAmt) / 100.0
		if @@ERROR <> 0
			Return(4)
		if @poAmount = 0
			Return(4)
		if Len(@piBarCode) > @vCodeLen + @vAmtLen + 1
			Return(4)
	end
	else if @poCodeType = 2  /*数量码*/
	begin
		Select @poErrMsg = @piBarCode + '是错误的数量条码'
		Select @vsQty = SubString(@piBarCode, @vCodeLen + 1, @vQtyLen)
		if Len(@vsQty) <> @vQtyLen
			Return(4)
		Select @poQuantity = convert(decimal(24, 2), @vsQty) / 1000.0
		if @@ERROR <> 0
			Return(4)
		if @poQuantity = 0
			Return(4)
		if Len(@piBarCode) > @vCodeLen + @vQtyLen + 1
			Return(4)
	end
	else if @poCodeType = 3  /*数量金额码*/
	begin
		Select @poErrMsg = @piBarCode + '是错误的数量金额条码'
		Select @vsQty = SubString(@piBarCode, @vCodeLen + 1, @vQtyLen)
		Select @vsAmt = SubString(@piBarCode, @vCodeLen + @vQtyLen + 1, @vAmtLen)
		if Len(@vsQty) <> @vQtyLen
			Return(4)
		Select @poQuantity = convert(decimal(24, 2), @vsQty) / 1000.0
		if @@ERROR <> 0
			Return(4)
		if @poQuantity = 0
			Return(4)
		if Len(@vsAmt) <> @vAmtLen
			Return(4)
		Select @poAmount = convert(decimal(24, 2), @vsAmt) / 100.0
		if @@ERROR <> 0
			Return(4)
		if @poAmount = 0
			Return(4)
		if Len(@piBarCode) > @vCodeLen + @vQtyLen + @vAmtLen + 1
			Return(4)
	end
	else if @poCodeType = 4  /*金额数量码*/
	begin
		Select @poErrMsg = @piBarCode + '是错误的金额数量条码'
		Select @vsAmt = SubString(@piBarCode, @vCodeLen + 1, @vAmtLen)
		Select @vsQty = SubString(@piBarCode, @vCodeLen + @vAmtLen + 1, @vQtyLen)
		if Len(@vsAmt) <> @vAmtLen
			Return(4)
		Select @poAmount = convert(decimal(24, 2), @vsAmt) / 100.0
		if @@ERROR <> 0
			Return(4)
		if @poAmount = 0
			Return(4)
		if Len(@vsQty) <> @vQtyLen
			Return(4)
		Select @poQuantity = convert(decimal(24, 2), @vsQty) / 1000.0
		if @@ERROR <> 0
			Return(4)
		if @poQuantity = 0
			Return(4)
		if Len(@piBarCode) > @vCodeLen + @vQtyLen + @vAmtLen + 1
			Return(4)
	end
	else
	begin
		Select @poErrMsg = '未知格式的条码' + @piBarCode
		Return(3)
	end
	Select @poErrMsg = ''
	Return(0)
end
GO
