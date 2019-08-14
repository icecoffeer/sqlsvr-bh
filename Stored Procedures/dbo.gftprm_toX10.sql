SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_toX10]
(
  @piNum	char(14),
  @piOper char(30),
  @poErrMsg varchar(255) output
)
as
begin
	DECLARE @VSTAT INT, @VRET INT
	SELECT @VSTAT = STAT FROM GFTPRM WHERE NUM LIKE @PINUM
	IF @VSTAT = 100 
		EXEC @VRET = gftprm_to110 @piNum, @piOper, @poErrMsg
	IF (@VSTAT = 800) or (@VSTAT = 1400)
		EXEC @VRET = gftprm_to810 @piNum, @piOper, @poErrMsg
	RETURN @VRET
end
GO
