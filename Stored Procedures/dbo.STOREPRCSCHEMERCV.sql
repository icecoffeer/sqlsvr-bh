SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STOREPRCSCHEMERCV]
(
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
  DECLARE @GID INT,
          @CLS VARCHAR(8),
          @CODE VARCHAR(4),
          @SRC INT,
          @NSTAT INT,
          @SGID INT,
          @ICOUNT INT
  SELECT @SGID = USERGID FROM SYSTEM
  DELETE FROM NSTOREPRCSCHEME WHERE (TYPE = 1 AND NSTAT = 0
     AND ID < (SELECT MAX(ID) FROM NSTOREPRCSCHEME WHERE TYPE = 1 AND NSTAT = 0))
     OR STOREGID <> @SGID

  /*DELETE FROM NPRCSCHEMEDTL WHERE (TYPE = 1 AND NSTAT = 0
     AND ID < (SELECT MAX(ID) FROM NPRCSCHEMEDTL WHERE TYPE = 1 AND NSTAT = 0))
     OR RCV <> @SGID
     OR (CODE NOT IN (SELECT CODE FROM NSTOREPRCSCHEME WHERE TYPE = 1 AND NSTAT = 0))*/

  DELETE NPRCSCHEMEDTL
  FROM NPRCSCHEMEDTL,
  (SELECT MAX(ID) ID, PRCCLS FROM NPRCSCHEMEDTL N1 WHERE TYPE = 1 AND NSTAT = 0 GROUP BY PRCCLS) T
  WHERE NPRCSCHEMEDTL.ID < T.ID
  AND NPRCSCHEMEDTL.TYPE = 1 AND NPRCSCHEMEDTL.NSTAT = 0
  AND NPRCSCHEMEDTL.PRCCLS = T.PRCCLS

  delete from NPRCSCHEMEDTL
  where CODE not in (SELECT CODE FROM NSTOREPRCSCHEME WHERE TYPE = 1 AND NSTAT = 0)

  DECLARE PRC_STORE_RCV CURSOR FOR
    SELECT STOREGID, CLS, CODE, SRC, NSTAT FROM NSTOREPRCSCHEME
      WHERE TYPE = 1 AND NSTAT = 0
       -- AND ID = (SELECT MAX(ID) FROM NSTOREPRCSCHEME WHERE TYPE = 1 AND NSTAT = 0)
    FOR UPDATE OF NSTAT

  OPEN PRC_STORE_RCV
  FETCH NEXT FROM PRC_STORE_RCV INTO @GID, @CLS, @CODE, @SRC, @NSTAT
  WHILE @@fetch_status = 0
  BEGIN
    IF @GID = @SGID
    BEGIN
      IF @CODE = '-'
      BEGIN
        DELETE FROM PRCSCHEMEDTL WHERE PRCCLS = @CLS
        DELETE FROM NPRCSCHEMEDTL WHERE PRCCLS = @CLS
      END
      ELSE
      BEGIN
      	SELECT @ICOUNT = COUNT(*) FROM NPRCSCHEMEDTL WHERE PRCCLS = @CLS AND TYPE = 1 AND NSTAT = 0
      	IF @ICOUNT > 0
      	BEGIN
      	  DELETE FROM PRCSCHEMEDTL WHERE PRCCLS = @CLS
      	  INSERT INTO PRCSCHEMEDTL (CODE, GDGID, GDQPCSTR, PRCCLS, CTRMODE, LAUNCHBYSTORE, TOPPRC, LOWPRC)
            SELECT CODE, GDGID, GDQPCSTR, PRCCLS, CTRMODE, LAUNCHBYSTORE, TOPPRC, LOWPRC FROM NPRCSCHEMEDTL
              WHERE TYPE = 1 AND NSTAT = 0 AND CODE = @CODE --PRCCLS = @CLS
          
          --将数据插入历史表PRCSCHEMEDTLHST中
          INSERT INTO PRCSCHEMEDTLHST (CODE, GDGID, GDQPCSTR, PRCCLS, CTRMODE, LAUNCHBYSTORE, TOPPRC, LOWPRC, NOTE, DATE )
            SELECT CODE, GDGID, GDQPCSTR, PRCCLS, CTRMODE, LAUNCHBYSTORE, TOPPRC, LOWPRC, NNOTE, RCVTIME FROM NPRCSCHEMEDTL
              WHERE TYPE = 1 AND NSTAT = 0 AND CODE = @CODE
              
          DELETE FROM NPRCSCHEMEDTL WHERE TYPE = 1 AND NSTAT = 0 AND PRCCLS = @CLS
      	END  -- COUNT >0
        ELSE
        BEGIN
          SELECT @ICOUNT = COUNT(*) FROM PRCSCHEMEDTL WHERE CODE = @CODE
          IF @ICOUNT = 0
            DELETE FROM PRCSCHEMEDTL WHERE PRCCLS = @CLS
        END
      END  -- CODE <> '-'
    END  -- IF  LOCAL
    DELETE FROM NSTOREPRCSCHEME WHERE CURRENT OF PRC_STORE_RCV
    FETCH NEXT FROM PRC_STORE_RCV INTO @GID, @CLS, @CODE, @SRC, @NSTAT
  END
  CLOSE PRC_STORE_RCV
  DEALLOCATE PRC_STORE_RCV
  RETURN(0)
END
GO
