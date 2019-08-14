SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetLtdBusinessString]
(
  @index int
) RETURNS varchar(100) AS
BEGIN
  DECLARE @str varchar(100)
  SET @str = ''
  IF @index & 1 = 1
    SET @str = @str + '限制配货; '
  IF @index & 2 = 2
    SET @str = @str + '限制定货; '
  IF @index & 4 = 4
    SET @str = @str + '限制销售; '
  IF @index & 8 = 8
    SET @str = @str + '清场; '
  IF @index & 16 = 16
    SET @str = @str + '限制向总部退货; '
  IF @index & 32 = 32
    SET @str = @str + '限制向供应商退货; '
  IF @index IS NULL OR @index < 0 OR @index > 63
    SET @str = '无'

  RETURN @str
END
GO
