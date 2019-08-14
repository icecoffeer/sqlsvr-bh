SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SENDBCKNOTIFY]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
  	declare
   		@src int,
		@RCV int,
   		@stat smallint,
   		@id int,
		@LOCALGID INT,
		@return_status int
        DECLARE @EXP DATETIME
   	select @stat = STAT, @src = STOREGID, @EXP = EXPDATE
   	from BCKNOTIFY where  NUM = @num
	SELECT @LOCALGID = USERGID FROM SYSTEM
	select @return_status = 0

   	if @stat <> 100
	begin
         	SET @MSG = '发送的单据不是审核状态'
         	return(1)
   	end

        IF @SRC <> @LOCALGID
 	BEGIN
         	SET @MSG = '发送的单据不是本单位生成的'
         	RETURN(1)
	END
	-- sz add
	IF (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
	BEGIN
	  SET @MSG = '单据' + @NUM + '已经超过到效日期'
	  RETURN 1
	END
	DECLARE ST CURSOR FOR
	SELECT STOREGID FROM BCKNOTIFYLACDTL
	WHERE NUM = @NUM AND STOREGID <> @LOCALGID

	OPEN ST

	FETCH NEXT FROM ST
	INTO @RCV

	WHILE @@FETCH_STATUS = 0
	BEGIN
		execute GETNETBILLID @id output

		insert into NBCKNOTIFY (ID, SRC, RCV, NUM, SETTLENO, RECCNT,
          		NOTE, FILDATE, FILLER, CHKDATE, CHECKER, EXPDATE, STAT,
          		SNDDATE, RCVTIME, NTYPE, NSTAT, NNOTE)
          	select @id, @SRC, @RCV,NUM, SETTLENO, RECCNT,
                 	NOTE, FILDATE, FILLER, CHKDATE, CHECKER, EXPDATE, STAT,
                 	getdate(), NULL, 0, 0, NULL
          	from BCKNOTIFY
		where NUM = @Num

   		if @@error <> 0
		BEGIN
			SET @MSG = '发送'+@NUM+'单据失败'
			select @return_status = 1
			break
		END

   		insert into NBCKNOTIFYDTL (SRC, ID, NUM, LINE, GDGID, NOTE)
          	select @src, @id, NUM, LINE, GDGID, NOTE
          	from BCKNOTIFYDTL
		where NUM = @Num

   		if @@error <> 0
		BEGIN
			SET @MSG = '发送'+@NUM+'单据失败'
			select @return_status = 1
			break
		END


		FETCH NEXT FROM ST
		INTO @RCV
	END

	CLOSE ST
	DEALLOCATE ST

    if @return_status <> 0
      return(@return_status)
 	update BCKNOTIFY
	set SNDDATE = getdate()
	where NUM = @Num

END
GO
