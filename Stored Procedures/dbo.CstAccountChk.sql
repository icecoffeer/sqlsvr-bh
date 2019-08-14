SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[CstAccountChk]
	@num       char(10)
as

	declare @pay money,
		@billto  int,
		@RCPCST INT,
		@CURDATE DATETIME,
		@TOTAL MONEY, 
		@outnum char(10),
		@cls varchar(10),
		@cur_settleno int
 	
        select @cur_settleno = (select max(NO) from MONTHSETTLE)
	select @pay  = pay ,@billto = CLIENT from rcpcst where num = @num 
	/*if @pay < 0 
	begin
		raiserror('收款额不能为负数',16,1)
		return(1)
	end*/

	select @RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	if @RCPCST is null 
	   select @RCPCST = '0'
	if @RCPCST = '1'
	BEGIN
      
	      	DECLARE CURDATE CURSOR FOR
		SELECT ADATE,outnum,cls,OTOTAL
		    FROM CSTBILL (nolock) 
		    WHERE CLIENT=@BILLTO
		    ORDER BY ADATE
		OPEN CURDATE
		
		FETCH NEXT FROM CURDATE INTO @CURDATE,@outnum,@cls,@TOTAL
		WHILE @@FETCH_STATUS = 0
	        BEGIN     
		     if @cls = '批发退' OR @CLS = '直销退' 
			select @TOTAL = - @TOTAL 		     
			
		     IF @TOTAL >@PAY 
		     BEGIN
     		         SET @TOTAL=@TOTAL-@PAY 
  	                 UPDATE CSTBILL SET OTOTAL=@TOTAL WHERE ADATE=@CURDATE AND CLIENT=@BILLTO And outnum = @outnum and cls = @cls
  	                 UPDATE CSTBILL SET RCPTOTAL=TOTAL-OTOTAL WHERE ADATE=@CURDATE AND CLIENT=@BILLTO And outnum = @outnum and cls = @cls
			 SET @PAY = 0
			 BREAK
		     END	
        	      
 		     SET @PAY=@PAY-@TOTAL
	             INSERT INTO CSTPAYBILL (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPNUM)
			 SELECT ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,@NUM 
			 	FROM CSTBILL 
				WHERE ADATE=@CURDATE AND CLIENT=@BILLTO and outnum = @outnum and cls = @cls
	             DELETE FROM CSTBILL WHERE ADATE=@CURDATE AND CLIENT=@BILLTO And outnum = @outnum and cls = @cls
  
		     FETCH NEXT FROM CURDATE INTO @CURDATE,@outnum,@cls,@TOTAL
		END
		CLOSE CURDATE
		DEALLOCATE CURDATE
     	        
		if @pay >0 --mido by cyb 2002.08.14 2002081450966
		begin
	           insert into CSTBill (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPTOTAL,OTOTAL)
		     VALUES (@CUR_SETTLENO,GETDATE(),'付款',@billto,@NUM,-1*@pay,0,-1*@PAY)
		end

       END
       return(0)	
GO
