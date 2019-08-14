SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[TA_GENFORYY]
	@IS_ERR VARCHAR(255) OUTPUT --返回错误信息
	,@OPERATION_NAME VARCHAR(50)	--对应业务名称
	,@VOUCHER_DATE VARCHAR(10) --写到凭证中的日期
	,@WHERE_CLAUSE varchar(255)=NULL--查询控制条件
	,@OPERATOR_NAME VARCHAR(10)--生成凭证的操作员姓名
As

DECLARE @SQL varchar(250)
	,@SQL_ADDTION varchar(250)
	,@VOUCHER_TYPENAME VARCHAR(15)
	,@OPERATION_ID INT
	,@MAX_ROWS INT--????

DECLARE @SUMTYPE_ALL INT--??????????????????
	SELECT @SUMTYPE_ALL=-1

DECLARE @YW_ROWCOUNT INT--CURRENT OPERATION'S ROW COUNT

DECLARE @DATA1 VARCHAR(100)
	,@DATA2 VARCHAR(100)
	,@DATA3 VARCHAR(100)
	,@DATA4 VARCHAR(100)
	,@DATA5 VARCHAR(100)
	,@DATA6 VARCHAR(100)
	,@DATA7 VARCHAR(100)
	,@DATA8 VARCHAR(100)
	,@DATA9 VARCHAR(100)
	,@DATA10 VARCHAR(100)
	,@DATA11 VARCHAR(100)
	,@DATA12 VARCHAR(100)
	,@DATA13 VARCHAR(100)
	,@DATA14 VARCHAR(100)
	,@DATA15 VARCHAR(100)
	,@SUM_TYPE INT--????????????
DECLARE @DIRECTION BIT
	,@RELATIONID INT
	,@ACCOUNT_INDEX VARCHAR(15)
	,@BRIEF_INDEX VARCHAR(30)
	,@TOTALMONEY_INDEX INT
	,@QUANTITY_INDEX INT
	,@FOREINMONEY_INDEX INT
	,@RATE_INDEX INT
	,@SETTLETYPENAME_INDEX INT
	,@SETTLENO_INDEX INT
	,@SETTLEDATE_INDEX INT
	,@DEPARTNAME_INDEX INT
	,@PERSONNAME_INDEX INT
	,@FIRMNAME_INDEX INT
	,@CORCODE_INDEX INT
	,@PROJECTNAME_INDEX INT
	,@ISSUM INT

DECLARE @TMP INT

DECLARE @YW_CODE INT--???さ?虻??D騩?

DECLARE	@BRIEF VARCHAR(30)
	,@ACCOUNT VARCHAR(15)
	,@ACCOUNTNAME VARCHAR(50)
	,@TOTALMONEY VARCHAR(50)
	,@QUANTITY VARCHAR(50)
	,@FOREINMONEY VARCHAR(50)
	,@RATE VARCHAR(50)
	,@SETTLETYPENAME VARCHAR(20)
	,@SETTLENO VARCHAR(5)
	,@SETTLEDATE VARCHAR(10)
	,@DEPARTNAME VARCHAR(20)
	,@PERSONNAME VARCHAR(8)
	,@FIRMNAME VARCHAR(40)
	,@CORCODE VARCHAR(10)
	,@PROJECTNAME VARCHAR(20)

DECLARE @S VARCHAR(30)--用于分解摘要，生成摘要信息
	,@I INT
	,@RETURN INT

	--查询业窭?
	SELECT @SQL=SQLCONTENT,@OPERATION_ID=OPERATIONID
		,@SQL_ADDTION=SQLADDTION
		,@VOUCHER_TYPENAME=VOUCHERTYPENAME
		,@MAX_ROWS=ISNULL(GENTYPE,1)
		FROM TA_OPERATION WHERE OPERATIONNAME=@OPERATION_NAME
	IF @@ROWCOUNT<>1 
	BEGIN
		select @IS_ERR='对应业务名称' +@OPERATION_Name
			+ '在数据库中不存在'
		RETURN -1
	END
	--清除临时表内容
	TRUNCATE TABLE #TA_YYFACE
	--打开光标
