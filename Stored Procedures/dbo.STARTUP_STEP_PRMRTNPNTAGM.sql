SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STARTUP_STEP_PRMRTNPNTAGM]
AS
BEGIN
  DECLARE
    @VNUM VARCHAR(14),
    @VPRMOFFSETNUM VARCHAR(14),
    @VRET INTEGER,
    @VMSG VARCHAR(255),
    @VSETTLENO INTEGER,
    @VCURTIME DATETIME
  SET @VCURTIME = GETDATE()
  SELECT @VSETTLENO = MAX(NO) FROM MONTHSETTLE(NOLOCK)

  INSERT INTO LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  VALUES (@VCURTIME, @VSETTLENO, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 101, '促销返点协议自动生成促销补差单' )

  DECLARE C_LINE CURSOR FOR
    SELECT NUM FROM PRMRTNPNTAGM(NOLOCK)
    WHERE STAT = 100
      AND AUTOGEN = 1
      AND GENTIME IS NOT NULL
      AND GENTIME <= @VCURTIME
      AND RTNSTAT = 0 --未生成补差单

  OPEN C_LINE
  FETCH NEXT FROM C_LINE INTO @VNUM
  WHILE @@FETCH_STATUS = 0
  BEGIN
    BEGIN TRANSACTION
    EXEC @VRET = PRMRTNPNTAGM_OCR @VCURTIME, @VNUM, 1, 1, @VPRMOFFSETNUM OUTPUT, @VMSG OUTPUT
    IF @VRET <> 0
    BEGIN
      ROLLBACK TRANSACTION
      BEGIN TRANSACTION
      SET @VMSG = SUBSTRING('促销返点协议 ' + @VNUM + ' 日结生成促销补差单失败。'
        + CHAR(10) + @VMSG, 1, 255)
      WAITFOR DELAY '0:00:0.010'
      INSERT INTO LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      VALUES(GETDATE(), @VSETTLENO, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 304, @VMSG);
      COMMIT TRANSACTION
    END ELSE
      COMMIT TRANSACTION

    FETCH NEXT FROM C_LINE INTO @VNUM
  END
  CLOSE C_LINE
  DEALLOCATE C_LINE
END
GO
