SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DELNPROM]
(
  @SRC      INT,
  @ID  INT
)
AS
BEGIN
  DELETE FROM NPROM WHERE SRC = @SRC AND ID = @ID
  DELETE FROM NPROMGOODS WHERE SRC = @SRC AND ID = @ID
  DELETE FROM NPROMQTY WHERE SRC = @SRC AND ID = @ID
  DELETE FROM NPROMMONEY WHERE SRC = @SRC AND ID = @ID
  DELETE FROM NPROMGFT WHERE SRC = @SRC AND ID = @ID
END
GO
