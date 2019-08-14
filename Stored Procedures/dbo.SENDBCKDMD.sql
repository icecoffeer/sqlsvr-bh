SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SENDBCKDMD]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
) --with encryption
AS
BEGIN
  	DECLARE
   		@SRC INT,		@CHKSTOREGID INT,	@STAT SMALLINT,
   		@ID INT,		@USERGID INT,		@USEINVCHGRELQTY INT,
		@DMDSTORE INT,		@RCV INT,		@EXP DATETIME,
		@FROMSRC INT,   @UserProperty INT

	EXEC OPTREADINT 0,'UseInvChgRelQty',0,@UseInvChgRelQty OUTPUT
	SELECT @STAT = STAT, @SRC = SRC, @CHKSTOREGID = CHKSTOREGID, @EXP = EXPDATE, @DMDSTORE = DMDSTORE
   		FROM BCKDMD WHERE  NUM = @NUM
	SELECT @USERPROPERTY = USERPROPERTY, @USERGID = USERGID FROM SYSTEM

  IF @STAT <> 401 AND @STAT <> 400 AND @STAT <> 411 AND @STAT <> 410 AND @STAT <> 1600 AND @STAT <> 3000 AND @STAT <> 3100  --2005.7.18, Edited by ShenMin, 增加"预审"状态
	BEGIN
         	SET @MSG = '发送的单据不是已预审、请求总部批准、总部批准或申请作废、审批后作废、待退货'
         	RETURN(1)
  END
  /*只检查401下的单据，其他状态允许发送*/
	IF @STAT IN (401) AND (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
	BEGIN
		SET @MSG = '单据' + @NUM + '已经超过到效日期'
		RETURN 1
	END
	IF (@DMDSTORE = @USERGID) AND (@STAT NOT IN (401, 411, 410, 3100) )  --ShenMin
	BEGIN
		SET @MSG = '报批单位，单据' + @NUM + '状态为非申请总部批准、批准作废、待退货，不能发送。'
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

	IF @STAT = 401
	BEGIN
		IF @SRC <> @USERGID OR @SRC <> @DMDSTORE --@CHKSTOREGID = @USERGID
		BEGIN
			SET @MSG = '发送的请求总部批准单据不是本单位生成的'
			return(1)
		END
		SET @RCV = @CHKSTOREGID
		SET @FROMSRC = @SRC
	END
	ELSE
	BEGIN
		IF @DMDSTORE = @USERGID
		BEGIN
			--SET @MSG = '报批单位为自己的单位不能发送除结束状态下的申请单.'
			--RETURN(1)
			SET @RCV = @CHKSTOREGID
			SET @FROMSRC = @DMDSTORE
		END ELSE
		BEGIN
		  SET @RCV = @DMDSTORE
		  SET @FROMSRC = @CHKSTOREGID
		END
	END

	EXECUTE GETNETBILLID @ID OUTPUT
	INSERT INTO NBCKDMD (ID, SRC, RCV, NUM, SETTLENO, RECCNT,
		NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE, PSR, PSRGID, BCKCLS,
		CANCELER, EXPDATE, STAT, BEGINDATE,
		SNDDATE, RCVTIME, NTYPE, NSTAT, NNOTE,DMDSTORE,SRCNUM)
	SELECT @ID, @USERGID, @RCV, NUM, SETTLENO, RECCNT,
		NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE, PSR, PSRGID, BCKCLS,
		CANCELER, EXPDATE, STAT, BEGINDATE,
		GETDATE(), NULL, 0, 0, NULL, DMDSTORE, SRCNUM
      	FROM BCKDMD
	WHERE NUM = @NUM
	IF @@ERROR <> 0
	BEGIN
		SET @MSG = '发送'+@NUM+'单据失败'
		RETURN(1)
	END
	--开始发送
	--为慈客隆定制 小商品->大商品
	IF @UseInvChgRelQty = 1
	BEGIN
		INSERT INTO NBCKDMDDTL (SRC, ID, NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY)
      		SELECT @USERGID, @ID, D.NUM, D.LINE, ISNULL(I.GDGID, D.GDGID) GDGID,
      			D.CASES, ISNULL(D.QTY/I.RELQTY,D.QTY) QTY,
      			D.DMDCASES, ISNULL(D.DMDQTY / I.RELQTY,D.DMDQTY) DMDQTY,
      			D.NOTE, D.CHECKED, D.INV, BCKEDQTY  --2003.11.26 1422
      		FROM BCKDMDDTL D, INVCHG I(NOLOCK)
		WHERE NUM = @NUM AND D.GDGID *= I.GDGID2

		UPDATE BCKDMDDTL SET CASES = QTY / G.QPC, DMDCASES = DMDQTY / G.QPC
		FROM GOODS G(NOLOCK) WHERE BCKDMDDTL.GDGID = G.GID
		AND BCKDMDDTL.NUM = @NUM AND BCKDMDDTL.GDGID IN(SELECT GDGID FROM INVCHG(NOLOCK))
	END
	ELSE
	BEGIN
		INSERT INTO NBCKDMDDTL (SRC, ID, NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY)
      		SELECT @USERGID, @ID, NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY  --FDY 2003.11.26 1422 ADD FDY
      		FROM BCKDMDDTL
		WHERE NUM = @NUM
	END
	IF @@ERROR <> 0
	BEGIN
		SET @MSG = '发送'+@NUM+'单据失败'
		RETURN(1)
	END
	UPDATE BCKDMD SET SNDDATE = GETDATE() WHERE NUM = @NUM
	EXEC BCKDMDADDLOG @NUM, @STAT, '发送', @OPER
	--发送关系表，限总部
	IF (@UserProperty & 16 = 16)
	BEGIN
		INSERT INTO NBckDmdSplitDtl(SRC, ID, RCV, SNDDATE, DMDSTORE, NEWNUM, SRCNUM, NEWCLS, SRCCLS, GDGID,
			NEWLINE, SRCLINE, STAT, OCRDATE, NTYPE, NSTAT)
		SELECT @USERGID, @ID, @RCV, GETDATE(), DMDSTORE, NEWNUM, SRCNUM, NEWCLS, SRCCLS, GDGID,
			NEWLINE, SRCLINE, STAT, OCRDATE, 0 ,0
		FROM BckDmdSplitDtl WHERE NEWNUM = @NUM AND NEWCLS = 'BCKDMD'
	END
	--ShenMin
	if ((select Optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'UseNewAlcBckFlow')) = 1)
	  and ((select stat FROM BCKDMD where NUM=@NUM) = 3100)
	begin
		INSERT INTO NBCKDMDDTLDTL(NUM, LINE, CASENUM, GDGID, CASES, QTY, ID, SRC)
		SELECT NUM, LINE, CASENUM, GDGID, CASES, QTY, @ID, @USERGID
		FROM BCKDMDDTLDTL
		WHERE NUM = @NUM
	end
END
GO
