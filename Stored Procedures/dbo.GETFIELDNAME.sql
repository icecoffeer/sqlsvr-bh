SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROC [dbo].[GETFIELDNAME]
	@PITABLENAME	VARCHAR(100),
	@PIFIELDNAME	VARCHAR(100),
	@PONAMERESULT VARCHAR(100) OUTPUT	
AS
BEGIN
	DECLARE
		@VFIELDLABEL	VARCHAR(80) 

	SELECT @PONAMERESULT = @PIFIELDNAME

	SELECT @PONAMERESULT = FIELDLABEL FROM COLLATEITEM 
	 WHERE COLLATENO=(SELECT NO FROM [COLLATE] WHERE TABLENAME=@PITABLENAME)
	   AND FIELDNAME = @PIFIELDNAME 

END 
GO