SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 调用时如果没有参数，则执行整体同步 */
CREATE PROCEDURE [dbo].[MOVEBILLSYNC]
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
	@SRC_VENDOR INT,
	@SRC_RECEIVER INT,
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
	@SRC_GENNUM CHAR(12),
	@SRC_SRC INT,
	@SRC_INVNUM CHAR(10)

	DECLARE @USERGID INT

	SELECT @USERGID = USERGID FROM SYSTEM

	/* 处理单张单据 */
	IF @BILL IS NOT NULL AND @CLS IS NOT NULL AND @NUM IS NOT NULL
	BEGIN
		IF @BILL = 'DIRALC' AND @CLS NOT IN ('直配出', '直配出退', '直销', '直销退')
		BEGIN
			RAISERROR('调用存储过程MOVEBILLSYNC的参数@CLS错误', 16, 1)
			RETURN(1)
		END

		IF NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM)
		BEGIN
			RAISERROR('指定的单据不存在', 16, 1)
			RETURN(1)
		END

		/* 直配出货单，直配出货退货单，直销单，直销退货单 */
		IF @BILL = 'DIRALC' AND @CLS IN ('直配出', '直配出退', '直销', '直销退')
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VENDOR = VENDOR,
			@SRC_RECEIVER = RECEIVER,
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
				RAISERROR('指定单据对应的移货单状态不合法', 16, 1)
				RETURN(0)
			END

			IF @SRC_STAT IN (1, 6, 7)
			BEGIN
				UPDATE INOUTBILL
				SET SETTLENO = @SRC_SETTLENO,
				WRH = ISNULL(@SRC_WRH, 1),
				SENDER = CASE WHEN @CLS IN ('直配出', '直销') THEN @SRC_VENDOR ELSE @SRC_RECEIVER END,
				RECEIVER = CASE WHEN @CLS IN ('直配出', '直销') THEN @SRC_RECEIVER ELSE @SRC_VENDOR END,
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
				@SRC_VENDOR = VENDOR,
				@SRC_RECEIVER = RECEIVER,
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
				SENDER = CASE WHEN @CLS IN ('直配出', '直销') THEN @SRC_VENDOR ELSE @SRC_RECEIVER END,
				RECEIVER = CASE WHEN @CLS IN ('直配出', '直销') THEN @SRC_RECEIVER ELSE @SRC_VENDOR END,
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
		END /* 直配出货单等 结束 */

		/* 提货单 */
		IF @BILL = 'RTL'
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_INVNUM = INVNUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VENDOR = 1,
			@SRC_RECEIVER = 1,
			@SRC_CHECKER = NULL,
			@SRC_CHKDATE = NULL,
			@SRC_PRECHECKER = FILLER,
			@SRC_PRECHKDATE = CREATETIME,
			@SRC_GEN = NULL,
			@SRC_GENBILL = NULL,
			@SRC_GENCLS = NULL,
			@SRC_GENNUM = NULL,
			@SRC_SRC = SRC,
			@SRC_NUM = NUM
			FROM DSP WHERE CLS = @BILL AND POSNOCLS = @CLS AND FLOWNO = @NUM

			IF @SRC_SRC = @USERGID
			BEGIN
				RAISERROR('指定的提货单是本店单据', 16, 1)
				RETURN(1)
			END

			IF @SRC_STAT = 3
			BEGIN
				DELETE FROM INOUTBILL WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
				RETURN(0)
			END

			IF @SRC_STAT IN (1, 2)
				SELECT @SRC_CHECKER = FILLER,
				@SRC_CHKDATE = FILDATE
				FROM DSPREG WHERE DSPNUM = @SRC_NUM

			UPDATE INOUTBILL
			SET INVNUM = ISNULL(@SRC_INVNUM,''),
			SETTLENO = @SRC_SETTLENO,
			WRH = ISNULL(@SRC_WRH, 1),
			SENDER = @SRC_VENDOR,
			RECEIVER = @SRC_RECEIVER,
			CHECKER = ISNULL(@SRC_CHECKER,1),
			CHKDATE = (CASE WHEN @SRC_STAT IN (1,2) THEN @SRC_CHKDATE ELSE NULL END),
			PRECHECKER = @SRC_PRECHECKER,
			PRECHKDATE = @SRC_PRECHKDATE,
			BILLSTAT = (CASE @SRC_STAT WHEN 0 THEN 2 WHEN 1 THEN 3 WHEN 2 THEN 4 END),
			GEN = @SRC_GEN,
			GENBILL = @SRC_GENBILL,
			GENCLS = @SRC_GENCLS,
			GENNUM = @SRC_GENNUM
			WHERE BILL = @BILL AND CLS = @CLS AND NUM = @NUM
		END /* 提货单 结束 */

		RETURN(0)
	END /* 处理单张单据结束*/


	/* 处理所有单据 */
	UPDATE INOUTBILL
	SET SETTLENO = A.SETTLENO,
	WRH = ISNULL(A.WRH, 1),
	SENDER = CASE WHEN A.CLS IN ('直配出', '直销') THEN A.VENDOR ELSE A.RECEIVER END,
	RECEIVER = CASE WHEN A.CLS IN ('直配出', '直销') THEN A.RECEIVER ELSE A.VENDOR END,
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
	AND A.CLS IN ('直配出', '直配出退', '直销', '直销退') AND A.STAT = 7

	INSERT INTO INOUTBILL (BILL, CLS, NUM, INVNUM, SETTLENO, WRH, SENDER, RECEIVER,
	CHECKER, CHKDATE, PRECHECKER, PRECHKDATE, BILLSTAT, GEN, GENBILL, GENCLS, GENNUM, SRC)
	SELECT 'DIRALC', CLS, NUM, '', SETTLENO, ISNULL(WRH,1),
	CASE WHEN CLS IN ('直配出', '直销') THEN VENDOR ELSE RECEIVER END,
	CASE WHEN CLS IN ('直配出', '直销') THEN RECEIVER ELSE VENDOR END,
	CHECKER, NULL, ISNULL(PRECHECKER, CHECKER), ISNULL(PRECHKDATE, FILDATE), 0,
	GEN, GENBILL, GENCLS, GENNUM, @USERGID
	FROM DIRALC
	WHERE STAT = 7 AND CLS IN ('直配出', '直配出退', '直销', '直销退')
	AND NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = 'DIRALC' AND CLS = DIRALC.CLS
	AND NUM = DIRALC.NUM)


	UPDATE INOUTBILL
	SET INVNUM = ISNULL(A.INVNUM,''),
	SETTLENO = A.SETTLENO,
	WRH = ISNULL(A.WRH, 1),
	SENDER = 1,
	RECEIVER = 1,
	CHECKER = 1,
	CHKDATE = NULL,
	PRECHECKER = A.FILLER,
	PRECHKDATE = A.CREATETIME,
	BILLSTAT = 2
	FROM DSP A
	WHERE INOUTBILL.BILL = 'RTL'
	AND INOUTBILL.BILL = A.CLS AND INOUTBILL.NUM = A.FLOWNO AND INOUTBILL.CLS = A.POSNOCLS
	AND A.STAT = 0
	AND A.SRC <> @USERGID

	INSERT INTO INOUTBILL (BILL, CLS, NUM, INVNUM, SETTLENO, WRH, SENDER, RECEIVER,
	CHECKER, CHKDATE, PRECHECKER, PRECHKDATE, BILLSTAT, SRC)
	SELECT A.CLS, A.POSNOCLS, A.FLOWNO, ISNULL(A.INVNUM,''), A.SETTLENO, ISNULL(A.WRH,1), 1, 1,
	1, NULL, A.FILLER, A.CREATETIME, 2, A.SRC
	FROM DSP A
	WHERE A.CLS = 'RTL' AND A.STAT = 0
	AND NOT EXISTS (SELECT 1 FROM INOUTBILL WHERE BILL = A.CLS AND CLS = A.POSNOCLS AND NUM = A.FLOWNO)
	AND A.SRC <> @USERGID


	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE TYPE = 'U' AND
		NAME LIKE '#INOUTBILL_DLT%')
		DROP TABLE #INOUTBILL_DLT
	CREATE TABLE #INOUTBILL_DLT (BILL CHAR (10), CLS CHAR(10), NUM CHAR(12))

	DECLARE CURSOR1 CURSOR FOR
	SELECT BILL, CLS, NUM FROM INOUTBILL
	WHERE (BILL = 'DIRALC'
	AND CLS IN ('直配出', '直配出退', '直销', '直销退')
	AND BILLSTAT = 0)
	OR (BILL = 'DSP'
	AND CLS = ''
	AND BILLSTAT IN (2, 3))
	OPEN CURSOR1
	FETCH NEXT FROM CURSOR1 INTO @IO_BILL, @IO_CLS, @IO_NUM
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @IO_BILL = 'DIRALC' AND @IO_CLS IN ('直配出', '直配出退', '直销', '直销退')
		BEGIN
			SELECT @SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VENDOR = VENDOR,
			@SRC_RECEIVER = RECEIVER,
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
				SENDER = CASE WHEN @IO_CLS IN ('直配出', '直销') THEN @SRC_VENDOR ELSE @SRC_RECEIVER END,
				RECEIVER = CASE WHEN @IO_CLS IN ('直配出', '直销') THEN @SRC_RECEIVER ELSE @SRC_VENDOR END,
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
				@SRC_VENDOR = VENDOR,
				@SRC_RECEIVER = RECEIVER,
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
				SENDER = CASE WHEN @IO_CLS IN ('直配出', '直销') THEN @SRC_VENDOR ELSE @SRC_RECEIVER END,
				RECEIVER = CASE WHEN @IO_CLS IN ('直配出', '直销') THEN @SRC_RECEIVER ELSE @SRC_VENDOR END,
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
		END /* @IO_BILL = 'DIRALC' */


		IF @IO_BILL = 'DSP' AND @IO_CLS = ''
		BEGIN
			SELECT @SRC_INVNUM = INVNUM,
			@SRC_STAT = STAT,
			@SRC_NUM = NUM,
			@SRC_SETTLENO = SETTLENO,
			@SRC_WRH = WRH,
			@SRC_VENDOR = 1,
			@SRC_RECEIVER = 1,
			@SRC_CHECKER = NULL,
			@SRC_CHKDATE = NULL,
			@SRC_PRECHECKER = FILLER,
			@SRC_PRECHKDATE = CREATETIME,
			@SRC_GEN = NULL,
			@SRC_GENBILL = NULL,
			@SRC_GENCLS = NULL,
			@SRC_GENNUM = NULL
			FROM DSP WHERE CLS = @IO_BILL AND POSNOCLS = @IO_CLS AND FLOWNO = @IO_NUM

			IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

				GOTO NEXT_LOOP
			END

			IF @SRC_STAT = 3
			BEGIN
				INSERT INTO #INOUTBILL_DLT (BILL, CLS, NUM)
				VALUES(@IO_BILL, @IO_CLS, @IO_NUM)

				GOTO NEXT_LOOP
			END

			IF @SRC_STAT IN (1, 2)
				SELECT @SRC_CHECKER = FILLER,
				@SRC_CHKDATE = FILDATE
				FROM DSPREG WHERE DSPNUM = @SRC_NUM

			UPDATE INOUTBILL
			SET INVNUM = ISNULL(@SRC_INVNUM, ''),
			SETTLENO = @SRC_SETTLENO,
			WRH = ISNULL(@SRC_WRH, 1),
			SENDER = @SRC_VENDOR,
			RECEIVER = @SRC_RECEIVER,
			CHECKER = ISNULL(@SRC_CHECKER,1),
			CHKDATE = (CASE WHEN @SRC_STAT IN (1,2) THEN @SRC_CHKDATE ELSE NULL END),
			PRECHECKER = @SRC_PRECHECKER,
			PRECHKDATE = @SRC_PRECHKDATE,
			BILLSTAT = (CASE @SRC_STAT WHEN 0 THEN 2 WHEN 1 THEN 3 WHEN 2 THEN 4 END),
			GEN = @SRC_GEN,
			GENBILL = @SRC_GENBILL,
			GENCLS = @SRC_GENCLS,
			GENNUM = @SRC_GENNUM
			WHERE BILL = @IO_BILL AND CLS = @IO_CLS AND NUM = @IO_NUM
		END


		NEXT_LOOP:
		FETCH NEXT FROM CURSOR1 INTO @IO_BILL, @IO_CLS, @IO_NUM
	END
	CLOSE CURSOR1
	DEALLOCATE CURSOR1

	DELETE FROM INOUTBILL FROM #INOUTBILL_DLT WHERE INOUTBILL.BILL = #INOUTBILL_DLT.BILL
	AND INOUTBILL.CLS = #INOUTBILL_DLT.CLS AND INOUTBILL.NUM = #INOUTBILL_DLT.NUM

END

GO