--	select @SQL+ '  "' +@WHERE_CLAUSE +'"'

	EXEC (@SQL + '  ' +@WHERE_CLAUSE +'')
	OPEN CUR_GETVOUCHER
	FETCH NEXT FROM CUR_GETVOUCHER INTO @DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6
		,@DATA7,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13,@DATA14,@DATA15
	IF @@FETCH_STATUS=-1
		GOTO END_SP
	--打开凭证与业务数据对应关系光标
	DECLARE CUR_RELATION SCROLL CURSOR 
		FOR 
		SELECT RELATIONID,DIRECTION,ACCOUNT,BRIEF,TOTALMONEY,QUANTITY,FOREINMONEY,
		RATE,SETTLETYPENAME,SETTLENO,SETTLEDATE,DEPARTNAME,PERSONNAME,
		FIRMNAME,CORCODE,PROJECTNAME,ISSUM FROM TA_RELATION WHERE OPERATIONID=@OPERATION_ID
	OPEN CUR_RELATION
	FETCH NEXT FROM CUR_RELATION INTO @RELATIONID,@DIRECTION,@ACCOUNT_INDEX,@BRIEF_INDEX,
		@TOTALMONEY_INDEX,@QUANTITY_INDEX,@FOREINMONEY_INDEX,
		@RATE_INDEX,@SETTLETYPENAME_INDEX,@SETTLENO_INDEX,@SETTLEDATE_INDEX,
		@DEPARTNAME_INDEX,@PERSONNAME_INDEX,@FIRMNAME_INDEX,@CORCODE_INDEX,
		@PROJECTNAME_INDEX,@ISSUM
	IF @@FETCH_STATUS=-1
	BEGIN
		SELECT @IS_ERR='该项业务的凭证没有建立与业务数据对应关系'
		CLOSE CUR_RELATION
		DEALLOCATE CUR_RELATION
		CLOSE CUR_GETVOUCHER
		DEALLOCATE CUR_GETVOUCHER
		RETURN -1
	END

	SELECT @YW_CODE=0--控制生成凭证的业务号
	SELECT @YW_ROWCOUNT=@MAX_ROWS

	WHILE @@FETCH_STATUS<>-1
	BEGIN
		IF @@FETCH_STATUS=-2 GOTO LOOPNEXT
		IF @MAX_ROWS=1
		BEGIN
			SELECT @YW_CODE=@YW_CODE+1--???????髚???????
		END
		--If there are sumtype voucher,should added sumtype record before
		IF @MAX_ROWS>1 AND @YW_ROWCOUNT=@MAX_ROWS
		BEGIN
			SELECT @YW_CODE=@YW_CODE+1--将借贷方框架重新生成
			SELECT @YW_ROWCOUNT=0
