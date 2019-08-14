SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PROMDLT]
(
  @CLS      VARCHAR(10),
  @NUM      VARCHAR(14),
  @OPER     VARCHAR(30),
  @TOSTAT   INT,
  @MSG  VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RET  INT,
    @STAT INT

  SET @RET = 0
  SELECT @STAT = STAT FROM PROM(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS
  IF @STAT <> 100
  BEGIN
    SET @MSG = '目标状态不对' + LTRIM(STR(@STAT))
    RETURN 1
  END

  UPDATE GOODS SET LSTUPDTIME = GETDATE()
  WHERE GID IN (SELECT GDGID FROM PROMOTE(NOLOCK) WHERE BILLNUM = @NUM AND CLS = @CLS)

  DELETE FROM PROMOTE
    WHERE BILLNUM = @NUM AND CLS = @CLS
  DELETE FROM PROMOTEMONEY
    WHERE BILLNUM = @NUM AND CLS = @CLS
  DELETE FROM PROMOTEQTY
    WHERE BILLNUM = @NUM AND CLS = @CLS
  DELETE FROM PROMOTEGFT
    WHERE BILLNUM = @NUM AND CLS = @CLS
  UPDATE PROM SET STAT = 110, FILDATE = GETDATE(),
    LSTUPDTIME = GETDATE()
  WHERE NUM = @NUM AND CLS = @CLS
  INSERT INTO PROMLOG (NUM, CLS, STAT, FILLER, FILDATE)
  VALUES(@NUM, @CLS, 110, @OPER, GETDATE())
  --删除促销单优先级信息
  if (@CLS = '捆绑') or (@CLS = '总量') or (@CLS = '总额')
  begin
    declare @PRMNAME char(30)
    set @PRMNAME = @CLS + '促销'
    Exec @RET = PS3_DelPromPir '组合', @PRMNAME, @NUM
    if @RET <> 0
      return @RET
  end

 /* EXEC @RET = PROMSEND @CLS, @NUM, @OPER, 0, @MSG
  IF @RET <> 0 RETURN 1 */
  RETURN 0
END
GO
