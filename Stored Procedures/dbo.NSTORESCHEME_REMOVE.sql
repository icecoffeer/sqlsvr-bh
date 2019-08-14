SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[NSTORESCHEME_REMOVE]
(
  @SRC INT,
  @ID INT
)
AS
BEGIN
  DELETE FROM NSTOREOPERSCHEME WHERE SRC = @SRC AND ID = @ID
  DELETE FROM NSTOREOPERSCHEMEDTL WHERE SRC = @SRC AND ID = @ID
  DELETE FROM NSTORESCHSORTGOODS WHERE SRC = @SRC AND ID = @ID
END
GO