/*
			FETCH FIRST FROM CUR_RELATION INTO @RELATIONID,@DIRECTION,@ACCOUNT_INDEX,@BRIEF_INDEX,
				@TOTALMONEY_INDEX,@QUANTITY_INDEX,@FOREINMONEY_INDEX,
				@RATE_INDEX,@SETTLETYPENAME_INDEX,@SETTLENO_INDEX,@SETTLEDATE_INDEX,
				@DEPARTNAME_INDEX,@PERSONNAME_INDEX,@FIRMNAME_INDEX,@CORCODE_INDEX,
				@PROJECTNAME_INDEX,@ISSUM
			WHILE @@FETCH_STATUS<>-1
			BEGIN
				IF @ISSUM=1
				BEGIN
					INSERT INTO TA_YYFACE (OPERATCODE,PRODUCEDATE,VOUCHERTYPENAME,
						BRIEF,ACCOUNT,DIRECTION,TICKETNUMBER,TOTALMONEY
						,QUANTITY,FOREINMONEY,OPERATORNAME)
						VALUES
						(CONVERT(VARCHAR(32),@YW_CODE),@VOUCHER_DATE,
						@VOUCHER_TYPENAME,@BRIEF_INDEX,@ACCOUNT,CONVERT(CHAR(1),@DIRECTION),
						'0','0','0','0',@OPERATOR_NAME)
				END
				FETCH NEXT FROM CUR_RELATION INTO @RELATIONID,@DIRECTION,@ACCOUNT_INDEX,@BRIEF_INDEX,
					@TOTALMONEY_INDEX,@QUANTITY_INDEX,@FOREINMONEY_INDEX,
					@RATE_INDEX,@SETTLETYPENAME_INDEX,@SETTLENO_INDEX,@SETTLEDATE_INDEX,
					@DEPARTNAME_INDEX,@PERSONNAME_INDEX,@FIRMNAME_INDEX,@CORCODE_INDEX,
					@PROJECTNAME_INDEX,@ISSUM
			END
*/
		END
		
		FETCH FIRST FROM CUR_RELATION INTO @RELATIONID,@DIRECTION,@ACCOUNT_INDEX,@BRIEF_INDEX,
			@TOTALMONEY_INDEX,@QUANTITY_INDEX,@FOREINMONEY_INDEX,
			@RATE_INDEX,@SETTLETYPENAME_INDEX,@SETTLENO_INDEX,@SETTLEDATE_INDEX,
			@DEPARTNAME_INDEX,@PERSONNAME_INDEX,@FIRMNAME_INDEX,@CORCODE_INDEX,
			@PROJECTNAME_INDEX,@ISSUM
		WHILE @@FETCH_STATUS<>-1
		BEGIN
			--生成摘要信息
			SELECT @BRIEF='',@S='',@I=0
			SELECT @I=CHARINDEX('+',@BRIEF_INDEX)
			WHILE @I<>0
			BEGIN
				SELECT @S=SUBSTRING(@BRIEF_INDEX,1,@I-1)
				IF SUBSTRING(ISNULL(@S,''),1,3)='COL' 
				BEGIN
					SELECT @TMP=CONVERT(INT,RIGHT(@S,DATALENGTH(@S)-3))
					EXEC TA_GETDATATOINDEX @S OUTPUT,@TMP,@DATA1,@DATA2,@DATA3
						,@DATA4,@DATA5,@DATA6,@DATA7,@DATA8,@DATA9,@DATA10
						,@DATA11,@DATA12,@DATA13,@DATA14,@DATA15
					SELECT @BRIEF=@BRIEF+rtrim(@S)
				END
				ELSE
				BEGIN
					SELECT @BRIEF=@BRIEF+rtrim(@S)
				END
				SELECT @BRIEF_INDEX=SUBSTRING(@BRIEF_INDEX,@I+1,DATALENGTH(@BRIEF_INDEX))
				SELECT @I=CHARINDEX('+',@BRIEF_INDEX)
			END

			IF SUBSTRING(ISNULL(@BRIEF_INDEX,''),1,3)='COL' 
			BEGIN
				SELECT @TMP=CONVERT(INT,RIGHT(@BRIEF_INDEX,DATALENGTH(@BRIEF_INDEX)-3))
				EXEC TA_GETDATATOINDEX @S OUTPUT,@TMP,@DATA1,@DATA2,@DATA3
					,@DATA4,@DATA5,@DATA6,@DATA7,@DATA8,@DATA9,@DATA10
					,@DATA11,@DATA12,@DATA13,@DATA14,@DATA15
				SELECT @BRIEF=@BRIEF+rtrim(@S)
			END
			ELSE
			BEGIN
				SELECT @BRIEF=@BRIEF+@BRIEF_INDEX
			END
			--取出对应的科目代码和名称
			IF (SELECT COUNT(*) FROM TA_RLTACCDTL WHERE RELATIONID=@RELATIONID)=0
			begin
				SELECT @ACCOUNT=@ACCOUNT_INDEX
			end
			else
			BEGIN
			--此时要根据定义情况判断明细科目
				EXEC @RETURN=TA_GETACCOUNTTODETAIL @IS_ERR OUTPUT,@ACCOUNT OUTPUT,@ACCOUNTNAME OUTPUT
					,@RELATIONID
					,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
					,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
					,@DATA14,@DATA15
				IF @RETURN<0 
				BEGIN
					CLOSE CUR_RELATION
					DEALLOCATE CUR_RELATION
					CLOSE CUR_GETVOUCHER
					DEALLOCATE CUR_GETVOUCHER
					RETURN @RETURN
				END
			END
			IF ISNULL(@ACCOUNT,'')='' GOTO RELATIONNEXT

			EXEC TA_GETDATATOINDEX @TOTALMONEY OUTPUT,@TOTALMONEY_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @QUANTITY OUTPUT,@QUANTITY_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @FOREINMONEY OUTPUT,@FOREINMONEY_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @RATE OUTPUT,@RATE_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @SETTLETYPENAME OUTPUT,@SETTLETYPENAME_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @SETTLENO OUTPUT,@SETTLENO_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @SETTLEDATE OUTPUT,@SETTLEDATE_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @DEPARTNAME OUTPUT,@DEPARTNAME_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @PERSONNAME OUTPUT,@PERSONNAME_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @FIRMNAME OUTPUT,@FIRMNAME_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @CORCODE OUTPUT,@CORCODE_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			EXEC TA_GETDATATOINDEX @PROJECTNAME OUTPUT,@PROJECTNAME_INDEX
				,@DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6,@DATA7
				,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13
				,@DATA14,@DATA15
			IF (convert(money,@TOTALMONEY)=0) AND (convert(money,@FOREINMONEY)=0)
			BEGIN
				GOTO RELATIONNEXT
			END
			IF @DEPARTNAME_INDEX<>0 AND (ISNULL(@DEPARTNAME,'')='') GOTO RELATIONNEXT
			IF @FIRMNAME_INDEX<>0 AND (ISNULL(@FIRMNAME,'')='') GOTO RELATIONNEXT


			--将生成的数据保存到TA_YYFACE表中
			IF @MAX_ROWS=1 OR @ISSUM=0
			BEGIN
				INSERT INTO #TA_YYFACE (OPERATCODE,PRODUCEDATE,VOUCHERTYPENAME,
					TICKETNUMBER,BRIEF,ACCOUNT,DIRECTION,TOTALMONEY,
					QUANTITY,FOREINMONEY,RATE,SETTLETYPENAME,SETTLENO,
					SETTLEDATE,DEPARTNAME,PERSONNAME,FIRMNAME,TICKETCODE,
					OPERATORNAME,PROJECTNAME)
					VALUES
					(CONVERT(VARCHAR(32),@YW_CODE),@VOUCHER_DATE,
					@VOUCHER_TYPENAME,'1',@BRIEF,@ACCOUNT,CONVERT(CHAR(1),@DIRECTION),
					@TOTALMONEY,@QUANTITY,@FOREINMONEY,@RATE,@SETTLETYPENAME,
					@SETTLENO,@SETTLEDATE,@DEPARTNAME,@PERSONNAME,@FIRMNAME,
					@CORCODE,@OPERATOR_NAME,@PROJECTNAME)
			END
			ELSE
			BEGIN
				--现在主要考虑往来户核算，所以这样处理
				--要同时考虑到部门核算，1999.10.9
				if @DEPARTNAME_INDEX<>0
				BEGIN
					if @FIRMNAME_INDEX<>0
					BEGIN
						SELECT @RETURN=COUNT(*) FROM #TA_YYFACE
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
							ACCOUNT=@ACCOUNT AND 
							DIRECTION=CONVERT(CHAR(1),@DIRECTION)
							AND FIRMNAME=@FIRMNAME
							AND DEPARTNAME=@DEPARTNAME
					END
					ELSE
					BEGIN
						SELECT @RETURN=COUNT(*) FROM #TA_YYFACE
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
							ACCOUNT=@ACCOUNT AND 
							DIRECTION=CONVERT(CHAR(1),@DIRECTION)
							AND DEPARTNAME=@DEPARTNAME
					END
				END
				ELSE
				BEGIN
					if @FIRMNAME_INDEX<>0
					BEGIN
						SELECT @RETURN=COUNT(*) FROM #TA_YYFACE
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
							ACCOUNT=@ACCOUNT AND 
							DIRECTION=CONVERT(CHAR(1),@DIRECTION)
							AND FIRMNAME=@FIRMNAME
					END
					ELSE
					BEGIN
						SELECT @RETURN=COUNT(*) FROM #TA_YYFACE
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
							ACCOUNT=@ACCOUNT AND 
							DIRECTION=CONVERT(CHAR(1),@DIRECTION)
					END
				END
				If @RETURN<>0 
				BEGIN
					--将原记录修改
					IF @DEPARTNAME_INDEX=0
					BEGIN
						IF @FIRMNAME_INDEX=0 
						BEGIN
							UPDATE #TA_YYFACE SET TICKETNUMBER=CONVERT(VARCHAR(32),CONVERT(INT,TICKETNUMBER)+1),
								TOTALMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,TOTALMONEY)+
									CONVERT(MONEY,@TOTALMONEY)),
								QUANTITY=CONVERT(VARCHAR(50),CONVERT(MONEY,QUANTITY)+
									CONVERT(MONEY,@QUANTITY)),
								FOREINMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,FOREINMONEY)+
									CONVERT(MONEY,@FOREINMONEY))
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
								ACCOUNT=@ACCOUNT AND 
								DIRECTION=CONVERT(CHAR(1),@DIRECTION)
						END
						ELSE
						BEGIN
							UPDATE #TA_YYFACE SET TICKETNUMBER=CONVERT(VARCHAR(32),CONVERT(INT,TICKETNUMBER)+1),
								TOTALMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,TOTALMONEY)+
									CONVERT(MONEY,@TOTALMONEY)),
								QUANTITY=CONVERT(VARCHAR(50),CONVERT(MONEY,QUANTITY)+
									CONVERT(MONEY,@QUANTITY)),
								FOREINMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,FOREINMONEY)+
									CONVERT(MONEY,@FOREINMONEY))
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
								ACCOUNT=@ACCOUNT AND 
								DIRECTION=CONVERT(CHAR(1),@DIRECTION)
								AND FIRMNAME=@FIRMNAME
						END
					END
					ELSE
					BEGIN
						IF @FIRMNAME_INDEX=0 
						BEGIN
							UPDATE #TA_YYFACE SET TICKETNUMBER=CONVERT(VARCHAR(32),CONVERT(INT,TICKETNUMBER)+1),
								TOTALMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,TOTALMONEY)+
									CONVERT(MONEY,@TOTALMONEY)),
								QUANTITY=CONVERT(VARCHAR(50),CONVERT(MONEY,QUANTITY)+
									CONVERT(MONEY,@QUANTITY)),
								FOREINMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,FOREINMONEY)+
									CONVERT(MONEY,@FOREINMONEY))
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
								ACCOUNT=@ACCOUNT AND 
								DIRECTION=CONVERT(CHAR(1),@DIRECTION)
								AND DEPARTNAME=@DEPARTNAME
						END
						ELSE
						BEGIN
							UPDATE #TA_YYFACE SET TICKETNUMBER=CONVERT(VARCHAR(32),CONVERT(INT,TICKETNUMBER)+1),
								TOTALMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,TOTALMONEY)+
									CONVERT(MONEY,@TOTALMONEY)),
								QUANTITY=CONVERT(VARCHAR(50),CONVERT(MONEY,QUANTITY)+
									CONVERT(MONEY,@QUANTITY)),
								FOREINMONEY=CONVERT(VARCHAR(50),CONVERT(MONEY,FOREINMONEY)+
									CONVERT(MONEY,@FOREINMONEY))
							WHERE OPERATCODE=CONVERT(VARCHAR(32),@YW_CODE) AND
								ACCOUNT=@ACCOUNT AND 
								DIRECTION=CONVERT(CHAR(1),@DIRECTION)
								AND FIRMNAME=@FIRMNAME
								AND DEPARTNAME=@DEPARTNAME
						END
					END
				END
				ELSE
				BEGIN
					INSERT INTO #TA_YYFACE (OPERATCODE,PRODUCEDATE,VOUCHERTYPENAME,
						TICKETNUMBER,BRIEF,ACCOUNT,DIRECTION,TOTALMONEY,
						QUANTITY,FOREINMONEY,RATE,SETTLETYPENAME,SETTLENO,
						SETTLEDATE,DEPARTNAME,PERSONNAME,FIRMNAME,TICKETCODE,
						OPERATORNAME,PROJECTNAME)
						VALUES
						(CONVERT(VARCHAR(32),@YW_CODE),@VOUCHER_DATE,
						@VOUCHER_TYPENAME,'1',@BRIEF,@ACCOUNT,CONVERT(CHAR(1),@DIRECTION),
						@TOTALMONEY,@QUANTITY,@FOREINMONEY,@RATE,@SETTLETYPENAME,
						@SETTLENO,@SETTLEDATE,@DEPARTNAME,@PERSONNAME,@FIRMNAME,
						@CORCODE,@OPERATOR_NAME,@PROJECTNAME)
				END

			END

