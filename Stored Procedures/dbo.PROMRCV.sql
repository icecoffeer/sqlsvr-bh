SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PROMRCV]
(
  @SRC      INT,
  @RCV      INT,
  @CLS      VARCHAR(10),
  @MSG      VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RET   INT,
    @ID    INT

  DECLARE CRDTL CURSOR FOR
  SELECT ID FROM NPROM(NOLOCK) WHERE SRC = @SRC AND RCV = @RCV and CLS = @CLS AND TYPE = 1 ORDER BY ID

  OPEN CRDTL
  FETCH NEXT FROM CRDTL INTO @ID
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC @RET = RCVONEPROM @SRC, @ID, @CLS, '交换服务', @MSG output
    IF @RET <> 0
    begin
    	CLOSE CRDTL
      DEALLOCATE CRDTL
      RETURN 1
    end
    FETCH NEXT FROM CRDTL INTO @ID
  END
  CLOSE CRDTL
  DEALLOCATE CRDTL

  RETURN 0
END
GO