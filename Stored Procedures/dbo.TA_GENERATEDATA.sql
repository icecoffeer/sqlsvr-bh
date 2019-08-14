SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[TA_GENERATEDATA]
	@IS_ERR VARCHAR(255) OUTPUT --返回错误信息
	,@GENTYPE VARCHAR(10)--按哪个厂家的财务软件格式生成记录
	,@OPERATION_NAME VARCHAR(50)	--对应业务名称
	,@VOUCHER_DATE VARCHAR(10) --写到凭证中的日期
	,@WHERE_CLAUSE varchar(255)=NULL--查询控制条件
	,@OPERATOR_NAME VARCHAR(10)--生成凭证的操作员姓名
As
DECLARE @RETURN INT
if @GENTYPE='YY'
BEGIN
	EXEC @RETURN=TA_GENFORYY @IS_ERR OUTPUT,@OPERATION_NAME,@VOUCHER_DATE,@WHERE_CLAUSE,@OPERATOR_NAME
	RETURN @RETURN
END
IF @GENTYPE='BOKE'
BEGIN
	EXEC @RETURN=TA_GENFORBOKE @IS_ERR OUTPUT,@OPERATION_NAME,@VOUCHER_DATE,@WHERE_CLAUSE,@OPERATOR_NAME
	RETURN @RETURN
END

IF @GENTYPE='KINGDEE88'
BEGIN
	EXEC @RETURN=TA_GENFORKingDee88 @IS_ERR OUTPUT,@OPERATION_NAME,@VOUCHER_DATE,@WHERE_CLAUSE,@OPERATOR_NAME
	RETURN @RETURN
END

SELECT @IS_ERR='对应'+@GENTYPE+'厂家的接口还没有实现。'
return -1


GO