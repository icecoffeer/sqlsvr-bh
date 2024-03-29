SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRCCSTGDADJGRPADDLOG] 
(
	@NUM	CHAR(14),
	@TOSTAT	INT,
	@ACT	VARCHAR(50),
	@OPER	CHAR(30)
)   		
AS
BEGIN
	IF RTRIM(@OPER) = '' 
	BEGIN
		DECLARE @FILLERCODE VARCHAR(20), @FILLER INT, @FILLERNAME VARCHAR(50)
		SET @FILLERCODE = SUSER_SNAME()
		WHILE CHARINDEX('_',@FILLERCODE) <> 0
		BEGIN
  			SET @FILLERCODE = SUBSTRING(@FILLERCODE,CHARINDEX('_',@FILLERCODE) + 1,LEN(@FILLERCODE))
		END
		SELECT @FILLER = GID, @FILLERNAME = NAME FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
		IF @FILLERNAME IS NULL 
		BEGIN
			SET @FILLERCODE = '-'
			SET @FILLERNAME = '未知'
			SELECT @FILLER = GID FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
		END
		SET @OPER = '['+RTRIM(ISNULL(@FILLERCODE,''))+']' + RTRIM(ISNULL(@FILLERNAME,''))
	END
	IF @ACT = '' SELECT @ACT = ACTNAME FROM MODULESTAT(NOLOCK) WHERE NO = @TOSTAT
	INSERT INTO PRCCSTGDADJGRPLOG (NUM, STAT, ACT, MODIFIER, TIME) 
	VALUES(@NUM, @TOSTAT, @ACT, @OPER, GETDATE());
	RETURN 0
END
GO
