SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Procedure [dbo].[TA_GetAccountTODETAIL]
	@IS_ERR VARCHAR(255) OUTPUT
	,@ACCOUNT VARCHAR(20) OUTPUT
	,@ACCOUNTNAME VARCHAR(30) OUTPUT
	,@RELATIONID INT
	,@DATA1 VARCHAR(50)
	,@DATA2 VARCHAR(50)
	,@DATA3 VARCHAR(50)
	,@DATA4 VARCHAR(50)
	,@DATA5 VARCHAR(50)
	,@DATA6 VARCHAR(50)
	,@DATA7 VARCHAR(50)
	,@DATA8 VARCHAR(50)
	,@DATA9 VARCHAR(50)
	,@DATA10 VARCHAR(50)
	,@DATA11 VARCHAR(50)
	,@DATA12 VARCHAR(50)
	,@DATA13 VARCHAR(50)
	,@DATA14 VARCHAR(50)
	,@DATA15 VARCHAR(50)
As

DECLARE	@INDEX INT
	,@S VARCHAR(50)
	,@CONDITION VARCHAR(100)

--	SELECT @IS_ERR='将'+convert(varchar(20),@Relationid)+'传入TA_GETACCOUNTTODETAIL'
--	RETURN -1

	SELECT @ACCOUNT=NULL,@ACCOUNTNAME=NULL

	IF (SELECT COUNT(*) FROM TA_RLTACCDTL WHERE RELATIONID=@RELATIONID)=1
	BEGIN
		SELECT @INDEX=CorSerialNO FROM TA_RLTACCDTL WHERE RELATIONID=@RELATIONID
		EXEC TA_GETDATATOINDEX @CONDITION OUTPUT,@INDEX
			,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
			,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
			,@DATA14,@DATA15
	END
	ELSE
	BEGIN
		SELECT @CONDITION=''
		DECLARE CUR_RTLACCDTL CURSOR 
			FOR 
			SELECT CorSerialNO FROM TA_RLTACCDTL WHERE RELATIONID=@RELATIONID
		OPEN CUR_RTLACCDTL
		FETCH NEXT FROM CUR_RTLACCDTL INTO @INDEX
		IF @@FETCH_STATUS=-1
		BEGIN
			SELECT @IS_ERR='调用TA_TA_GetAccountTODETAIL时没有取到任何关联定义记录。'
			CLOSE CUR_RTLACCDTL
			DEALLOCATE CUR_RTLACCDTL
			RETURN -1
		END
		WHILE @@FETCH_STATUS<>-1
		BEGIN
			IF @@FETCH_STATUS=-2 GOTO LOOPNEXT
			EXEC TA_GETDATATOINDEX @S OUTPUT,@INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			IF @CONDITION='' 
			BEGIN
				SELECT @CONDITION=RTRIM(LTRIM(@S))
			END
			ELSE
			BEGIN
				SELECT @CONDITION=@CONDITION+'+'+RTRIM(LTRIM(@S))
			END
LOOPNEXT:
			FETCH NEXT FROM CUR_RTLACCDTL INTO @INDEX
		END
		CLOSE CUR_RTLACCDTL
		DEALLOCATE CUR_RTLACCDTL
	END
--根据生成的条件找对应的明细科目
	
--如果没有判断条件，则退出
	Select @Condition=rtrim(ltrim(@Condition))
	if @Condition=''
	begin
		Select @ACCOUNT='',@aCCOUNTNAME=''
--		INSERT TA_LOG (OPERATIONID,HAPPENDATE,OPERATOR,MEMO) VALUES (@RELATIONID,GETDATE(),1,@CONDITION+'ACCOUNT=' + @ACCOUNT)
		Select @IS_ERR=''
		RETURN 0
	end
	select @ACCOUNT=ACCOUNTCODE,@ACCOUNTNAME=ACCOUNTNAME FROM TA_ACCOUNTDETAIL
		WHERE (RELATIONID=@RELATIONID) AND (UPPER(CONDITION)=UPPER(@CONDITION))
	IF ISNULL(@ACCOUNT,'')=''
	BEGIN
		SELECT @IS_ERR='根据传入的关联号('+convert(varchar(30),@RELATIONID)
			+')判断条件('+@CONDITION+')没有找到对应的科目代码和科目名称。'
		return -1
	END
--	INSERT TA_LOG (OPERATIONID,HAPPENDATE,OPERATOR,MEMO) VALUES (@RELATIONID,GETDATE(),1,@CONDITION+'ACCOUNT=' + @ACCOUNT)

	select @IS_ERR=''
	RETURN 0


GO
