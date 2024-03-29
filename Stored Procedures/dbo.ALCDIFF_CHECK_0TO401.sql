SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ALCDIFF_CHECK_0TO401]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)				-- RETURN ERROR FROM 200
AS
BEGIN
	DECLARE
	  @EMPGID INT,
	  @TNUM INT

        SELECT @TNUM = COUNT(AD.SRCNUM) FROM ALCDIFFDTL AD,ALCDIFF A WHERE A.NUM = AD.NUM  AND A.NUM = @NUM
        AND AD.SRCNUM IN (SELECT ALD.SRCNUM FROM ALCDIFFDTL ALD,ALCDIFF AL WHERE AL.NUM = ALD.NUM AND AL.STAT IN (401,300) AND AL.NUM <> @NUM)
        
        IF @TNUM > 0 
        BEGIN
          SET @MSG = '来源单据已被其他请求总部批准的单据引用'
          RETURN 1
        END	

	SELECT @EMPGID = GID FROM EMPLOYEE(NOLOCK) WHERE
	  CODE = SUBSTRING(@OPER, CHARINDEX('[',@OPER) + 1, LEN(@OPER) - CHARINDEX('[',@OPER) - 1)
	AND NAME = SUBSTRING(@OPER, 1, CHARINDEX('[',@OPER) - 1)

	UPDATE ALCDIFF SET
	  STAT = 401, REQDATE = GETDATE(), REQOPER = @EMPGID
	WHERE NUM = @NUM

	EXEC ALCDIFFADDLOG @NUM, 401, '请求总部批准', @OPER

	SET @MSG = '单据：' + @NUM + '请求总部批准成功'

	RETURN 0
END
GO
