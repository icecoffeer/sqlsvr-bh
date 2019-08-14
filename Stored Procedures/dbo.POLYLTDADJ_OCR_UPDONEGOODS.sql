SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[POLYLTDADJ_OCR_UPDONEGOODS]
(
  @ATYPE INT, /*调整单汇总的调整范围的值*/
  @LTDVALUE INT, /*调整单明细的调整范围的值*/
  @GDGID INT, /*待改的商品*/
  @ISLTD INT, /*待改商品的原有限制业务属性值*/
  @OPERGID INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @I INT,
    @J INT,
    @N INT,
    @NEWVALUE INT
  SET @NEWVALUE = @ISLTD
  SELECT @N = CONVERT(INT, FLOOR(LOG10(@ATYPE)/LOG10(2)))
  SET @I = 0
  SET @J = 1
  WHILE @I <= @N
  BEGIN
    IF @ATYPE & @J = @J
    BEGIN
      IF @LTDVALUE & @J = @J
        SELECT @NEWVALUE = @NEWVALUE | @J
      ELSE
        SELECT @NEWVALUE = @NEWVALUE & (~@J)
    END
    SET @I = @I + 1
    SET @J = @J * 2
  END
  UPDATE GOODS SET ISLTD = @NEWVALUE, LSTUPDTIME = GETDATE(), MODIFIER = @OPERGID
  WHERE GID = @GDGID
  RETURN 0
END
GO