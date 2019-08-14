SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STOREOPERSCHEME_DOREMOVE]
(
  @NUM VARCHAR(14),         --单号
  @MSG VARCHAR(255) OUTPUT  --错误信息
)
AS
BEGIN
  DELETE FROM STOREOPERSCHEME WHERE NUM = @NUM
  DELETE FROM STOREOPERSCHEMEDTL WHERE NUM = @NUM
  DELETE FROM SCHEMELAC WHERE NUM = @NUM
  DELETE FROM STORESCHSORTGOODS WHERE NUM = @NUM
  SET @MSG = ''
  RETURN 0
END
GO