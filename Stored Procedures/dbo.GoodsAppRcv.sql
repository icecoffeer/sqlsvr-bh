SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GoodsAppRcv]
(
  @BILL_ID INT,
  @SRC_ID INT,
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) --WITH ENCRYPTION
AS
BEGIN
	DECLARE
		@CUR_SETTLENO INT,
		@STAT SMALLINT,
		@RCV_GID INT,
		@NET_STAT SMALLINT,
		@NET_TYPE SMALLINT,
		@NUM CHAR(14),
		@NET_NUM CHAR(14),
		@PRE_NUM CHAR(14),
		@NET_BILLID INT,
		@ALLOWEDQTYPRICE INT,
		@USERGID INT,
		@BILLTO INT
	DECLARE
		@PSR INT,
		@WRH INT,
		@LINE INT,
		@APPMODE VARCHAR(20),
		@RATIFIER INT, @LRATIFIER INT,
		@ERET INT, @GFTWRHGID INT
	SET @WRH = 1
	SET @ERET = 0
	--Exec OptReadInt 569, 'AllowedQtyPrice', 1, @AllowedQtyPrice Output
	SELECT @CUR_SETTLENO = MAX(NO) from MONTHSETTLE
	SELECT @GFTWRHGID = GID FROM WAREHOUSE WHERE RTRIM(CODE) = '@'
	SELECT  @RCV_GID = RCV, @NET_STAT = STAT, @NET_TYPE = TYPE, @NET_NUM = NUM, @APPMODE = APPMODE,
		@RATIFIER = RATIFIER
	FROM NGOODSAPP WHERE ID = @BILL_ID AND SRC = @SRC_ID
	SELECT @USERGID = USERGID FROM SYSTEM
	IF @@ROWCOUnt = 0 or @net_num is null
	begin
		SET @MSG = '该单据不存在'
		return(1)
	end
	if @net_type <> 1
	begin
		SET @MSG = '该单据不在接收缓冲区中'
		return(1)
	end
	if @USERGID <>  @rcv_gid
	begin
	  	update ngoodsapp set nstat = 1 ,nnote = '该单据的接收单位不是本单位'
	  					where src = @src_id and id = @bill_id
		SET @MSG = '该单据的接收单位不是本单位'
		return(1)
	end
	--SND确保Bill_id 对应一张单据
	--检查员工对照表 MST
	SELECT @PSR = PSR FROM NGOODSAPP WHERE SRC = @SRC_ID AND ID = @BILL_ID
	IF NOT EXISTS( SELECT CODE FROM EMPLOYEE WHERE GID = @PSR )
	BEGIN
	  IF EXISTS( SELECT LGID FROM EMPXLATE WHERE NGID = @PSR )
	  	SELECT @PSR = LGID FROM EMPXLATE WHERE NGID = @PSR
	  ELSE
	  BEGIN
	  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '本地找不到采购员对应的员工(对照表中也不存在)'
	  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到采购员对应的员工(对照表中也不存在)'
		RETURN(1)
	  END
	END
	--检查员工对照表 DTL
	UPDATE NGOODSAPPDTL SET PSR = XLATE.LGID FROM EMPXLATE XLATE
	WHERE SRC = @SRC_ID AND ID = @BILL_ID
	    AND NGOODSAPPDTL.PSR NOT IN(SELECT GID FROM EMPLOYEE (NOLOCK) )
	    AND NGOODSAPPDTL.PSR = XLATE.NGID-- AND NGOODSAPPDTL.RATFLAG = 1
	IF EXISTS(SELECT 1 FROM NGOODSAPPDTL WHERE SRC = @SRC_ID AND ID = @BILL_ID
		AND PSR NOT IN (SELECT GID FROM EMPLOYEE(NOLOCK) ) )
	BEGIN
	  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '本地找不到商品采购员对应的员工'
	  		WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到明细商品中的采购员对应的员工'
		RETURN(1)
	END
	--检查供应商对照表 DTL
	UPDATE NGOODSAPPDTL SET BILLTO = XLATE.LGID FROM VDRXLATE XLATE
	WHERE SRC = @SRC_ID AND ID = @BILL_ID
	    AND NGOODSAPPDTL.BILLTO NOT IN(SELECT GID FROM VENDOR (NOLOCK) )
	    AND NGOODSAPPDTL.BILLTO = XLATE.NGID-- AND NGOODSAPPDTL.RATFLAG = 1
	IF EXISTS(SELECT 1 FROM NGOODSAPPDTL WHERE SRC = @SRC_ID AND ID = @BILL_ID
		AND BILLTO NOT IN (SELECT GID FROM VENDOR(NOLOCK) ) )
	BEGIN
	  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '本地找不到商品缺省供应商对应的供应商'
	  				WHERE SRC = @SRC_ID AND ID = @BILL_ID
	  	SET @MSG = '本地找不到明细商品中的缺省供应商对应的供应商'
		RETURN(1)
	END
	--商品是否已经接收
	IF @NET_STAT = 400 AND @APPMODE = '新增'
	BEGIN
		IF EXISTS( SELECT 1 FROM NGOODSAPPDTL DTL WHERE SRC = @SRC_ID AND ID = @BILL_ID
					AND DTL.RATFLAG = 1 AND DTL.CODE NOT IN (SELECT CODE FROM GOODS (NOLOCK) ) )
		BEGIN
		  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '请先接收新增的网络商品后再接收本申请单'
		  					WHERE SRC = @SRC_ID AND ID = @BILL_ID
		  	SET @MSG = '请先接收新增的网络商品后再接收本申请单'
			RETURN(1)
		END
	END

	--本地没有对应单据
	IF (SELECT COUNT(*) FROM GOODSAPP A,NGOODSAPP B WHERE A.NUM = B.NUM
		AND B.ID = @BILL_ID AND B.SRC = @SRC_ID) = 0
	BEGIN
		IF @NET_STAT IN (401, 411, 400)
		BEGIN
			SET @STAT = @NET_STAT
			SET @WRH = 1
			INSERT INTO GOODSAPP (SRC, NUM, STAT, RATIFIER, PSR, FILDATE, FILLER,
				       CHECKER, CHKDATE, RATOPER, RATDATE, DEADDATE,
				       LSTUPDTIME, PRNTIME, SNDTIME, SETTLENO, NOTE, GOODSCLS, APPMODE, RECCNT)
	          	SELECT  SRC, NUM, STAT, RATIFIER, @PSR, FILDATE, FILLER,
				       CHECKER, CHKDATE, RATOPER, RATDATE, DEADDATE,
				       GETDATE(), PRNTIME, null, @CUR_SETTLENO, NOTE, GOODSCLS, APPMODE, RECCNT
	          	FROM NGOODSAPP
			WHERE SRC = @SRC_ID AND ID = @BILL_ID

	   		INSERT INTO GOODSAPPDTL (NUM, LINE, FLAG, RATFLAG, NOTE, GID, CODE, NAME, SPEC, SORT, RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC,
	   				BILLTO, AUTOORD, ORIGIN, GRADE, MBRPRC, SALETAX, PSR, F1, F2, F3, ALC, CODE2, MKTINPRC, MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NENDTIME, NCANPAY, SSSTART, SSEND, SEASON, HQCONTROL, ORDCYCLE, ALCCTR, ISDISP)
	          	SELECT NUM, LINE, FLAG, RATFLAG, NOTE, GID, CODE, NAME, SPEC, SORT, RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, WHSPRC, CASE WHEN KEEPTYPE&4=4 THEN @GFTWRHGID ELSE @WRH END WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC,
	          		CASE BILLTO WHEN @USERGID THEN 1 ELSE BILLTO END, AUTOORD, ORIGIN, GRADE, MBRPRC, SALETAX, PSR, F1, F2, F3, ALC, CODE2, MKTINPRC, MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NENDTIME, NCANPAY, SSSTART, SSEND, SEASON, HQCONTROL, ORDCYCLE, ALCCTR, ISDISP
	          	FROM NGOODSAPPDTL
			WHERE SRC = @SRC_ID AND ID = @BILL_ID

			INSERT INTO GOODSAPPFIELD(NUM, LINE, FIELDNAME)
			SELECT NUM, LINE, FIELDNAME FROM NGOODSAPPFIELD
			WHERE SRC = @SRC_ID AND ID = @BILL_ID

			INSERT INTO GOODSAPPLAC(NUM, STOREGID)
			SELECT NUM, STOREGID FROM NGOODSAPPLAC
			WHERE SRC = @SRC_ID AND ID = @BILL_ID
			--更新商品WRH
			SELECT @NUM = NUM FROM NGOODSAPP WHERE ID = @BILL_ID AND SRC = @SRC_ID
			IF @APPMODE <> '删除'
			BEGIN
			  UPDATE GOODS SET WRH = DTL.WRH FROM GOODSAPPDTL DTL, GOODSAPP MST
				WHERE DTL.NUM = @NUM AND MST.NUM = DTL.NUM AND DTL.CODE = GOODS.CODE AND DTL.RATFLAG = 1
				AND MST.STAT = 400
		      IF (SELECT RSTWRH FROM SYSTEM) = 1
		      BEGIN
                  INSERT INTO VDRGD (VDRGID, GDGID, WRH)
                  SELECT BILLTO, GID, WRH
                  FROM GOODS (NOLOCK)
                  WHERE GID IN ( SELECT GDTL.GID FROM GOODSAPP GMST, GOODSAPPDTL GDTL
                                WHERE GMST.NUM LIKE @NET_NUM AND GMST.NUM = GDTL.NUM
                               )
                    AND NOT EXISTS ( SELECT 1 FROM VDRGD
                    WHERE VDRGID = GOODS.BILLTO AND VDRGD.GDGID = GOODS.GID AND VDRGD.WRH = GOODS.WRH
                    )
              END
			END
			EXEC GOODSAPPADDLOG @NET_NUM, @NET_STAT,'', @OPER
			IF @@ERROR <> 0
			BEGIN
			  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '接收'+@NET_NUM+'单据失败'
	  				WHERE SRC = @SRC_ID AND ID = @BILL_ID
				SET @MSG = '接收'+@NET_NUM+'单据失败'
				RETURN(1)
			END
		END
		IF @NET_STAT = 400 AND @APPMODE = '删除'
		BEGIN
			EXEC @ERET = GOODSAPPAPPLY @NET_NUM, @MSG OUTPUT
			IF @ERET<>0
			BEGIN
		  		UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '删除商品失败'
  				WHERE SRC = @SRC_ID AND ID = @BILL_ID
				SET @MSG = '生效时错误[删除商品]:' + @MSG
				RAISERROR(@MSG,16,1)
				RETURN(1)
			END
		END
	END
	ELSE --本地找到对应单据
	BEGIN
        SELECT @STAT = A.STAT, @NUM = A.NUM, @LRATIFIER = B.RATIFIER
        FROM GOODSAPP A,NGOODSAPP B WHERE A.NUM = B.NUM AND B.ID = @BILL_ID AND B.SRC = @SRC_ID
        IF (@STAT = 0) OR (@NET_STAT = 0) OR (@STAT = 1200) OR (@NET_STAT = 1200) --AND @NET_STAT IN (400, 411)
        BEGIN
		  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '接收方单据状态非法（为未提交）'
 				WHERE SRC = @SRC_ID AND ID = @BILL_ID
        	SET @MSG = '接收方单据状态非法（为未提交）:' + @Num
			RETURN(1)
        END
	IF @STAT = 401 AND @NET_STAT IN (401, 411, 400) AND @LRATIFIER <> @USERGID
	BEGIN
		UPDATE NGOODSAPPDTL SET WRH = ISNULL(B.WRH,NGOODSAPPDTL.WRH)
				FROM GOODSAPPDTL B
				WHERE NGOODSAPPDTL.ID = @BILL_ID AND NGOODSAPPDTL.SRC = @SRC_ID
				AND NGOODSAPPDTL.NUM = B.NUM AND B.LINE = NGOODSAPPDTL.LINE
		UPDATE NGOODSAPP SET SNDTIME = B.SNDTIME
				FROM GOODSAPP B
				WHERE NGOODSAPP.ID = @BILL_ID AND NGOODSAPP.SRC = @SRC_ID
			DELETE FROM GOODSAPP WHERE NUM = @NUM
			DELETE FROM GOODSAPPDTL WHERE NUM = @NUM
			DELETE FROM GOODSAPPFIELD WHERE NUM = @NUM
			DELETE FROM GOODSAPPLAC WHERE NUM = @NUM

			INSERT INTO GOODSAPP (SRC, NUM, STAT, RATIFIER, PSR, FILDATE, FILLER,
				       CHECKER, CHKDATE, RATOPER, RATDATE, DEADDATE,
				       LSTUPDTIME, PRNTIME, SNDTIME, SETTLENO, NOTE, GOODSCLS, APPMODE, RECCNT)
	          	SELECT  SRC, NUM, STAT, RATIFIER, @PSR, FILDATE, FILLER,
				       CHECKER, CHKDATE, RATOPER, RATDATE, DEADDATE,
				       GETDATE(), PRNTIME, GETDATE(), @CUR_SETTLENO, NOTE, GOODSCLS, APPMODE, RECCNT
	          	FROM NGOODSAPP
			WHERE SRC = @SRC_ID AND ID = @BILL_ID

	   		INSERT INTO GOODSAPPDTL (NUM, LINE, FLAG, RATFLAG, NOTE, GID, CODE, NAME, SPEC, SORT, RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC,
	   				BILLTO, AUTOORD, ORIGIN, GRADE, MBRPRC, SALETAX, PSR, F1, F2, F3, ALC, CODE2, MKTINPRC, MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NENDTIME, NCANPAY, SSSTART, SSEND, SEASON, HQCONTROL, ORDCYCLE, ALCCTR, ISDISP)
	          	SELECT NUM, LINE, FLAG, RATFLAG, NOTE, GID, CODE, NAME, SPEC, SORT, RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC,
	          		CASE BILLTO WHEN @USERGID THEN 1 ELSE BILLTO END, AUTOORD, ORIGIN, GRADE, MBRPRC, SALETAX, PSR, F1, F2, F3, ALC, CODE2, MKTINPRC, MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NENDTIME, NCANPAY, SSSTART, SSEND, SEASON, HQCONTROL, ORDCYCLE, ALCCTR, ISDISP
    	      		FROM NGOODSAPPDTL
			WHERE SRC = @SRC_ID AND ID = @BILL_ID

			INSERT INTO GOODSAPPFIELD(NUM, LINE, FIELDNAME)
			SELECT NUM, LINE, FIELDNAME FROM NGOODSAPPFIELD
			WHERE SRC = @SRC_ID AND ID = @BILL_ID

			INSERT INTO GOODSAPPLAC(NUM, STOREGID)
			SELECT NUM, STOREGID FROM NGOODSAPPLAC
			WHERE SRC = @SRC_ID AND ID = @BILL_ID
			IF @@ERROR <> 0
			BEGIN
			  	UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '接收'+@NET_NUM+'单据失败'
	  				WHERE SRC = @SRC_ID AND ID = @BILL_ID
				SET @MSG = '接收'+@NET_NUM+'单据失败'
				RETURN(1)
			END
			SELECT @NUM = NUM FROM NGOODSAPP WHERE ID = @BILL_ID AND SRC = @SRC_ID
			IF @APPMODE <> '删除'
			BEGIN
			  UPDATE GOODS SET WRH = DTL.WRH FROM GOODSAPPDTL DTL, GOODSAPP MST
				WHERE DTL.NUM = @NUM AND MST.NUM = DTL.NUM AND DTL.CODE = GOODS.CODE AND DTL.RATFLAG = 1
				AND MST.STAT = 400
		      IF (SELECT RSTWRH FROM SYSTEM) = 1
		      BEGIN
                  INSERT INTO VDRGD (VDRGID, GDGID, WRH)
                  SELECT BILLTO, GID, WRH
                  FROM GOODS (NOLOCK)
                  WHERE GID IN ( SELECT GDTL.GID FROM GOODSAPP GMST, GOODSAPPDTL GDTL
                                WHERE GMST.NUM LIKE @NET_NUM AND GMST.NUM = GDTL.NUM
                               )
                    AND NOT EXISTS ( SELECT 1 FROM VDRGD
                    WHERE VDRGID = GOODS.BILLTO AND VDRGD.GDGID = GOODS.GID AND VDRGD.WRH = GOODS.WRH
                    )
              END
			END
			EXEC GOODSAPPADDLOG @NET_NUM, @NET_STAT, '', @OPER
			IF @NET_STAT = 400 AND @APPMODE = '删除'
			BEGIN
				EXEC @ERET = GOODSAPPAPPLY @NET_NUM, @MSG OUTPUT
				IF @ERET<>0
				BEGIN
			  		UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '删除商品失败'
	  				WHERE SRC = @SRC_ID AND ID = @BILL_ID
					SET @MSG = '生效时错误:' + @MSG
					RAISERROR(@MSG,16,1)
					RETURN(1)
				END
			END
		END
		ELSE
		IF @STAT IN (401,411,400)  --401 added
		BEGIN
	  		UPDATE NGOODSAPP SET NSTAT = 1 ,NNOTE = '本地单据状态为请求总部批准、已作废或总部审批，不能再次接收'
			WHERE SRC = @SRC_ID AND ID = @BILL_ID
			SET @MSG = '本地单据状态为请求总部批准、已作废或总部审批，不能再次接收。' + @MSG
			--RAISERROR(@MSG,16,1)
			RETURN(1)
		END
	END
    DELETE FROM NGOODSAPP WHERE ID = @BILL_ID AND SRC = @SRC_ID
	DELETE FROM NGOODSAPPDTL WHERE ID = @BILL_ID AND SRC = @SRC_ID
	DELETE FROM NGOODSAPPFIELD WHERE ID = @BILL_ID AND SRC = @SRC_ID
	DELETE FROM NGOODSAPPLAC WHERE ID = @BILL_ID AND SRC = @SRC_ID
	EXEC GOODSAPPADDLOG @NUM,@NET_STAT,'接收',@OPER
	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), substring(@OPER, CHARINDEX('[', @OPER)+1, CHARINDEX(']',@OPER) - CHARINDEX('[',@OPER)-1), '',
    'GOODSAPP', 304, '接收商品资料申请单:['+@NUM+']' )
	RETURN(0)
END
GO
