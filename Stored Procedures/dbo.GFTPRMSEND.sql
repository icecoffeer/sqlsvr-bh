SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GFTPRMSEND]
( 
  @PINUM	CHAR(14),
  @PIOPER 	CHAR(30),
  @TOStat 	INT,  --强制审核标志
  @POERRMSG 	VARCHAR(255) OUTPUT
) --WITH ENCRYPTION		
AS
BEGIN
    DECLARE	
      @SRC INT,       	@ID  INT,    
      @RCV INT, 	@STAT SMALLINT
    
    SELECT @STAT = STAT
    FROM GFTPRM(NOLOCK) WHERE NUM = @PINUM
        
--CHECK    
    IF @STAT <> 800 
    BEGIN
      SET @POERRMSG = '[发送]单据' + @PINUM + '不是已生效状态'
      RETURN 1
    END
    
    IF @STAT = 800 
    BEGIN
      IF NOT EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID = ZBGID)
      BEGIN
        SET @POERRMSG = '[发送]单据' + @PINUM + ':门店不能发送'
        RETURN 2
      END
    END
    
--BEGIN TO SEND
       
    SELECT @SRC = SRC FROM GFTPRM(NOLOCK) WHERE NUM = @PINUM
    
    DECLARE C_LAC CURSOR FOR
    SELECT STOREGID FROM GFTPRMLACDTL(NOLOCK) WHERE NUM = @PINUM 
    OPEN C_LAC
    FETCH NEXT FROM C_LAC
    INTO @RCV
    WHILE @@FETCH_STATUS = 0
    BEGIN
    	EXECUTE GETNETBILLID @ID OUTPUT
 	INSERT INTO NGFTPRM(ID, NUM, STAT, FILLER, FILDATE, CHECKER, CHKDATE, 
    	BEGINTIME, ENDTIME, SRC, LSTUPDTIME, NOTE, PRNTIME, SETTLENO, RECCNT, 
 	TOPIC, RCV, NSTAT, TYPE, RCVTIME, NNOTE, FRCCHK)
    	SELECT @ID, NUM, 0, FILLER, FILDATE, CHECKER, CHKDATE, 
    	BEGINTIME, ENDTIME, @SRC, LSTUPDTIME, NOTE, PRNTIME, SETTLENO, RECCNT, 
    	TOPIC, @RCV, 0, 0, NULL, NULL, @TOStat
    	FROM GFTPRM(NOLOCK)
    	WHERE NUM = @PINUM
    
    	IF @@ERROR <> 0 
    	BEGIN
        	SET @POERRMSG = '发送' + @PINUM + '单据失败'
        	RETURN 3
    	END	
    	
    	INSERT INTO NGFTPRMDTL(RCV, ID, NUM, LINE, RULECODE, NOTE)
    	SELECT @RCV, @ID, NUM, LINE, RULECODE, NOTE 
    	FROM GFTPRMDTL(NOLOCK)
    	WHERE NUM = @PINUM
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 4
    	END
    	
    	INSERT INTO NGFTPRMRULE(RCV, ID, CODE, NAME, STAT, BEGINTIME, ENDTIME, 
    	QTY, AMT, NOTE, TOPIC, REPORT)
    	SELECT @RCV, @ID, A.CODE, A.NAME, A.STAT, A.BEGINTIME, A.ENDTIME, 
    	A.QTY, A.AMT, A.NOTE, A.TOPIC, A.REPORT
    	FROM GFTPRMRULE A(NOLOCK) , GFTPRMDTL D(NOLOCK) 
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.CODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 5
    	END
    	
    	INSERT INTO NGFTPRMRULELMT(RCV, ID, RCODE, LMTNO, NOTE)
    	SELECT @RCV, @ID, A.RCODE, A.LMTNO, A.NOTE
    	FROM GFTPRMRULELMT A(NOLOCK), GFTPRMDTL D(NOLOCK)
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.RCODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 6
    	END
    	
    	INSERT INTO NGFTPRMRULELMTDTL(RCV, ID, RCODE, LMTNO, LINE, NAME, VALUE)
    	SELECT @RCV, @ID, A.RCODE, A.LMTNO, A.LINE, A.NAME, A.VALUE
    	FROM GFTPRMRULELMTDTL A(NOLOCK), GFTPRMDTL D(NOLOCK)
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.RCODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 7
    	END
    	
    	INSERT INTO NGFTPRMGOODS(RCV, ID, RCODE, LINE, GDCOND, GDCONDTEXT, FILTERCNSTR, QTY, AMT)
    	SELECT @RCV, @ID, A.RCODE, A.LINE, A.GDCOND, A.GDCONDTEXT, A.FILTERCNSTR, A.QTY, A.AMT
    	FROM GFTPRMGOODS A(NOLOCK), GFTPRMDTL D(NOLOCK)
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.RCODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 8
    	END
    	
    	INSERT INTO NGFTPRMGIFT(RCV, ID, RCODE, GROUPID, QTY, AMT, AMTLMT, SUMAMT, SUMAMTLMT)
    	SELECT @RCV, @ID, A.RCODE, A.GROUPID, A.QTY, A.AMT, A.AMTLMT, A.SUMAMT, A.SUMAMTLMT
    	FROM GFTPRMGIFT A(NOLOCK), GFTPRMDTL D(NOLOCK)
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.RCODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 9
    	END
    	
    	INSERT INTO NGFTPRMGIFTDTL(RCV, ID, RCODE, GROUPID, GFTGID, QTY, QTYLMT, 
    	SUMQTY, SUMQTYLMT, PAYPRC)
    	SELECT @RCV, @ID, A.RCODE, A.GROUPID, A.GFTGID, A.QTY, A.QTYLMT, 
    	A.SUMQTY, A.SUMQTYLMT, A.PAYPRC
    	FROM GFTPRMGIFTDTL A(NOLOCK), GFTPRMDTL D(NOLOCK)
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.RCODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 10
    	END
    	
    	INSERT INTO NGFTPRMRULEMUTEX(RCV, ID, RCODE, MUTEXCODE)
    	SELECT @RCV, @ID, A.RCODE, A.MUTEXCODE
    	FROM GFTPRMRULEMUTEX A(NOLOCK), GFTPRMDTL D(NOLOCK)
    	WHERE D.NUM = @PINUM AND D.RULECODE = A.RCODE 
    
    	IF @@ERROR <> 0 
    	BEGIN 
        	SET @POERRMSG = '发送' + @PINUM+ '单据失败'
        	RETURN 11
    	END
    	
	FETCH NEXT FROM C_LAC
	INTO @RCV
    END
    DEALLOCATE C_LAC
    
    EXEC GFTPRM_ADDLOG @PINUM, 0, @PIOPER
    
    SET @POERRMSG = '发送' + @PINUM+ '单据成功'
    
    RETURN 0  
END
GO
