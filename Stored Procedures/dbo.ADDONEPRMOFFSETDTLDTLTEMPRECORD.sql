SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADDONEPRMOFFSETDTLDTLTEMPRECORD]
(
 @PINUM VARCHAR(14), --单号
 @PIAGMNUM VARCHAR(14), --协议单号
 @PIAGMLINE INT, --协议行号
 @PIAGMTABLENAME VARCHAR(32),
 @PISTOREGID INT, --门店
 @PIGDGID INT, --商品
 @PIQTY MONEY, --数量
 @PITOTAL MONEY --金额
)
AS
BEGIN
  DECLARE
    @VLINE INT, --以商品区分行号
    @VITEM INT --以商品和门店区分项目号
  --以一张促销补差单里只有一个协议号位前提
  --以商品找到行号
  SELECT @VLINE = MAX(LINE) FROM PRMOFFSETDTLDTLTEMP(NOLOCK)
  WHERE SPID = @@SPID AND NUM = @PINUM AND GDGID = @PIGDGID
  IF @VLINE IS NULL
    SELECT @VLINE = ISNULL(MAX(LINE) + 1, 1) FROM PRMOFFSETDTLDTLTEMP(NOLOCK)
    WHERE SPID = @@SPID AND NUM = @PINUM
  SELECT @VITEM = MAX(ITEM) FROM PRMOFFSETDTLDTLTEMP(NOLOCK)
  WHERE SPID = @@SPID AND NUM = @PINUM AND LINE = @VLINE AND STOREGID = @PISTOREGID
  IF @VITEM IS NULL
  BEGIN
    SELECT @VITEM = ISNULL(MAX(ITEM) + 1, 1) FROM PRMOFFSETDTLDTLTEMP(NOLOCK)
    WHERE SPID = @@SPID AND NUM = @PINUM AND LINE = @VLINE
    INSERT INTO PRMOFFSETDTLDTLTEMP(SPID, NUM, LINE, ITEM, GDGID, STOREGID, AGMNUM, AGMLINE, SAMT, RAMT, SQTY, RQTY, AGMTABLENAME)
    VALUES(@@SPID, @PINUM, @VLINE, @VITEM, @PIGDGID, @PISTOREGID, @PIAGMNUM, @PIAGMLINE, @PITOTAL, @PITOTAL, @PIQTY, @PIQTY, @PIAGMTABLENAME)
  END
  ELSE BEGIN
    UPDATE PRMOFFSETDTLDTLTEMP SET SQTY = SQTY + @PIQTY, RQTY = RQTY + @PIQTY, SAMT = SAMT + @PITOTAL, RAMT = RAMT + @PITOTAL
    WHERE SPID = @@SPID AND LINE = @VLINE AND ITEM = @VITEM
  END
  RETURN(0)
END
GO
