SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SVIFILLTMPSVI](
    @NUM VARCHAR(16),
    @SPWRH INT,
    @p_isWrh INT,
    @CWRH INT,
    @SPPSR INT,
    @p_isPsrer INT,
    @CPSR INT,
    @SPSTORE INT,
    @p_isByStore INT,
    @CSTORE INT,
    @PVDRGID INT
)
AS
BEGIN
  DECLARE @WRH VARCHAR(100), @WCODE VARCHAR(10)
  DECLARE @PSR VARCHAR(50), @PCODE VARCHAR(10)
  DECLARE @STORE VARCHAR(100), @SCODE VARCHAR(16)
  DECLARE @STCOUNT INT
  DECLARE     @VNAME VARCHAR(100), @VCODE VARCHAR(16)
  IF @SPWRH = 1
    SELECT @WRH = RTRIM(NAME) + '[' + RTRIM(CODE) +']', @WCODE = CODE FROM WAREHOUSE WHERE
            GID = @CWRH
  ELSE
  BEGIN
    IF @p_isWrh = 1 
    BEGIN
      SELECT @STCOUNT = COUNT(*) FROM #WRH
      IF @STCOUNT = 1 
        SELECT @WRH = RTRIM(NAME) + '[' + RTRIM(CODE) +']', @WCODE = CODE FROM WAREHOUSE WHERE
            GID = (SELECT MIN(GID) FROM #WRH)
      ELSE
        SELECT @WRH = '未知[-]', @WCODE = '-' 
    END
    ELSE
      SELECT @WRH = '未知[-]', @WCODE = '-' 
  END
  
  IF @SPPSR = 1
    SELECT @PSR = RTRIM(NAME) + '[' + RTRIM(CODE) +']', @PCODE = CODE FROM EMPLOYEE WHERE
            GID = @CPSR
  ELSE
  BEGIN
    IF @p_isPsrer = 1 
    BEGIN
      SELECT @STCOUNT = COUNT(*) FROM #PSR
      IF @STCOUNT = 1 
        SELECT @PSR = RTRIM(NAME) + '[' + RTRIM(CODE) +']', @PCODE = CODE FROM EMPLOYEE WHERE
            GID = (SELECT MIN(GID) FROM #PSR)
      ELSE
        SELECT @PSR  = '未知[-]', @PCODE = '-' 
    END
    ELSE
      SELECT @PSR = '未知[-]', @PCODE = '-' 
  END  
  
  IF @SPSTORE = 1
    SELECT @STORE = RTRIM(NAME) + '[' + RTRIM(CODE) +']', @SCODE = CODE FROM STORE WHERE
            GID = @CSTORE
  ELSE
  BEGIN
    IF @p_isByStore = 1 
    BEGIN
      SELECT @STCOUNT = COUNT(*) FROM #STORE
      IF @STCOUNT = 1 
        SELECT @STORE = RTRIM(NAME) + '[' + RTRIM(CODE) +']', @SCODE = CODE FROM STORE WHERE
            GID = (SELECT MIN(GID) FROM #STORE)
      ELSE
        SELECT @STORE = '多个门店[-]', @SCODE = '-' 
    END
    ELSE
      SELECT @STORE = '多个门店[-]', @SCODE = '-' 
  END 
  SELECT @STCOUNT = COUNT(*) FROM SVIDTL WHERE NUM = @NUM
  SELECT @VNAME = RTRIM(NAME) + '[' + RTRIM(CODE) + ']', @VCODE= CODE FROM VENDOR WHERE GID = @PVDRGID
  INSERT INTO #SVI (NUM, VDRCODE,VENDOR, PSRCODE, PSR, STCODE, STORE, WRHCODE, WRH, LINE) VALUES
        (@NUM,@VCODE, @VNAME, @PCODE, @PSR, @SCODE, @STORE, @WCODE, @WRH, @STCOUNT)
  RETURN 0
END
GO
