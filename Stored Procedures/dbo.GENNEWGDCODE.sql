SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GENNEWGDCODE]
(
  @SORT VARCHAR(13),
  @GDCODE VARCHAR(13) OUTPUT
)
AS
BEGIN
  DECLARE
    @CODE1 VARCHAR(20),
    @CODE2 VARCHAR(20)

  SET @SORT = LTRIM(RTRIM(@SORT))
  SET @SORT = SUBSTRING(@SORT, 1, 2)
  SET @CODE1 = @SORT
  SET @CODE2 = @SORT
  EXEC GENFLOWCODEEX @CODE1 OUTPUT, 'GDINPUT'
  EXEC GENFLOWCODEEX @CODE2 OUTPUT, 'GOODSH'
  IF @CODE1 > @CODE2 SET @GDCODE = @CODE1
  ELSE SET @GDCODE = @CODE2
END
GO
