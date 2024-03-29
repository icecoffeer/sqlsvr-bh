SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GENPAY]
(
	@PIOPERGID	INTEGER,
	@PLANDATE	DATETIME,
	@BALUNIT	INT,
	@MSG		VARCHAR(255)	OUTPUT
)
AS
BEGIN
	DECLARE @VDRGID INT
	DECLARE @P_VDRGID INT
	DECLARE @CHGTYPE VARCHAR(30)
	DECLARE @IVCCODE CHAR(14)
	DECLARE @OCRDATE DATETIME
	DECLARE @PAYDATE DATETIME
	DECLARE @TOTAL	MONEY
	DECLARE @ACTTOTAL MONEY
	DECLARE @CURTOTAL MONEY
	DECLARE @NOTE VARCHAR(255)
	DECLARE @NUM	CHAR(14)
	DECLARE @LINE	INT
	DECLARE @SETTLENO	INT
	DECLARE @SALETOTAL	MONEY
	DECLARE @FEETOTAL	MONEY
	DECLARE @PREPAYTOTAL	MONEY
	DECLARE @PSR INT
	DECLARE @DEPT CHAR(10)
	DECLARE @P_DEPT CHAR(10)
  DECLARE @TAXRATE MONEY
  DECLARE @P_TAXRATE MONEY
	DECLARE @DEPTLIMIT	INT
  DECLARE @TAXRATELIMIT INT
	DECLARE @VSQL VARCHAR(1000)
	DECLARE @DEFPAYCODE VARCHAR(20) --缺省付款方式
  DECLARE @OPER VARCHAR(50)
  declare @ChkVdrPayCode varchar(1)
  DECLARE @TRANER INT
  DECLARE @BLinkPsrAndTran INT

	SELECT @SETTLENO = MAX(NO) FROM MONTHSETTLE(NOLOCK) 
	DELETE FROM TMPGENBILLS WHERE SPID = @@SPID
  SELECT @OPER = RTRIM(NAME) + '[' + RTRIM(CODE) + ']'
  FROM EMPLOYEE(NOLOCK) WHERE GID = @PIOPERGID

	SELECT @P_VDRGID = NULL
	SELECT @LINE = 0, @SALETOTAL = 0, @FEETOTAL = 0, @PREPAYTOTAL = 0
	IF OBJECT_ID('C_TMPPAY') IS NOT NULL DEALLOCATE C_TMPPAY
	EXEC OPTREADINT 0,'SettleDeptLimit',0,@DEPTLIMIT OUTPUT
  EXEC OPTREADINT 0, '付款分税率', 0, @TAXRATELIMIT OUTPUT
	EXEC OPTREADSTR 3108,'DefPayCode','',@DEFPAYCODE OUTPUT
	EXEC OPTREADSTR 3108,'ChkVdrPayCode','0',@ChkVdrPayCode OUTPUT
	EXEC OPTREADSTR 3108,'BLinkPsrAndTran','0',@BLinkPsrAndTran OUTPUT
	IF @DEPTLIMIT = 1
  BEGIN
    IF @TAXRATELIMIT = 1
  		SELECT @VSQL = 'DECLARE C_TMPPAY CURSOR FOR '
	  		+ ' SELECT VDRGID, CHGTYPE, IVCCODE, OCRDATE, PAYDATE, TOTAL, ACTTOTAL, CURTOTAL, NOTE, PSR, DEPT, TAXRATE'
		  	+ ' FROM TMPPAY WHERE SPID = @@SPID AND CURTOTAL <> 0 '
			  + ' ORDER BY VDRGID, DEPT, TAXRATE'
    ELSE
  		SELECT @VSQL = 'DECLARE C_TMPPAY CURSOR FOR '
	  		+ ' SELECT VDRGID, CHGTYPE, IVCCODE, OCRDATE, PAYDATE, TOTAL, ACTTOTAL, CURTOTAL, NOTE, PSR, DEPT, TAXRATE'
		  	+ ' FROM TMPPAY WHERE SPID = @@SPID AND CURTOTAL <> 0 '
			  + ' ORDER BY VDRGID, DEPT'
	END ELSE
  BEGIN
    IF @TAXRATELIMIT = 1
      SELECT @VSQL = 'DECLARE C_TMPPAY CURSOR FOR '
        + ' SELECT VDRGID, CHGTYPE, IVCCODE, OCRDATE, PAYDATE, TOTAL, ACTTOTAL, CURTOTAL, NOTE, PSR, DEPT, TAXRATE'
        + ' FROM TMPPAY WHERE SPID = @@SPID AND CURTOTAL <> 0'
        + ' ORDER BY VDRGID, TAXRATE'
    ELSE
      SELECT @VSQL = 'DECLARE C_TMPPAY CURSOR FOR '
        + ' SELECT VDRGID, CHGTYPE, IVCCODE, OCRDATE, PAYDATE, TOTAL, ACTTOTAL, CURTOTAL, NOTE, PSR, DEPT, TAXRATE'
        + ' FROM TMPPAY WHERE SPID = @@SPID AND CURTOTAL <> 0'
        + ' ORDER BY VDRGID'
  END
	EXEC(@VSQL)
        DECLARE @UGID INT
        SELECT @UGID = USERGID FROM FASYSTEM
	OPEN C_TMPPAY
	FETCH NEXT FROM C_TMPPAY INTO @VDRGID, @CHGTYPE, @IVCCODE, @OCRDATE, @PAYDATE, @TOTAL, @ACTTOTAL, @CURTOTAL, @NOTE, @PSR, @DEPT, @TAXRATE
	WHILE @@FETCH_STATUS = 0
	BEGIN
    IF @TAXRATE IS NULL 
      SET @TAXRATE = 17
		IF (@P_VDRGID IS NULL) 
      OR (@VDRGID <> @P_VDRGID) 
      OR ((@DEPTLIMIT = 1) AND (@DEPT <> @P_DEPT))
      OR ((@TAXRATELIMIT = 1) AND (@TAXRATE <> @P_TAXRATE))
		BEGIN
			IF @P_VDRGID IS NOT NULL
			BEGIN
				UPDATE CNTRPAYCASH SET 
					PAYTOTAL = @SALETOTAL - @FEETOTAL - @PREPAYTOTAL,
					SALETOTAL = @SALETOTAL,
					FEETOTAL = @FEETOTAL,
					PREPAYTOTAL = @PREPAYTOTAL
				WHERE NUM = @NUM
				UPDATE TMPGENBILLS SET
					FINISHTIME = GETDATE(),
					STAT = 1,
					DTLCNT = @LINE
				WHERE OWNER = '付款选择' AND BILLNAME = '付款单' AND NUM = @NUM
			END

			EXEC GENNEXTBILLNUMEX NULL, 'CNTRPAYCASH', @NUM OUTPUT
			INSERT INTO TMPGENBILLS(SPID, OWNER, BILLNAME, NUM, DTLCNT, STARTTIME, STAT)
			VALUES(@@SPID, '付款选择', '付款单', @NUM, 0, GETDATE(), 0)
			--added by jinlei
			if @ChkVdrPayCode = '1' 
			  select @DEFPAYCODE = s.code from vendor v(nolock), SETTLEACCOUNT s(nolock) 
			  where v.gid = @VDRGID and v.SETTLEACCOUNT = s.name 
			--end added
			if @BLinkPsrAndTran = 1 
			  set @TRANER = @PSR
			else
			  set @TRANER = 1
			INSERT INTO CNTRPAYCASH(NUM, SETTLENO, FILLER, FILDATE, OCRDATE, VDRGID, TRANSACTOR, NOTE, STAT, PRNTIME,
			PAYTOTAL, SALETOTAL, FEETOTAL, PREPAYTOTAL, SETTLEACCOUNTNO, LSTUPDTIME, PLANDATE, FROMDATE, 
			TODATE, PSR, DEPT, BTYPE, BALUNIT,SRC,SENDCOUNT, TAXRATE)
			VALUES(@NUM, @SETTLENO, @OPER, GETDATE(), GETDATE(), @VDRGID, @TRANER, NULL, 0, NULL,
			0, 0, 0, 0, @DEFPAYCODE, GETDATE(), @PLANDATE, NULL, NULL, @PSR, @DEPT, 1, @BALUNIT, @UGID, 0, @TAXRATE)
			SELECT @LINE = 0, @SALETOTAL = 0, @FEETOTAL = 0, @PREPAYTOTAL = 0
		END
		
		SELECT @LINE = @LINE + 1
		IF (@CHGTYPE = '供应商结算单') OR (@CHGTYPE = '代销结算单') OR (@CHGTYPE = '联销结算单')
			SELECT @SALETOTAL = @SALETOTAL + @CURTOTAL --@TOTAL  sz modified
		ELSE IF @CHGTYPE = '费用单'
			SELECT @FEETOTAL = @FEETOTAL + @CURTOTAL  -- sz modified
		ELSE IF @CHGTYPE = '预付款单'
			SELECT @PREPAYTOTAL = @PREPAYTOTAL + @CURTOTAL --@TOTAL  sz modified
		INSERT INTO CNTRPAYCASHDTL(NUM, LINE, CHGTYPE, IVCNUM, IVCCODE, TOTALBAL, IVCAMT, IVCPAY, PAYTOTAL, NOTE)
		VALUES(@NUM, @LINE, @CHGTYPE, NULL, @IVCCODE, @ACTTOTAL, @TOTAL, @TOTAL-@ACTTOTAL, @CURTOTAL, @NOTE)

		SELECT @P_VDRGID = @VDRGID
		SELECT @P_DEPT = @DEPT
    SELECT @P_TAXRATE = @TAXRATE
		FETCH NEXT FROM C_TMPPAY INTO @VDRGID, @CHGTYPE, @IVCCODE, @OCRDATE, @PAYDATE, @TOTAL, @ACTTOTAL, @CURTOTAL, @NOTE, @PSR, @DEPT, @TAXRATE
		IF @@FETCH_STATUS <> 0
		BEGIN
			UPDATE CNTRPAYCASH SET 
				PAYTOTAL = @SALETOTAL - @FEETOTAL - @PREPAYTOTAL,
				SALETOTAL = @SALETOTAL,
				FEETOTAL = @FEETOTAL,
				PREPAYTOTAL = @PREPAYTOTAL
			WHERE NUM = @NUM
			UPDATE TMPGENBILLS SET
				FINISHTIME = GETDATE(),
				STAT = 1,
				DTLCNT = @LINE
			WHERE OWNER = '付款选择' AND BILLNAME = '付款单' AND NUM = @NUM
		END
	END
	CLOSE C_TMPPAY
	DEALLOCATE C_TMPPAY
	
	RETURN 0
END
GO
