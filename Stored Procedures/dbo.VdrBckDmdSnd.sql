SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VdrBckDmdSnd]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
    DECLARE
        @SRC INT,       @CHKSTOREGID INT,   @STAT SMALLINT,
        @ID INT,        @USERGID INT,       @DMDSTORE INT,
        @EXP DATETIME,	@RCV INT, @UserProperty INT

    SELECT @STAT = STAT, @SRC = SRC, @CHKSTOREGID = CHKSTOREGID, @EXP = EXPDATE, @DMDSTORE = DMDSTORE
        FROM VDRBCKDMD WHERE  NUM = @NUM
    SELECT @UserProperty = UserProperty, @USERGID = USERGID FROM SYSTEM
--check
    IF @STAT <> 401 AND @STAT <> 500  AND @STAT <> 411 AND @STAT <> 410
    BEGIN
        SET @MSG = '发送的单据不是请求总部批准、已审核或申请作废、批准后作废'
        RETURN(1)
   	END
   	/*只检查401下的单据，其他状态允许发送*/
    IF @STAT IN (401) AND (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
    BEGIN
        SET @MSG = '单据' + @NUM + '已经超过到效日期'
        RETURN 1
    END
    IF (@DMDSTORE = @USERGID) AND (@STAT NOT IN (401, 411, 410))  --2005.03.15
    BEGIN
        SET @MSG = '报批单位，单据' + @NUM + '状态为非申请总部批准、批准作废，不能发送。'
        RETURN 1
    END
    IF (@CHKSTOREGID = @USERGID) AND (@STAT = 401)
    BEGIN
        SET @MSG = '审批单位，单据' + @NUM + '状态为申请总部批准，不能发送。'
        RETURN 1
    END
    --2004.12.23
  	IF (@DMDSTORE <> @USERGID) AND (@SRC = @USERGID) AND (@STAT = 411)
  	BEGIN
  		  SET @MSG = '单据' + @NUM + '总部代门店申请的单据，状态为申请作废的，无需发送。'
  		  RETURN 1
  	END
--Prepare Paraments
    IF @STAT = 401
    BEGIN
        IF @CHKSTOREGID = @USERGID
        BEGIN
            SET @MSG = '发送的单据不是本单位生成的'
            RETURN(1)
        END
        SET @RCV = @CHKSTOREGID
        --SET @SRC = @SRC
    END
    ELSE
    BEGIN
        IF @DMDSTORE = @USERGID
        BEGIN
            --SET @MSG = '发送的单据不是本单位批准的' --2005.03.15
            --RETURN(1)
            SET @RCV = @CHKSTOREGID
            --SET @SRC = @DMDSTORE
        END ELSE
        BEGIN
            SET @RCV = @DMDSTORE
            SET @SRC = @CHKSTOREGID
        END
    END
--Begin to send
    EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NVDRBCKDMD (ID, SRC, RCV, VENDOR, NUM, SETTLENO, RECCNT,
        NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE,PSR,PSRGID,
        CANCELER, EXPDATE, STAT, BCKCLS, BEGINDATE,
        SNDDATE, RCVTIME, NTYPE, NSTAT, NNOTE, DMDSTORE, SRCNUM)
    SELECT @ID, @SRC, @RCV, VENDOR, NUM, SETTLENO, RECCNT,
            NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE,PSR,PSRGID,
        CANCELER, EXPDATE, STAT, BCKCLS, BEGINDATE,
            GETDATE(), NULL, 0, 0, NULL, DMDSTORE, SRCNUM
        FROM VDRBCKDMD
        WHERE NUM = @NUM
    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送'+@NUM+'单据失败'
        RETURN(1)
    END
    INSERT INTO NVDRBCKDMDDTL (SRC, ID, NUM, LINE, GDGID, CASES, QTY, DMDCASES,
           DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY)
    SELECT @SRC, @ID, NUM, LINE, GDGID, CASES, QTY, DMDCASES,
        DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY
        FROM VDRBCKDMDDTL
        WHERE NUM = @NUM
    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送'+@NUM+'单据失败'
        RETURN(1)
    END
    UPDATE VDRBCKDMD SET SNDDATE = GETDATE() WHERE NUM = @NUM
  	EXEC VDRBCKDMDADDLOG @NUM, @STAT, '发送', @OPER
    --发送关系表，限总部
    IF (@UserProperty & 16 = 16)
    BEGIN
        INSERT INTO NBckDmdSplitDtl(SRC, ID, RCV, SNDDATE, DMDSTORE, NEWNUM, SRCNUM, NEWCLS, SRCCLS, GDGID,
                NEWLINE, SRCLINE, STAT, OCRDATE, NTYPE, NSTAT)
          SELECT @SRC, @ID, @RCV, GETDATE(), DMDSTORE, NEWNUM, SRCNUM, NEWCLS, SRCCLS, GDGID,
                NEWLINE, SRCLINE, STAT, OCRDATE, 0, 0
          FROM BckDmdSplitDtl WHERE NEWNUM = @NUM AND NEWCLS = 'VDRBCKDMD'
    END

END
GO
