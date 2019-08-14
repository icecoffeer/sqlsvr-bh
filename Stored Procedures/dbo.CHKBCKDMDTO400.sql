SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKBCKDMDTO400]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @CT INT,              @LmtOperForNotSplitMDBill int,
	        @USERGID INT,         @SRCNUM CHAR(14),
	        @SRC INT
	DECLARE @EXP DATETIME
	EXEC OPTREADINT 518,'LmtOperForNotSplitMDBill',0,@LmtOperForNotSplitMDBill OUTPUT
	SELECT @USERGID = USERGID FROM SYSTEM
	SELECT @SRCNUM = SRCNUM, @SRC = SRC FROM BCKDMD WHERE NUM = @NUM
	SELECT @CT = COUNT(*) FROM BCKDMD A,BCKDMDDTL B
	  WHERE A.NUM = @NUM AND A.NUM = B.NUM AND B.QTY is NULL
	IF @CT > 0
	BEGIN
		SET @MSG = '存在没有设置数量的记录!'
		RETURN 1
	END
	SELECT @EXP = EXPDATE FROM BCKDMD WHERE NUM = @NUM
    IF (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
    BEGIN
      SET @MSG ='单据已经过期。'
	RETURN 1
    END

	IF @LmtOperForNotSplitMDBill = 1 AND @SRC <> @USERGID
	  AND (@SRCNUM IS NULL OR RTRIM(@SRCNUM) = '')
	BEGIN
		SET @MSG ='单据是门店单据但未经过拆分不能审批。'
		RETURN 1
	END
      --ShenMin
	if (select Optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'UseNewAlcBckFlow')) <> 1
	  begin
	    UPDATE BCKDMD SET
	    	STAT = 400,
	    	CACLDATE = GETDATE(),
	    	CANCELER = @OPER,
	    	LSTUPDTIME = GETDATE()
	    WHERE NUM = @NUM
	    EXEC BCKDMDADDLOG @NUM, 400, '', @OPER
	  end
	else
	  begin
	    UPDATE BCKDMD SET
	    	STAT = 3000,
	    	CACLDATE = GETDATE(),
	    	CANCELER = @OPER,
	    	LSTUPDTIME = GETDATE()
	    WHERE NUM = @NUM
	    EXEC BCKDMDADDLOG @NUM, 3000, '', @OPER
	  end
	--if (select optionvalue from hdoption where optioncaption = 'ChkSend' and moduleno = 518) = 1

	RETURN 0
END
GO
