SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LTDADJDEL] (
  @NUM	CHAR(14),
  @OPER	INT
) AS
BEGIN
  DECLARE @STAT INT
  SELECT @STAT = STAT FROM LTDADJ WHERE NUM = @NUM
  IF @STAT <> 0
  BEGIN
  	RAISERROR('单据%s不是未审核单据，不能删除', 16, 1, @NUM)
  	RETURN 1
  END ELSE
  BEGIN
    DELETE FROM LTDADJDTL WHERE NUM = @NUM
    DELETE FROM LTDADJLACDTL WHERE NUM = @NUM
    DELETE FROM LTDADJ WHERE NUM = @NUM
  END

  RETURN 0
END
GO