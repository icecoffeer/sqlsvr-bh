SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHGBOOKADDLOG]
(
 @PINUM 	CHAR(14),
 @PIOPER 	CHAR(30),
 @PITOSTAT	INT
)
AS
BEGIN
	INSERT INTO CHGBOOKLOG (NUM, STAT, MODIFIER, TIME)
       VALUES(@PINUM, @PITOSTAT, @PIOPER, GETDATE())
END;
GO
