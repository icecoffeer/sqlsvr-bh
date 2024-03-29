SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MXFDMD_Snd]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
    DECLARE
        @SRC INT,       @CHKSTOREGID INT,   @STAT SMALLINT,
        @ID INT,        @USERGID INT,       @DMDSTORE INT,
        @EXP DATETIME,  @RCV INT

    SELECT @STAT = STAT, @SRC = SRC, @CHKSTOREGID = XCHGSTORE, @EXP = EXPDATE, @DMDSTORE = FROMSTORE
        FROM MXFDMD WHERE  NUM = @NUM
    SELECT @USERGID = USERGID FROM SYSTEM
--check
    IF @STAT not in (400, 401, 402, 411)
    BEGIN
        SET @MSG = '单据状态错误，不允许发送'
        RETURN(1)
    END
    IF @STAT = 401 AND (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
    BEGIN
        SET @MSG = '单据' + @NUM + '已经超过到效日期'
        RETURN 1
    END
    IF (@DMDSTORE = @USERGID) AND (@STAT NOT IN (401, 411))
    BEGIN
        SET @MSG = '报批单位，单据' + @NUM + '状态不是请求总部批准或申请作废状态，不能发送。'
        RETURN 1
    END
    IF (@CHKSTOREGID = @USERGID) AND (@STAT NOT IN (400, 402))
    BEGIN
        SET @MSG = '审批单位，单据' + @NUM + '状态不是总部批准或总部拒绝状态，不能发送。'
        RETURN 1
    END

--Prepare Paraments
    SET @SRC = @USERGID
    IF @DMDSTORE = @USERGID
      SET @RCV = @CHKSTOREGID
    ELSE IF @CHKSTOREGID = @USERGID
      SET @RCV = @DMDSTORE
    ELSE BEGIN
      SET @MSG = '本单位既不是报批单位，也不是审批单位，不能发送。'
      RETURN 1
    END
--Begin to send
    delete from NMXFDMD where NUM = @NUM;
    delete from NMXFDMDDTL where NUM = @NUM;
    EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NMXFDMD (ID, SRC, RCV, NUM, SETTLENO, STAT, FROMSTORE, TOSTORE, RECCNT, XCHGSTORE,
        FILDATE, FILLER, DMDDATE, DMDOPER, CHKDATE, CHECKER, LSTUPDTIME, LSTUPDOPER, EXPDATE, NOTE,
        SNDTIME, RCVTIME, TYPE, NSTAT, NNOTE, SRCNUM,
        FROMTOTAL, FROMTAX, DEPT)
    SELECT @ID, @SRC, @RCV, NUM, SETTLENO, STAT, FROMSTORE, TOSTORE, RECCNT, XCHGSTORE,
        FILDATE, FILLER, DMDDATE, DMDOPER, CHKDATE, CHECKER, LSTUPDTIME, LSTUPDOPER, EXPDATE, NOTE,
        GETDATE(), NULL, 0, 0, NULL, NUM, FROMTOTAL, FROMTAX, DEPT
        FROM MXFDMD
        WHERE NUM = @NUM
    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送'+@NUM+'单据失败'
        RETURN(1)
    END
    INSERT INTO NMXFDMDDTL (SRC, ID, NUM, LINE, GDGID, CONFIRM, NOTE, QTY, FROMPRC, FROMTOTAL, WRH, FROMTAX)
    SELECT @SRC, @ID, NUM, LINE, GDGID, CONFIRM, NOTE, QTY, FROMPRC, FROMTOTAL, WRH, FROMTAX
        FROM MXFDMDDTL
        WHERE NUM = @NUM
    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送'+@NUM+'单据失败'
        RETURN(1)
    END

    UPDATE MXFDMD SET SNDTIME = GETDATE() WHERE NUM = @NUM
    EXEC MXFDMD_ADD_LOG @NUM, @STAT, '发送', @OPER

END
GO
