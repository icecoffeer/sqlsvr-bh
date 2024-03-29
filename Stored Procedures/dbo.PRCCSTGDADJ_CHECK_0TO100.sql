SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRCCSTGDADJ_CHECK_0TO100]
(
  @NUM	CHAR(14),
  @OPER	CHAR(30),
  @CLS	CHAR(10),
  @TOSTAT	INT,
  @MSG	VARCHAR(255) OUTPUT
)				
AS
BEGIN
	DECLARE 
	  @EMPGID INT, 		@RE INT,
	  @STOREGID INT,	@GDGID INT,
	  @NEWPRC MONEY
	  
	SELECT @EMPGID = GID FROM EMPLOYEE(NOLOCK) WHERE 
	CODE = SUBSTRING(@OPER, CHARINDEX('[',@OPER) + 1, LEN(@OPER) - CHARINDEX('[',@OPER) - 1)
	AND NAME = SUBSTRING(@OPER, 1, CHARINDEX('[',@OPER) - 1)
	
	UPDATE PRCCSTGDADJ SET
	  STAT = 100, CHKDATE = GETDATE(), CHECKER = @EMPGID
	WHERE NUM = @NUM
	
	DECLARE C_LAC CURSOR FOR
	SELECT STOREGID FROM PRCCSTGDADJLACDTL(NOLOCK) WHERE NUM = @NUM
	OPEN C_LAC
	FETCH NEXT FROM C_LAC
	INTO @STOREGID
	WHILE @@FETCH_STATUS = 0
	BEGIN
 	  
 	  DECLARE C_GOODS CURSOR FOR
	  SELECT GDGID, NEWPRC FROM PRCCSTGDADJDTL(NOLOCK) WHERE NUM = @NUM
	  OPEN C_GOODS
	  FETCH NEXT FROM C_GOODS
	  INTO @GDGID, @NEWPRC
	  WHILE @@FETCH_STATUS = 0
	  BEGIN 	  
 	    IF EXISTS(SELECT 1 FROM CSTGD WHERE CSTGID = @STOREGID AND GDGID = @GDGID)
 	      UPDATE CSTGD SET ALCPRC = @NEWPRC WHERE CSTGID = @STOREGID AND GDGID = @GDGID
 	    ELSE
 	      INSERT INTO CSTGD(CSTGID, GDGID, CSTGDCODE, SALE, ALCQTY, 
 	        ALCPRC, ISLTD, MEMO, LSTUPDTIME, LSTMODIFIER, CODE2, CRTLPRC)
 	      VALUES(@STOREGID, @GDGID, NULL, 1, 1, 
 	        @NEWPRC, 0, '客户商品价格调整单生成', GETDATE(), @OPER, NULL, 0)
 	    FETCH NEXT FROM C_GOODS
	    INTO @GDGID, @NEWPRC
	  END
	  DEALLOCATE C_GOODS
 	  
	  FETCH NEXT FROM C_LAC
	  INTO @STOREGID
	END
	DEALLOCATE C_LAC
	
	EXEC PRCCSTGDADJADDLOG @NUM, 100, '审核', @OPER
	
	RETURN 0
END
GO
