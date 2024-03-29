SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STOREOPERSCHEME_OCR]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @STOREGID INT,
    @SORTCODE VARCHAR(13),
    @GDGID INT,
    @USERGID INT,
    @ZBGID INT,
    @ISZB INT

  SELECT @USERGID = USERGID, @ZBGID = ZBGID FROM SYSTEM

  DECLARE C_CUR CURSOR FOR
    SELECT SORTCODE, GDGID 
      FROM STORESCHSORTGOODS WHERE NUM = @Num
  OPEN C_CUR
  FETCH NEXT FROM C_CUR INTO @SORTCODE, @GDGID
  WHILE @@FETCH_STATUS = 0
  BEGIN
    --处理所有生效门店,按后单压前单进行生效
  	DECLARE C_SDTL CURSOR FOR
      SELECT STOREGID FROM SCHEMELAC(NOLOCK)
      WHERE NUM = @Num
    OPEN C_SDTL
    FETCH NEXT FROM C_SDTL INTO @STOREGID
    WHILE @@FETCH_STATUS = 0
    BEGIN
    	IF EXISTS (SELECT 1 FROM CURSTOREOPERSCHEME
        WHERE STOREGID = @STOREGID AND GDGID = @GDGID
        )
      BEGIN
        DELETE FROM CURSTOREOPERSCHEME
        WHERE STOREGID = @STOREGID AND GDGID = @GDGID
      END

      IF @STOREGID = @ZBGID
        SET @ISZB = 1
      ELSE
        SET @ISZB = 0

  	  INSERT INTO CURSTOREOPERSCHEME(STOREGID, SORTCODE, GDGID, ISOPER, ISNECESSARY, ISZB)
      SELECT @STOREGID, @SORTCODE, @GDGID, ISOPER, ISNECESSARY, @ISZB
      FROM STORESCHSORTGOODS(nolock)
        WHERE NUM = @Num and GDGID = @GDGID

      FETCH NEXT FROM C_SDTL INTO @STOREGID
    END
    CLOSE C_SDTL
    DEALLOCATE C_SDTL

    --处理总部的本店记录,若各门店的这一商品存在经营的,那么总部的也更新为可经营;
    --若所有门店都不经营,那么总部的更新为不经营.
    DECLARE @ISOPER INT
    IF @USERGID = @ZBGID
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM CURSTOREOPERSCHEME
        WHERE STOREGID = @USERGID AND GDGID = @GDGID
        )
      BEGIN
        INSERT INTO CURSTOREOPERSCHEME(STOREGID, SORTCODE, GDGID, ISOPER, ISNECESSARY, ISZB)
        SELECT @USERGID, @SORTCODE, @GDGID, ISOPER, ISNECESSARY, 1
        FROM STORESCHSORTGOODS(nolock)
          WHERE NUM = @Num and GDGID = @GDGID
      END

      IF EXISTS(SELECT 1 FROM CURSTOREOPERSCHEME WHERE (STOREGID <> @USERGID) AND ISOPER = 1)
        SET @ISOPER = 1
      ELSE
        SET @ISOPER = 0

      UPDATE CURSTOREOPERSCHEME
        SET ISOPER = @ISOPER
      WHERE STOREGID = @USERGID AND GDGID = @GDGID
    END

    FETCH NEXT FROM C_CUR INTO @SORTCODE, @GDGID
  END
  CLOSE C_CUR
  DEALLOCATE C_CUR

  RETURN(0)
end
GO