RELATIONNEXT:
		FETCH NEXT FROM CUR_RELATION INTO @RELATIONID,@DIRECTION,@ACCOUNT_INDEX,@BRIEF_INDEX,
			@TOTALMONEY_INDEX,@QUANTITY_INDEX,@FOREINMONEY_INDEX,
			@RATE_INDEX,@SETTLETYPENAME_INDEX,@SETTLENO_INDEX,@SETTLEDATE_INDEX,
			@DEPARTNAME_INDEX,@PERSONNAME_INDEX,@FIRMNAME_INDEX,@CORCODE_INDEX,
			@PROJECTNAME_INDEX,@ISSUM
		END
		SELECT @YW_ROWCOUNT=@YW_ROWCOUNT+1
LOOPNEXT:
		FETCH NEXT FROM CUR_GETVOUCHER INTO @DATA1,@DATA2,@DATA3,@DATA4,@DATA5,@DATA6
			,@DATA7,@DATA8,@DATA9,@DATA10,@DATA11,@DATA12,@DATA13,@DATA14,@DATA15
		
	END
	CLOSE CUR_RELATION
	DEALLOCATE CUR_RELATION
	SELECT @IS_ERR=''
END_SP:
	CLOSE CUR_GETVOUCHER
	DEALLOCATE CUR_GETVOUCHER
	RETURN (0)


GO
