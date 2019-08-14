SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADDDIFFCOSTTORPT]
  @PI_GDGID INT,
  @PI_WRH INT,
  @PI_COST MONEY,
  @PI_ADATE DATETIME,
  @PI_SETTLENO INT
AS
BEGIN
  DECLARE @USERGID INT

  DECLARE @YNO INT

  SELECT @USERGID = USERGID FROM SYSTEM

  SELECT @YNO = YNO FROM V_YM WHERE MNO = @PI_SETTLENO

  IF NOT EXISTS(SELECT * FROM INVCHGDRPT WHERE ASTORE=@USERGID AND ASETTLENO = @PI_SETTLENO
    AND ADATE =@PI_ADATE AND BGDGID = @PI_GDGID AND BWRH = @PI_WRH)
  BEGIN
    INSERT INTO INVCHGDRPT(ASTORE,ASETTLENO,ADATE,BGDGID,BWRH,DI8,LSTUPDTIME)
      VALUES(@USERGID,@PI_SETTLENO,@PI_ADATE,@PI_GDGID,@PI_WRH,@PI_COST,GETDATE())
  END
  ELSE
  BEGIN
    UPDATE INVCHGDRPT SET
    DI8 = DI8 + @PI_COST,
    LSTUPDTIME = GETDATE()
    WHERE ASTORE=@USERGID AND ASETTLENO = @PI_SETTLENO
    AND ADATE =@PI_ADATE AND BGDGID = @PI_GDGID AND BWRH = @PI_WRH
  END

  IF NOT EXISTS(SELECT * FROM INVCHGMRPT WHERE ASTORE=@USERGID AND ASETTLENO = @PI_SETTLENO
    AND BGDGID = @PI_GDGID AND BWRH = @PI_WRH)
  BEGIN
    INSERT INTO INVCHGMRPT(ASTORE,ASETTLENO,BGDGID,BWRH,DI8)
      VALUES(@USERGID,@PI_SETTLENO,@PI_GDGID,@PI_WRH,@PI_COST)
  END
  ELSE
  BEGIN
    UPDATE INVCHGMRPT SET DI8 = DI8 + @PI_COST WHERE ASTORE=@USERGID AND ASETTLENO = @PI_SETTLENO
    AND BGDGID = @PI_GDGID AND BWRH = @PI_WRH
  END

  IF NOT EXISTS(SELECT * FROM INVCHGYRPT WHERE ASTORE=@USERGID AND ASETTLENO = @YNO
    AND BGDGID = @PI_GDGID AND BWRH = @PI_WRH)
  BEGIN
    INSERT INTO INVCHGYRPT(ASTORE,ASETTLENO,BGDGID,BWRH,DI8)
      VALUES(@USERGID,@YNO,@PI_GDGID,@PI_WRH,@PI_COST)
  END
  ELSE
  BEGIN
    UPDATE INVCHGYRPT SET DI8 = DI8 + @PI_COST WHERE ASTORE=@USERGID AND ASETTLENO = @YNO
    AND BGDGID = @PI_GDGID AND BWRH = @PI_WRH
  END
END
GO