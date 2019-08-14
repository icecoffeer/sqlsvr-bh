SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[POLYLTDADJ_MODIFYTO100]
(
  @NUM CHAR(14),
  @TOSTAT INT,
  @OPER VARCHAR(30),
  @MSG VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE
    @STAT INT,
    @OCRTYPE INT,
    @SETTLENO INT,
    @RETURN_VALUE INT
  SELECT @STAT = STAT, @OCRTYPE = OCRTYPE
    FROM POLYLTDADJ(NOLOCK) WHERE NUM = @NUM
  IF @@ROWCOUNT = 0
  BEGIN
    SET @MSG = '取单据失败'
    RETURN(1)
  END
  IF @STAT <> 0
  BEGIN
    SET @MSG = '不是未审核的单据，不能进行审核操作'
    RETURN(1)
  END

  SELECT @SETTLENO = MAX(NO) FROM MONTHSETTLE(NOLOCK)
  UPDATE POLYLTDADJ
  SET STAT = @TOSTAT, SETTLENO = @SETTLENO, CHKTIME = GETDATE(), CHECKER = @OPER, LSTUPDTIME = GETDATE(), LSTUPDOPER = @OPER
  WHERE NUM = @NUM

  IF @OCRTYPE = 0
  BEGIN
    EXEC @RETURN_VALUE = POLYLTDADJ_OCR @NUM, @OPER, @MSG OUTPUT
    IF @RETURN_VALUE <> 0 RETURN @RETURN_VALUE
  END

  EXEC POLYLTDADJ_ADD_LOG @NUM, @TOSTAT, '审核', @OPER;
  RETURN(0)
END
GO
