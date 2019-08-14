SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MKTPRC_SEND]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @STAT INT, @SRC INT, @RCV INT, @ID INT

  SELECT @STAT = STAT FROM MKTPRC(NOLOCK) WHERE NUM = @NUM

  IF @STAT <> 100 AND @STAT <> 110
  BEGIN
    SET @MSG = '[发送]单据' + @NUM + '不是已审核或已作废状态'
    RETURN 1
  END

  UPDATE MKTPRC SET SNDTIME = GETDATE() WHERE NUM = @NUM
  SELECT @SRC = USERGID FROM SYSTEM(NOLOCK)
  SELECT @RCV = ZBGID FROM SYSTEM(NOLOCK)

  EXECUTE GETNETBILLID @ID OUTPUT

  INSERT INTO NMKTPRC(NUM, SETTLENO, STAT, STOREGID, SCHEMENUM, INVSTER, INVSTDATE, FILLER,
    FILDATE, CHECKER, CHKDATE, CANCELER, CACLDATE, LSTUPDTIME, SNDTIME, RECCNT, PRNTIME,
    INVSTOBJ, INVSTPLACE, NOTE, SRC, ID, RCV, RCVTIME, NTYPE, NSTAT, NNOTE)
  SELECT NUM, SETTLENO, STAT, STOREGID, SCHEMENUM, INVSTER, INVSTDATE, FILLER,
    FILDATE, CHECKER, CHKDATE, CANCELER, CACLDATE, LSTUPDTIME, SNDTIME, RECCNT, PRNTIME,
    INVSTOBJ, INVSTPLACE, NOTE, @SRC, @ID, @RCV, GETDATE(), 0, 0, NULL
  FROM MKTPRC(NOLOCK)
  WHERE NUM = @NUM

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '发送' + @NUM + '单据失败'
    RETURN 2
  END

  INSERT INTO NMKTPRCDTL(NUM, LINE, GDGID, GDQPCSTR, GDQPC, RTLPRC,
    CNTINPRC, WHSPRC, MBRPRC, PROMOTEPRICE, PROMOTEINPRC, PROMOTEMBRPRC, NOTE,
    LRTLPRC, LCNTINPRC, LWHSPRC, LMBRPRC, LPROMOTEPRICE, LPROMOTEINPRC, LPROMOTEMBRPRC, SRC, ID)
  SELECT NUM, LINE, GDGID, GDQPCSTR, GDQPC, RTLPRC,
    CNTINPRC, WHSPRC, MBRPRC, PROMOTEPRICE, PROMOTEINPRC, PROMOTEMBRPRC, NOTE,
    LRTLPRC, LCNTINPRC, LWHSPRC, LMBRPRC, LPROMOTEPRICE, LPROMOTEINPRC, LPROMOTEMBRPRC, @SRC, @ID
  FROM MKTPRCDTL(NOLOCK)
  WHERE NUM = @NUM

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '发送' + @NUM + '单据失败'
    RETURN 3
  END

  SET @MSG = '发送' + @NUM + '单据成功'

  RETURN 0
END
GO
