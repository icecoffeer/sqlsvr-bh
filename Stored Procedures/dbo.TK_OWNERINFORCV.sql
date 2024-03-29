SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TK_OWNERINFORCV](
		@CLS CHAR(10)
)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM TK_NOWNERINFO(NOLOCK) WHERE SERIALNO
		NOT IN (SELECT SERIALNO FROM TK_TOKENINFO(NOLOCK)))
	BEGIN
		RAISERROR('本地未找到令牌资料', 16, 1)
		RETURN 1
	END
	
	DELETE FROM TK_OWNERINFO WHERE CLS = @CLS
	INSERT INTO TK_OWNERINFO(CLS, OWNERGID, SERIALNO, PIN)
	SELECT CLS, OWNERGID, SERIALNO, PIN
	FROM TK_NOWNERINFO WHERE TYPE = 1 AND CLS = @CLS
	DELETE FROM TK_NOWNERINFO WHERE TYPE = 1 AND CLS = @CLS
	
	RETURN 0
END
GO
