SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GdSaleAdjSnd]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @FRCCHK INT,
  @TOSTORE INT, --IF = -1 THEN TO ALL LAC STORE
  @MSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
  	DECLARE
   		@SRC INT,		    @STAT SMALLINT,   @ID INT,    
   		@RCVSTORE INT,      @VRET INT,        @USERGID INT,   
        @STOREGID INT,     	@GDGID INT,       @GDCODE VARCHAR(13),
        @Launch DATETIME
    	
    --SET @FRCCHK = 0  
    SET @VRET = -1
   	SELECT @STAT = STAT, @SRC = SRC
   		FROM GdSaleAdj WHERE  NUM = @NUM
	--EXEC OPTREADINT 594 ,'XXXX',0, @XXXX OUTPUT --选项
	
	SELECT @USERGID = USERGID FROM SYSTEM
   	if @stat <> 100 and @stat <> 800
	begin
      SET @MSG = '发送的单据不是审核或者已经生效的单据'
      return(1)
   	end
	/*IF (@Launch IS NOT NULL) AND (@Launch <= CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )
	BEGIN
	  SET @MSG = '单据' + @NUM + '已经超过到效日期'
	  RETURN 1
	END*/
	
	IF @STAT = 100 OR @STAT = 800
	BEGIN
        IF @SRC <> @USERGID 
        BEGIN
            SET @MSG = '发送的单据不是本单位生成的'
            RETURN(1)
        END
        IF @TOSTORE >= 0
        BEGIN 	
            EXECUTE GETNETBILLID @ID OUTPUT
            INSERT INTO NGdSaleAdj(ID, NNOTE, NSTAT, RCV, RCVTIME, FRCCHK, TYPE, 
                    NUM, STAT, SETTLENO, SRC, PSR, FILDATE, FILLER, CHECKER, CHKDATE, 
                    LAUNCH, LSTUPDTIME, PRNTIME, SNDTIME, EON, NOTE, RECCNT)
            SELECT  @ID, NULL, 0, @TOSTORE, NULL, @FRCCHK, 0, 
              		NUM, STAT, SETTLENO, SRC, PSR, FILDATE, FILLER, CHECKER, CHKDATE, 
              		LAUNCH, LSTUPDTIME, PRNTIME, SNDTIME, EON, NOTE, RECCNT
              	from GdSaleAdj
    		where NUM = @NUM
    
       		INSERT INTO NGdSaleAdjDTL(SRC, ID, 
       		    NUM, LINE, SETTLENO, GDGID, OLDGDSALE, NEWGDSALE, NEWPAYRATE, CHGFLAG, CHGFROMDATE, NOTE)
            SELECT @SRC, @ID, 
                NUM, LINE, SETTLENO, GDGID, OLDGDSALE, NEWGDSALE, NEWPAYRATE, CHGFLAG, CHGFROMDATE, NOTE
            FROM GdSaleAdjDTL
    		WHERE NUM = @NUM
    		--INSERT INTO NGdSaleAdjLac(SRC, ID, NUM, STOREGID)
       		--SELECT @SRC, @ID, NUM, STOREGID FROM GdSaleAdjLac WHERE NUM = @NUM
    		IF @@ERROR <> 0 
    		BEGIN
    			SET @MSG = '发送'+@NUM+'单据失败'
    			RETURN(1)
    		END
       		UPDATE GdSaleAdj SET SNDTIME = GETDATE() WHERE NUM = @NUM
       	END
       	ELSE IF @TOSTORE < 0 -- 发送所有生效门店
       	BEGIN
    	   	IF OBJECT_ID('GdSaleAdjSnd_C') IS NOT NULL DEALLOCATE GdSaleAdjSnd_C
    	   	DECLARE GdSaleAdjSnd_C CURSOR FOR 
    	   		SELECT STOREGID FROM GdSaleAdjLAC WHERE NUM = @NUM AND STOREGID <> @USERGID
    	   	OPEN GdSaleAdjSnd_C
    	   	FETCH NEXT FROM GdSaleAdjSnd_C INTO @RCVSTORE
    	   	WHILE @@FETCH_STATUS=0
    	   	BEGIN
    		   	EXECUTE GETNETBILLID @ID OUTPUT
                INSERT INTO NGdSaleAdj(ID, NNOTE, NSTAT, RCV, RCVTIME, FRCCHK, TYPE, 
                        NUM, STAT, SETTLENO, SRC, PSR, FILDATE, FILLER, CHECKER, CHKDATE, 
                        LAUNCH, LSTUPDTIME, PRNTIME, SNDTIME, EON, NOTE, RECCNT)
                SELECT  @ID, NULL, 0, @RCVSTORE, NULL, @FRCCHK, 0, 
                  		NUM, STAT, SETTLENO, SRC, PSR, FILDATE, FILLER, CHECKER, CHKDATE, 
                  		LAUNCH, LSTUPDTIME, PRNTIME, SNDTIME, EON, NOTE, RECCNT
                  	from GdSaleAdj
        		where NUM = @NUM
        
           		INSERT INTO NGdSaleAdjDTL(SRC, ID, 
           		    NUM, LINE, SETTLENO, GDGID, OLDGDSALE, NEWGDSALE, NEWPAYRATE, CHGFLAG, CHGFROMDATE, NOTE)
                SELECT @SRC, @ID, 
                    NUM, LINE, SETTLENO, GDGID, OLDGDSALE, NEWGDSALE, NEWPAYRATE, CHGFLAG, CHGFROMDATE, NOTE
                FROM GdSaleAdjDTL
        		WHERE NUM = @NUM
        		--INSERT INTO NGdSaleAdjLac(SRC, ID, NUM, STOREGID)
           		--SELECT @SRC, @ID, NUM, STOREGID FROM GdSaleAdjLac WHERE NUM = @NUM
    			IF @@ERROR <> 0 
    			BEGIN
    				SET @MSG = '发送'+@NUM+'单据失败'
                    CLOSE GdSaleAdjSnd_C
                    DEALLOCATE GdSaleAdjSnd_C
    				RETURN(1)
    			END
    			FETCH NEXT FROM GdSaleAdjSnd_C INTO @RCVSTORE
    		END  
            CLOSE GdSaleAdjSnd_C
            DEALLOCATE GdSaleAdjSnd_C
            
        	UPDATE GdSaleAdj SET SNDTIME = GETDATE() WHERE NUM = @NUM       	
        END
	END

	EXEC GdSaleAdjADDLOG @NUM,@STAT,'发送',@OPER
	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), substring(@OPER, CHARINDEX('[', @OPER)+1, CHARINDEX(']',@OPER) - CHARINDEX('[',@OPER)-1), '',
    'GdSaleAdj', 304, '发送营销方式调整单:['+@NUM+']' )
END
GO
