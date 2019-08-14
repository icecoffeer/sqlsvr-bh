SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PROMBCHK]
(
	@NUM	 VARCHAR(14),
	@CLS	 VARCHAR(10),
	@OPER	  VARCHAR(30),
	@TOSTAT  int,
	@MSG  VARCHAR(255) OUTPUT
)
AS
BEGIN
    declare 
	@VRET INT,
	@VSTAT INT
	
	set @VRET = 0
	SELECT @VSTAT = STAT FROM PROMB WHERE NUM = @NUM
	IF @TOSTAT <> 100 OR @VSTAT <> 0 OR @TOSTAT <= @VSTAT	
	  begin
	    set @MSG = '目标状态不对' + CHAR(@TOSTAT)		
	    RETURN(1)
	  end
	
	IF @VSTAT = 0 
	  begin
	    exec @VRET = LOADPROMBTO50 @CLS, @NUM, @OPER, @MSG
	    IF @VRET <> 0 RETURN(@VRET)
	  end
		
	UPDATE PROMB 
	SET STAT = @TOSTAT, FILDATE = getdate(),
	    LSTUPDTIME = getdate()
	WHERE NUM = @NUM
	
	INSERT INTO PROMBLOG (NUM, STAT, FILLER, FILDATE)
	VALUES(@NUM, 100, @OPER, getdate())	
	
        --Added by Zhuhaohui 2007.12.14 审核消息提醒    
        if (@TOSTAT = 100)
        begin
          declare @title varchar(500),
                  @event varchar(100)
          --触发提醒
          set @title = @CLS + '促销单[' + @NUM + ']在' + Convert(varchar, getdate(), 20) + '被审核了。'
          set @event = @CLS + '促销单审核提醒'
          execute PROMCHKPROMPT @NUM, @CLS, @title, @event, @OPER
        end
        --end of 促销单审核提醒
    	
	
	EXEC @VRET = PROMBSEND @NUM, @CLS, @OPER, 0, @MSG
	IF @VRET <> 0 RETURN(1)

	/*@VRET := PROMBSEND(PICLS,PINUM,PIOPER,0,POERR_MSG)
	IF VRET <> 0 THEN RETURN(1); END IF;
	VRET := PROMBSEND(PICLS,PINUM,PIOPER,1,POERR_MSG)
	IF VRET <> 0 THEN RETURN(1); END IF;*/
 	RETURN(0)
END
GO
