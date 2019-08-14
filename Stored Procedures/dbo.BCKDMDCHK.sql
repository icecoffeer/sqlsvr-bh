SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BCKDMDCHK]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @VRET INT
	DECLARE @VSTAT INT
	DECLARE @VACTNAME CHAR(40)
	DECLARE @VSTATNAME CHAR(40)
	DECLARE @EXP DATETIME
	DECLARE @LKNUM VARCHAR(13)
    SET @VRET = 1;

	SELECT @VSTAT = STAT FROM BCKDMD
	WHERE NUM = @NUM
	IF @@ROWCOUNT = 0
	BEGIN
		SET @MSG = '单据' + @NUM + '不存在'
		RETURN 1
	END
	IF @TOSTAT in (401, 3000, 400) -- SZ ADD 1524 --ShenMin 400->3000
	BEGIN
	  SELECT @EXP = EXPDATE FROM BCKDMD WHERE NUM = @NUM
	  IF (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
	  BEGIN
	    SET @MSG = '单据' + @NUM + '已经超过到效日期'
	    RETURN 1
	  END
	END

	IF @VSTAT = 0 AND @TOSTAT = 401
	BEGIN
	  EXEC @VRET = CHKBCKDMDTO401 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
         -- RETURN @VRET
    END
	ELSE IF @VSTAT = 401 AND @TOSTAT = 3000
	BEGIN
      --2005.7.18, Edited by ShenMin, 增加"预审"状态
      EXEC @VRET = CHKBCKDMDTO1600 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT

	  EXEC @VRET = CHKBCKDMDTO400 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          --RETURN @VRET
    END
	ELSE IF @VSTAT = 401 AND @TOSTAT = 411
	BEGIN
	  EXEC @VRET = CHKBCKDMDTO411 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END
    --2005.7.18, Edited by ShenMin, 增加"预审"状态
    ELSE IF @VSTAT = 401 AND @TOSTAT = 1600
	BEGIN
	  EXEC @VRET = CHKBCKDMDTO1600 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END
    ELSE IF @VSTAT = 1600 AND @TOSTAT = 3000
	BEGIN
	  EXEC @VRET = CHKBCKDMDTO400 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
	  if (select Optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'UseNewAlcBckFlow')) = 1
        RETURN @VRET
    END
    ELSE IF @VSTAT = 1600 AND @TOSTAT = 411
	BEGIN
	  EXEC @VRET = CHKBCKDMDTO411 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
         -- RETURN @VRET
    END
	IF (@VSTAT IN (401,3000,1600,400)) AND @TOSTAT = 1400  --终止
	BEGIN
	  EXEC @VRET = CHKBCKDMD_TO1400 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
	END
	ELSE IF ((@VSTAT = 400) or (@VSTAT = 3100)) AND @TOSTAT = 300  --ShenMin
	BEGIN
	  EXEC @VRET = CHKBCKDMDTO300 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
      --RETURN @VRET
    END
	ELSE IF @VSTAT = 300 AND @TOSTAT = 300  --进退单据复核时触发
	BEGIN
      RETURN 0
    END

    --ShenMin
    ELSE IF @VSTAT = 3000 AND @TOSTAT = 3100
	BEGIN
      EXEC @VRET = CHKBCKDMDTO3100 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
        --RETURN @VRET
    END

    --Added by pengke 2004.11.1
    ELSE IF @VSTAT in (400, 3000) AND @TOSTAT = 410 --ShenMin
    BEGIN
      EXEC @VRET = CHKBCKDMDTO410 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
     -- RETURN @VRET
    END
	IF @VRET = 1
	  BEGIN
	    SELECT @VACTNAME = ACTNAME FROM MODULESTAT(NOLOCK) WHERE NO = @TOSTAT
	    SELECT @VSTATNAME = STATNAME FROM MODULESTAT(NOLOCK) WHERE NO = @VSTAT
        SET @MSG = '不能' + @VACTNAME + '状态为' + @VSTATNAME + '的退货申请单'
        RETURN 1
    END;

	if (select Optionvalue from hdoption where (moduleno = 518) and (optioncaption = 'ChkSend')) = 1
	  begin
      if @TOSTAT in (401, 400, 411, 410, 3000, 3100)
        begin
        	if not exists(select 1 from BCKDMD B(nolock), SYSTEM S(nolock)
        	               where B.NUM = @NUM
        	                 and B.SRC = S.USERGID and B.DMDSTORE <> S.USERGID
        	                 and STAT in(401, 411))
        	  exec @VRET = SENDBCKDMD @NUM, @OPER, @CLS, @TOSTAT, @MSG output;
        end;
	  end;
	return @VRET;
END
GO
