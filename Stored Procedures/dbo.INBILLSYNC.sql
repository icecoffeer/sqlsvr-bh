SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 调用时如果没有参数，则执行整体同步 */
CREATE PROCEDURE [dbo].[INBILLSYNC]
@BILL CHAR(10) = NULL,
@CLS CHAR(10) = NULL,
@NUM CHAR(12) = NULL
AS
BEGIN
	DECLARE @IO_BILL CHAR(10), @IO_CLS CHAR(10), @IO_NUM CHAR(12),
	@SRC_STAT SMALLINT,
	@SRC_NUM CHAR(10),
	@SRC_SETTLENO INT,
	@SRC_WRH INT,
	@SRC_DSPMODE SMALLINT,
	@SRC_VDRCLT INT,
	@SRC_DSPDATE DATETIME,
	@SRC_CONTACTOR VARCHAR(50),
	@SRC_TEL VARCHAR(40),
	@SRC_ADDR VARCHAR(100),
	@SRC_NEARBY VARCHAR(50),
	@SRC_CHECKER INT,
	@SRC_CHKDATE DATETIME,
	@SRC_PRECHECKER INT,
	@SRC_PRECHKDATE DATETIME,
	@SRC_GEN INT,
	@SRC_GENBILL CHAR(10),
	@SRC_GENCLS CHAR(10),
	@SRC_GENNUM CHAR(12)

	DECLARE @USERGID INT

	SELECT @USERGID = USERGID FROM SYSTEM

	/* 处理单张单据 */
	IF @BILL IS NOT NULL AND @CLS IS NOT NULL AND @NUM IS NOT NULL
	BEGIN
		IF @BILL NOT IN ('STKIN', 'STKOUTBCK', 'DIRALC', 'XF')
		BEGIN
			RAISERROR('调用存储过程INBILLSYNC的参数@BILL错误', 16, 1)
			RETURN(1)
		END

		IF @BILL = 'DIRALC' AND @CLS <> '直配进'
		BEGIN
			RAISERROR('调用存储过程INBILLSYNC的参数@CLS错误', 16, 1)
			RETURN(1)
		END

		IF NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM)
		BEGIN
			RAISERROR('指定的单据不存在', 16, 1)
			RETURN(1)
		END

		/* 进货单 */
		IF @BILL = 'STKIN'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VDRCLT = VENDOR,
			/*@SRC_DSPMODE = DSPMODE,
			@SRC_DSPDATE = DSPDATE,
			@SRC_CONTACTOR = CONTACTOR,
			@SRC_TEL = TEL,
			@SRC_ADDR = ADDR,
			@SRC_NEARBY = NEARBY,*/
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
			@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
			@SRC_GEN = GEN,
			@SRC_GENBILL = GENBILL,
			@SRC_GENCLS = GENCLS,
			@SRC_GENNUM = GENNUM
			FROM STKIN WHERE CLS = @CLS AND NUM = @NUM

			IF @@ROWCOUNT = 0
			BEGIN
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
				RETURN(0)
			END

			IF @SRC_STAT NOT IN (1, 2, 6, 7)
			BEGIN
				RAISERROR('指定单据对应的进货单状态不合法', 16, 1)
				RETURN(0)
			END

			IF @SRC_STAT IN (1, 6, 7)
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = (CASE WHEN @SRC_STAT IN (1,6) THEN @SRC_CHKDATE ELSE NULL END),
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = (CASE WHEN @SRC_STAT = 7 THEN 0 ELSE 1 END),
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM

				RETURN(0)
			END

			/* 找到修正链的终点 */
			SELECT @SRC_NUM = @NUM
			WHILE @SRC_STAT = 2
				SELECT @SRC_STAT = STAT,
				@SRC_NUM = NUM,
				@SRC_SETTLENO = SETTLENO,
				@SRC_WRH = WRH,
				@SRC_VDRCLT = VENDOR,
				/*@SRC_DSPMODE = DSPMODE,
				@SRC_DSPDATE = DSPDATE,
				@SRC_CONTACTOR = CONTACTOR,
				@SRC_TEL = TEL,
				@SRC_ADDR = ADDR,
				@SRC_NEARBY = NEARBY,*/
				@SRC_CHECKER = CHECKER,
				@SRC_CHKDATE = FILDATE,
				@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
				@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
				@SRC_GEN = GEN,
				@SRC_GENBILL = GENBILL,
				@SRC_GENCLS = GENCLS,
				@SRC_GENNUM = GENNUM
				FROM STKIN 	WHERE CLS = @CLS AND MODNUM = @SRC_NUM AND STAT IN (1, 2, 4, 6)

			IF @SRC_STAT IN (1, 6)
				UPDATE INOUTBILL
				SET NUM = @SRC_NUM,
				SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM
			ELSE
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
		END /* 进货单结束 */

		/* 出货退货单 */
		IF @BILL = 'STKOUTBCK'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VDRCLT = CLIENT,
			/*@SRC_DSPMODE = DSPMODE,
			@SRC_DSPDATE = DSPDATE,
			@SRC_CONTACTOR = BUYERNAME,
			@SRC_TEL = TEL,
			@SRC_ADDR = ADDR,
			@SRC_NEARBY = NEARBY,*/
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
			@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
			@SRC_GEN = GEN,
			@SRC_GENBILL = GENBILL,
			@SRC_GENCLS = GENCLS,
			@SRC_GENNUM = GENNUM
			FROM STKOUTBCK WHERE CLS = @CLS AND NUM = @NUM

			IF @@ROWCOUNT = 0
			BEGIN
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
				RETURN(0)
			END

			IF @SRC_STAT NOT IN (1, 2, 7)
			BEGIN
				RAISERROR('指定单据对应的出货退货单状态不合法', 16, 1)
				RETURN(0)
			END

			IF @SRC_STAT IN (1, 7)
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = (CASE WHEN @SRC_STAT = 1 THEN @SRC_CHKDATE ELSE NULL END),
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = (CASE WHEN @SRC_STAT = 7 THEN 0 ELSE 1 END),
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM

				RETURN(0)
			END

			/* 找到修正链的终点 */
			SELECT @SRC_NUM = @NUM
			WHILE @SRC_STAT = 2
				SELECT @SRC_STAT = STAT,
				@SRC_NUM = NUM,
				@SRC_SETTLENO = SETTLENO,
				@SRC_WRH = WRH,
				@SRC_VDRCLT = CLIENT,
				/*@SRC_DSPMODE = DSPMODE,
				@SRC_DSPDATE = DSPDATE,
				@SRC_CONTACTOR = BUYERNAME,
				@SRC_TEL = TEL,
				@SRC_ADDR = ADDR,
				@SRC_NEARBY = NEARBY,*/
				@SRC_CHECKER = CHECKER,
				@SRC_CHKDATE = FILDATE,
				@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
				@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
				@SRC_GEN = GEN,
				@SRC_GENBILL = GENBILL,
				@SRC_GENCLS = GENCLS,
				@SRC_GENNUM = GENNUM
				FROM STKOUTBCK WHERE CLS = @CLS AND MODNUM = @SRC_NUM AND STAT IN (1, 2, 4)

			IF @SRC_STAT = 1
				UPDATE INOUTBILL
				SET NUM = @SRC_NUM,
				SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM
			ELSE
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
		END /* 出货退货单结束 */

		/* 直配进货单 */
		IF @BILL = 'DIRALC' AND @CLS = '直配进'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VDRCLT = VENDOR,
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
			@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
			@SRC_GEN = GEN,
			@SRC_GENBILL = GENBILL,
			@SRC_GENCLS = GENCLS,
			@SRC_GENNUM = GENNUM
			FROM DIRALC WHERE CLS = @CLS AND NUM = @NUM

			IF @@ROWCOUNT = 0
			BEGIN
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
				RETURN(0)
			END

			IF @SRC_STAT NOT IN (1, 2, 6, 7)
			BEGIN
				RAISERROR('指定单据对应的直配进货单状态不合法', 16, 1)
				RETURN(0)
			END

			IF @SRC_STAT IN (1, 6, 7)
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				CHECKER = @SRC_CHECKER,
				CHKDATE = (CASE WHEN @SRC_STAT IN (1,6) THEN @SRC_CHKDATE ELSE NULL END),
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = (CASE WHEN @SRC_STAT = 7 THEN 0 ELSE 1 END),
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM

				RETURN(0)
			END

			/* 找到修正链的终点 */
			SELECT @SRC_NUM = @NUM
			WHILE @SRC_STAT = 2
				SELECT @SRC_STAT = STAT,
				@SRC_NUM = NUM,
				@SRC_SETTLENO = SETTLENO,
				@SRC_WRH = WRH,
				@SRC_VDRCLT = VENDOR,
				@SRC_CHECKER = CHECKER,
				@SRC_CHKDATE = FILDATE,
				@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
				@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
				@SRC_GEN = GEN,
				@SRC_GENBILL = GENBILL,
				@SRC_GENCLS = GENCLS,
				@SRC_GENNUM = GENNUM
				FROM DIRALC WHERE CLS = @CLS AND MODNUM = @SRC_NUM AND STAT IN (1, 2, 4, 6)

			IF @SRC_STAT IN (1, 6)
				UPDATE INOUTBILL
				SET NUM = @SRC_NUM,
				SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM
			ELSE
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
		END /* 直配进货单结束 */

		/* 内部调拨单 */
		IF @BILL = 'XF'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = TOWRH,
			@SRC_VDRCLT = FROMWRH,
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = CHECKER,
			@SRC_PRECHKDATE = FILDATE,
			@SRC_GEN = NULL,
			@SRC_GENBILL = NULL,
			@SRC_GENCLS = NULL,
			@SRC_GENNUM = NULL
			FROM XF WHERE NUM = @NUM

			IF @@ROWCOUNT = 0
			BEGIN
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
				RETURN(0)
			END

			IF @SRC_STAT NOT IN (8,9)
			BEGIN
				RAISERROR('指定单据对应的内部调拨单状态不合法', 16, 1)
				RETURN(0)
			END

			IF @SRC_STAT = 8
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 0,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @BILL AND INOUTBILL.CLS = @CLS
				AND INOUTBILL.NUM = @NUM

			IF @SRC_STAT = 9
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM

		END /* 内部调拨单结束 */

		RETURN(0)
	END /* 处理单张单据结束*/


	/* 处理所有单据 */
	UPDATE INOUTBILL
	SET SETTLENO = A.SETTLENO,
	WRH = ISNULL(A.WRH, 1),
	SENDER = A.VENDOR,
	/*DSPMODE = A.DSPMODE,
	DSPDATE = A.DSPDATE,
	CONTACTOR = A.CONTACTOR,
	CTRPHONE = A.TEL,
	ADDR = A.ADDR,
	NEARBY = A.NEARBY,*/
	CHECKER = A.CHECKER,
	CHKDATE = NULL,
	PRECHECKER = ISNULL(A.PRECHECKER, A.CHECKER),
	PRECHKDATE = ISNULL(A.PRECHKDATE, A.FILDATE),
	BILLSTAT = 0,
	GEN = A.GEN,
	GENBILL = A.GENBILL,
	GENCLS = A.GENCLS,
	GENNUM = A.GENNUM
	FROM STKIN A
	WHERE INOUTBILL.BILL = 'STKIN' AND INOUTBILL.CLS = A.CLS AND INOUTBILL.NUM = A.NUM
	AND A.STAT = 7

	INSERT INTO INOUTBILL (BILL, CLS, NUM, INVNUM, SETTLENO, WRH, SENDER, RECEIVER, /*DSPMODE,
	DSPDATE, CONTACTOR, CTRPHONE, ADDR, NEARBY,*/ CHECKER, CHKDATE, PRECHECKER, PRECHKDATE,
	BILLSTAT, GEN, GENBILL, GENCLS, GENNUM, SRC)
	SELECT 'STKIN', CLS, NUM, '', SETTLENO, ISNULL(WRH,1), VENDOR, 1, /*DSPMODE, DSPDATE,
	CONTACTOR, TEL, ADDR, NEARBY,*/ CHECKER, NULL, ISNULL(PRECHECKER, CHECKER), ISNULL(PRECHKDATE, FILDATE), 0,
	GEN, GENBILL, GENCLS, GENNUM, @USERGID
	FROM STKIN
	WHERE STAT = 7
	AND NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = 'STKIN' AND CLS = STKIN.CLS
	AND NUM = STKIN.NUM)

	UPDATE INOUTBILL
	SET SETTLENO = A.SETTLENO,
	WRH = ISNULL(A.WRH, 1),
	SENDER = A.CLIENT,
	/*DSPMODE = A.DSPMODE,
	DSPDATE = A.DSPDATE,
	CONTACTOR = A.BUYERNAME,
	CTRPHONE = A.TEL,
	ADDR = A.ADDR,
	NEARBY = A.NEARBY,*/
	CHECKER = A.CHECKER,
	CHKDATE = NULL,
	PRECHECKER = ISNULL(A.PRECHECKER, A.CHECKER),
	PRECHKDATE = ISNULL(A.PRECHKDATE, A.FILDATE),
	BILLSTAT = 0,
	GEN = A.GEN,
	GENBILL = A.GENBILL,
	GENCLS = A.GENCLS,
	GENNUM = A.GENNUM
	FROM STKOUTBCK A
	WHERE INOUTBILL.BILL = 'STKOUTBCK' AND INOUTBILL.CLS = A.CLS AND INOUTBILL.NUM = A.NUM
	AND A.STAT = 7

	INSERT INTO INOUTBILL (BILL, CLS, NUM, INVNUM, SETTLENO, WRH, SENDER, RECEIVER, /*DSPMODE,
	DSPDATE, CONTACTOR, CTRPHONE, ADDR, NEARBY,*/ CHECKER, CHKDATE, PRECHECKER, PRECHKDATE,
	BILLSTAT, GEN, GENBILL, GENCLS, GENNUM, SRC)
	SELECT 'STKOUTBCK', CLS, NUM, '', SETTLENO, ISNULL(WRH,1), CLIENT, 1, /*DSPMODE, DSPDATE,
	BUYERNAME, TEL, ADDR, NEARBY,*/ CHECKER, NULL, ISNULL(PRECHECKER, CHECKER), ISNULL(PRECHKDATE, FILDATE), 0,
	GEN, GENBILL, GENCLS, GENNUM, @USERGID
	FROM STKOUTBCK
	WHERE STAT = 7
	AND NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = 'STKOUTBCK' AND CLS = STKOUTBCK.CLS
	AND NUM = STKOUTBCK.NUM)

	UPDATE INOUTBILL
	SET SETTLENO = A.SETTLENO,
	WRH = ISNULL(A.WRH, 1),
	SENDER = A.VENDOR,
	CHECKER = A.CHECKER,
	CHKDATE = NULL,
	PRECHECKER = ISNULL(A.PRECHECKER, A.CHECKER),
	PRECHKDATE = ISNULL(A.PRECHKDATE, A.FILDATE),
	BILLSTAT = 0,
	GEN = A.GEN,
	GENBILL = A.GENBILL,
	GENCLS = A.GENCLS,
	GENNUM = A.GENNUM
	FROM DIRALC A
	WHERE INOUTBILL.BILL = 'DIRALC' AND INOUTBILL.CLS = A.CLS AND INOUTBILL.NUM = A.NUM
	AND A.CLS = '直配进' AND A.STAT = 7

	INSERT INTO INOUTBILL (BILL, CLS, NUM, INVNUM, SETTLENO, WRH, SENDER, RECEIVER,
	CHECKER, CHKDATE, PRECHECKER, PRECHKDATE, BILLSTAT, GEN, GENBILL, GENCLS, GENNUM, SRC)
	SELECT 'DIRALC', CLS, NUM, '', SETTLENO, ISNULL(WRH,1), VENDOR, 1,
	CHECKER, NULL, ISNULL(PRECHECKER, CHECKER), ISNULL(PRECHKDATE, FILDATE), 0,
	GEN, GENBILL, GENCLS, GENNUM, @USERGID
	FROM DIRALC
	WHERE STAT = 7 AND CLS = '直配进'
	AND NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = 'DIRALC' AND CLS = DIRALC.CLS
	AND NUM = DIRALC.NUM)

	UPDATE INOUTBILL
	SET SETTLENO = A.SETTLENO,
	WRH = ISNULL(A.TOWRH, 1),
	SENDER = A.FROMWRH,
	CHECKER = A.CHECKER,
	CHKDATE = A.FILDATE,
	PRECHECKER = A.CHECKER,
	PRECHKDATE = A.FILDATE,
	BILLSTAT = 0,
	GEN = NULL,
	GENBILL = NULL,
	GENCLS = NULL,
	GENNUM = NULL
	FROM XF A
	WHERE INOUTBILL.BILL = 'XF' AND INOUTBILL.CLS = '' AND INOUTBILL.NUM = A.NUM
	AND A.STAT = 8

	INSERT INTO INOUTBILL (BILL, CLS, NUM, INVNUM, SETTLENO, WRH, SENDER, RECEIVER,
	CHECKER, CHKDATE, PRECHECKER, PRECHKDATE, BILLSTAT,
	GEN, GENBILL, GENCLS, GENNUM, SRC)
	SELECT 'XF', '', NUM, '', SETTLENO, ISNULL(TOWRH,1), FROMWRH, 1,
	CHECKER, FILDATE, CHECKER, FILDATE, 0,
	NULL, NULL, NULL, NULL, @USERGID
	FROM XF
	WHERE STAT = 8
	AND NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = 'XF' AND CLS = ''
	AND NUM = XF.NUM)

	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE TYPE = 'U' AND
		NAME LIKE '#INOUTBILL_DLT%')
		DROP TABLE #INOUTBILL_DLT
	CREATE TABLE #INOUTBILL_DLT (BILL CHAR (10), CLS CHAR(10), NUM CHAR(12))

	DECLARE CURSOR1 CURSOR FOR
	SELECT BILL, CLS, NUM FROM INOUTBILL WHERE (BILL IN ('STKIN', 'STKOUTBCK', 'XF')
	OR (BILL = 'DIRALC' AND CLS = '直配进'))
	AND BILLSTAT = 0
	OPEN CURSOR1
	FETCH NEXT FROM CURSOR1 INTO @IO_BILL, @IO_CLS, @IO_NUM
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @IO_BILL = 'STKIN'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VDRCLT = VENDOR,
			/*@SRC_DSPMODE = DSPMODE,
			@SRC_DSPDATE = DSPDATE,
			@SRC_CONTACTOR = CONTACTOR,
			@SRC_TEL = TEL,
			@SRC_ADDR = ADDR,
			@SRC_NEARBY = NEARBY,*/
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
			@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
			@SRC_GEN = GEN,
			@SRC_GENBILL = GENBILL,
			@SRC_GENCLS = GENCLS,
			@SRC_GENNUM = GENNUM
			FROM STKIN WHERE CLS = @IO_CLS AND NUM = @IO_NUM

			IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

				GOTO NEXT_LOOP
			END

			IF @SRC_STAT NOT IN (1, 2, 6)
				GOTO NEXT_LOOP

			IF @SRC_STAT IN (1, 6)
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM

				GOTO NEXT_LOOP
			END

			SELECT @SRC_NUM = @IO_NUM
			WHILE @SRC_STAT = 2
				SELECT @SRC_STAT = STAT,
				@SRC_NUM = NUM,
				@SRC_SETTLENO = SETTLENO,
				@SRC_WRH = WRH,
				@SRC_VDRCLT = VENDOR,
				/*@SRC_DSPMODE = DSPMODE,
				@SRC_DSPDATE = DSPDATE,
				@SRC_CONTACTOR = CONTACTOR,
				@SRC_TEL = TEL,
				@SRC_ADDR = ADDR,
				@SRC_NEARBY = NEARBY,*/
				@SRC_CHECKER = CHECKER,
				@SRC_CHKDATE = FILDATE,
				@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
				@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
				@SRC_GEN = GEN,
				@SRC_GENBILL = GENBILL,
				@SRC_GENCLS = GENCLS,
				@SRC_GENNUM = GENNUM
				FROM STKIN WHERE CLS = @IO_CLS AND MODNUM = @SRC_NUM AND STAT IN (1, 2, 4, 6)

			IF @SRC_STAT IN (1, 6)
				UPDATE INOUTBILL
				SET NUM = @SRC_NUM,
				SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM
			ELSE
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)
		END /* @IO_BILL = 'STKIN' */

		IF @IO_BILL = 'STKOUTBCK'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VDRCLT = CLIENT,
			/*@SRC_DSPMODE = DSPMODE,
			@SRC_DSPDATE = DSPDATE,
			@SRC_CONTACTOR = BUYERNAME,
			@SRC_TEL = TEL,
			@SRC_ADDR = ADDR,
			@SRC_NEARBY = NEARBY,*/
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
			@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
			@SRC_GEN = GEN,
			@SRC_GENBILL = GENBILL,
			@SRC_GENCLS = GENCLS,
			@SRC_GENNUM = GENNUM
			FROM STKOUTBCK WHERE CLS = @IO_CLS AND NUM = @IO_NUM

			IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

				GOTO NEXT_LOOP
			END

			IF @SRC_STAT NOT IN (1, 2)
				GOTO NEXT_LOOP

			IF @SRC_STAT = 1
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM

				GOTO NEXT_LOOP
			END

			SELECT @SRC_NUM = @IO_NUM
			WHILE @SRC_STAT = 2
				SELECT @SRC_STAT = STAT,
				@SRC_NUM = NUM,
				@SRC_SETTLENO = SETTLENO,
				@SRC_WRH = WRH,
				@SRC_VDRCLT = CLIENT,
				/*@SRC_DSPMODE = DSPMODE,
				@SRC_DSPDATE = DSPDATE,
				@SRC_CONTACTOR = BUYERNAME,
				@SRC_TEL = TEL,
				@SRC_ADDR = ADDR,
				@SRC_NEARBY = NEARBY,*/
				@SRC_CHECKER = CHECKER,
				@SRC_CHKDATE = FILDATE,
				@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
				@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
				@SRC_GEN = GEN,
				@SRC_GENBILL = GENBILL,
				@SRC_GENCLS = GENCLS,
				@SRC_GENNUM = GENNUM
				FROM STKOUTBCK WHERE CLS = @IO_CLS AND MODNUM = @SRC_NUM AND STAT IN (1, 2, 4, 6)

			IF @SRC_STAT = 1
				UPDATE INOUTBILL
				SET NUM = @SRC_NUM,
				SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				/*DSPMODE = @SRC_DSPMODE,
				DSPDATE = @SRC_DSPDATE,
				CONTACTOR = @SRC_CONTACTOR,
				CTRPHONE = @SRC_TEL,
				ADDR = @SRC_ADDR,
				NEARBY = @SRC_NEARBY,*/
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM
			ELSE
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)
		END /* @IO_BILL = 'STKOUTBCK' */

		IF @IO_BILL = 'DIRALC' AND @IO_CLS = '直配进'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VDRCLT = VENDOR,
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
			@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
			@SRC_GEN = GEN,
			@SRC_GENBILL = GENBILL,
			@SRC_GENCLS = GENCLS,
			@SRC_GENNUM = GENNUM
			FROM DIRALC WHERE CLS = @IO_CLS AND NUM = @IO_NUM

			IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

				GOTO NEXT_LOOP
			END

			IF @SRC_STAT NOT IN (1, 2, 6)
				GOTO NEXT_LOOP

			IF @SRC_STAT IN (1, 6)
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM

				GOTO NEXT_LOOP
			END

			SELECT @SRC_NUM = @IO_NUM
			WHILE @SRC_STAT = 2
				SELECT @SRC_STAT = STAT,
				@SRC_NUM = NUM,
				@SRC_SETTLENO = SETTLENO,
				@SRC_WRH = WRH,
				@SRC_VDRCLT = VENDOR,
				@SRC_CHECKER = CHECKER,
				@SRC_CHKDATE = FILDATE,
				@SRC_PRECHECKER = ISNULL(PRECHECKER, CHECKER),
				@SRC_PRECHKDATE = ISNULL(PRECHKDATE, FILDATE),
				@SRC_GEN = GEN,
				@SRC_GENBILL = GENBILL,
				@SRC_GENCLS = GENCLS,
				@SRC_GENNUM = GENNUM
				FROM DIRALC WHERE CLS = @IO_CLS AND MODNUM = @SRC_NUM AND STAT IN (1, 2, 4, 6)

			IF @SRC_STAT IN (1, 6)
				UPDATE INOUTBILL
				SET NUM = @SRC_NUM,
				SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 1,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM
			ELSE
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)
		END /* @IO_BILL = 'DIRALC' AND @IO_CLS = '直配进' */

		IF @IO_BILL = 'XF'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = TOWRH,
			@SRC_VDRCLT = FROMWRH,
			@SRC_CHECKER = CHECKER,
			@SRC_CHKDATE = FILDATE,
			@SRC_PRECHECKER = CHECKER,
			@SRC_PRECHKDATE = FILDATE,
			@SRC_GEN = NULL,
			@SRC_GENBILL = NULL,
			@SRC_GENCLS = NULL,
			@SRC_GENNUM = NULL
			FROM XF WHERE NUM = @IO_NUM

			IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

				GOTO NEXT_LOOP
			END

			IF @SRC_STAT NOT IN (8,9)
				GOTO NEXT_LOOP

			IF @SRC_STAT = 8
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = @SRC_VDRCLT,
				CHECKER = @SRC_CHECKER,
				CHKDATE = @SRC_CHKDATE,
				PRECHECKER = @SRC_PRECHECKER,
				PRECHKDATE = @SRC_PRECHKDATE,
				BILLSTAT = 0,
				GEN = @SRC_GEN,
				GENBILL = @SRC_GENBILL,
				GENCLS = @SRC_GENCLS,
				GENNUM = @SRC_GENNUM
				WHERE INOUTBILL.BILL = @IO_BILL AND INOUTBILL.CLS = @IO_CLS
				AND INOUTBILL.NUM = @IO_NUM

			IF @SRC_STAT = 9
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

		END /* @IO_BILL = 'XF' */

		NEXT_LOOP:
		FETCH NEXT FROM CURSOR1 INTO @IO_BILL, @IO_CLS, @IO_NUM
	END
	CLOSE CURSOR1
	DEALLOCATE CURSOR1

	DELETE FROM INOUTBILL FROM #INOUTBILL_DLT WHERE INOUTBILL.BILL = #INOUTBILL_DLT.BILL
	AND INOUTBILL.CLS = #INOUTBILL_DLT.CLS AND INOUTBILL.NUM = #INOUTBILL_DLT.NUM

END

GO
