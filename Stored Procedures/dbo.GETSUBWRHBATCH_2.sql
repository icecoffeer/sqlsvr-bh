SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GETSUBWRHBATCH_2]
  @GDGID INT,
  @INPRC MONEY,--新增本次批次的进价
  @SUBWRH INT OUTPUT,
  @CODE CHAR(10) OUTPUT,
  @ERRMSG VARCHAR(200) = '' OUTPUT
AS
BEGIN
  /*
  输入: @WRH,仓位GID.
  输出: @SUBWRH,新货位的GID
	@CODE 新货位的代码
  改变数据: 新增一个货位,CODE的格式为“YYMMDDXXXX”
  	前6位通过当前日期得到，后4位流水. NAME中的内容与CODE相同 */
  DECLARE @WRH INT
  SELECT @WRH = 1
  DECLARE @DATESTR CHAR(6), @STRING CHAR(20), @MAXSUBWRH CHAR(10)
  DECLARE @USERCODE CHAR(4)

  SELECT @STRING = CONVERT(CHAR(10), GETDATE(), 102)
  SELECT @DATESTR = SUBSTRING(@STRING,3,2) + SUBSTRING(@STRING,6,2) +	SUBSTRING(@STRING,9,2)
  --增加门店代码
  SELECT @USERCODE = USERCODE FROM SYSTEM(NOLOCK)
  SELECT @DATESTR = SUBSTRING(@USERCODE, 1, 4) + @DATESTR
  SELECT @MAXSUBWRH = ISNULL(
    (SELECT MAX(CODE) FROM SUBWRH WHERE CODE LIKE @DATESTR+'%'), 
    @DATESTR+'0000')
  EXECUTE NEXTBN @MAXSUBWRH, @MAXSUBWRH OUTPUT
  
  EXEC @SUBWRH = SEQNEXTVALUE 'SUBWRH'

  INSERT INTO SUBWRH (GID,GDGID, CODE, NAME, WRH,INPRC)
	VALUES (@SUBWRH, @GDGID,@MAXSUBWRH, @MAXSUBWRH, @WRH,@INPRC)
  SELECT @CODE = @MAXSUBWRH
  
	RETURN 0
END
GO
