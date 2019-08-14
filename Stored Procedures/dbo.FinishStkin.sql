SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FinishStkin]
(
  @strReceiptNum CHAR(14),
  @strUserCode VARCHAR(10),
  @strErrMsg VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE
    @RET INT,
    @OPER VARCHAR(30),
    @intOpt_RfFinishStat int;  --结束收货时收货单的状态。选项配置。

  EXEC OPTREADINT 8146, 'RFFINISHSTAT', 0, @intOpt_RfFinishStat output;

  SET @OPER = NULL
  SELECT @OPER = RTRIM(NAME) + '[' + RTRIM(CODE) + ']'
    FROM EMPLOYEE(NOLOCK)
    WHERE CODE = @strUserCode
  IF @OPER IS NULL
    SET @OPER = '未知[-]'

  EXEC @RET = GOODSRECEIPT_ON_MODIFY
    @Num = @strReceiptNum,
    @ToStat = @intOpt_RfFinishStat,
    @Oper = @OPER,
    @Msg = @strErrMsg OUTPUT;

  RETURN(@RET)
END
GO
