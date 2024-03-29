SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRMRTNPNTAGM_ON_MODIFY]
(
  @NUM VARCHAR(14),            --单号
  @TOSTAT INT,                 --目标状态
  @OPER VARCHAR(30),           --操作人
  @MSG VARCHAR(255) OUTPUT  --错误信息
)
AS
BEGIN
  DECLARE @VRET INT, @FROMSTAT INT;

  IF @TOSTAT <> 0
  BEGIN
    --状态调度
    IF @TOSTAT = 100
    BEGIN
      EXEC @VRET = PRMRTNPNTAGM_MODIFYTO100 @NUM, @TOSTAT, @OPER, @MSG OUTPUT;
      RETURN(@VRET)
    END
    IF @TOSTAT = 300
    BEGIN
      EXEC @VRET = PRMRTNPNTAGM_MODIFYTO300 @NUM, @TOSTAT, @OPER, @MSG OUTPUT;
      RETURN(@VRET)
    END
    IF @TOSTAT = 1400
    BEGIN
      EXEC @VRET = PRMRTNPNTAGM_MODIFYTO1400 @NUM, @TOSTAT, @OPER, @MSG OUTPUT;
      RETURN(@VRET)
    END
  END
  ELSE BEGIN
    UPDATE PRMRTNPNTAGM SET LSTUPDOPER = @OPER, LSTUPDTIME = GETDATE() WHERE NUM = @NUM
    SELECT @FROMSTAT = STAT FROM PRMRTNPNTAGM(NOLOCK) WHERE NUM = @NUM
    IF @FROMSTAT = 0
      EXEC PRMRTNPNTAGM_ADD_LOG @NUM, @TOSTAT, '修改', @OPER;
    ELSE
      EXEC PRMRTNPNTAGM_ADD_LOG @NUM, @TOSTAT, '新增', @OPER;
    RETURN(0)
  END;
END
GO
