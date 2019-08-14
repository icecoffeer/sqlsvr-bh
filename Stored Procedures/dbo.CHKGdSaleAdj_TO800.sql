SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKGdSaleAdj_TO800]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
    DECLARE @STAT INT, @ARET INT
    --CURSOR
    DECLARE
        @GDGID INT,         @OLDGDSALE INT,     @NEWGDSALE INT, 
        @CHGFLAG INT,       @NEWPAYRATE MONEY,  @CHGFROMDATE DATETIME,
        @GDCODE VARCHAR(20),@BWRH INT,          @BVDRGID INT,
        @FROMDATE DATETIME, @TODATE DATETIME
    DECLARE 
        @GD_SALE INT,       @GD_INVPRC MONEY,   @USERGID INT, 
        @CURSETTLENO INT,   @MODE INT,          @OPERGID INT
    SELECT @STAT = STAT FROM GDSaleAdj WHERE NUM = @NUM
    SELECT @USERGID = USERGID FROM SYSTEM
    SELECT @CURSETTLENO = MAX(NO) FROM MONTHSETTLE
    SELECT @OPERGID = GID FROM EMPLOYEE E(NOLOCK) WHERE E.CODE = ( SUBSTRING(@OPER, CHARINDEX('[', @OPER)+1, CHARINDEX(']', @OPER) - CHARINDEX('[', @OPER)-1)   )
    IF @OPERGID IS NULL SET @OPERGID = 1
	IF @STAT = 800 
	BEGIN
	    RETURN 1
    END
	--DO APPLY PROCESS --
	--
	IF OBJECT_ID('GdSaleCur_C') IS NOT NULL DEALLOCATE GdSaleCur_C
	DECLARE GdSaleCur_C CURSOR FOR 
	    SELECT GDGID, OLDGDSALE, NEWGDSALE, CHGFLAG, NEWPAYRATE, CHGFROMDATE 
	    FROM GDSALEADJDTL WHERE NUM = @NUM
	OPEN GdSaleCur_C
	FETCH NEXT FROM GdSaleCur_C INTO @GDGID, @OLDGDSALE, @NEWGDSALE, @CHGFLAG, @NEWPAYRATE, @CHGFROMDATE
	WHILE @@FETCH_STATUS=0 
	BEGIN
	    --CHECK BEGIN
	    SELECT @GD_SALE = SALE, @GDCODE = CODE, @GD_INVPRC = INVPRC
	        FROM GOODS(NOLOCK) WHERE GID = @GDGID
	    IF @GD_SALE IS NULL
	    BEGIN
	        SET @MSG = '商品:'+@GDCODE+' 不存在或者营销方式不存在。'
	        CLOSE GdSaleCur_C
	        DEALLOCATE GdSaleCur_C
	        RETURN 1 
	    END
	    IF @NEWGDSALE = @OLDGDSALE
	    BEGIN
	        SET @MSG = '调整单上商品:'+@GDCODE+' 的新营销方式和原营销方式相同，错误。'
	        CLOSE GdSaleCur_C
	        DEALLOCATE GdSaleCur_C
	        RETURN 1 
	    END
	    IF @GD_SALE = @NEWGDSALE
	    BEGIN
	        FETCH NEXT FROM GdSaleCur_C INTO @GDGID, @OLDGDSALE, @NEWGDSALE, 
	            @CHGFLAG, @NEWPAYRATE, @CHGFROMDATE 
	        CONTINUE
	    END
	    IF @GD_SALE <> @OLDGDSALE
	    BEGIN
	        SET @MSG = '商品:'+@GDCODE+' 的本地营销方式和单据原营销方式不相同，错误。'
	        CLOSE GdSaleCur_C
	        DEALLOCATE GdSaleCur_C
	        RETURN 1 
	    END
	    --CHECK END
	    IF @CHGFLAG = 0 --仅仅修改属性
	    BEGIN
	        EXEC @ARET = GdChgSaleBasic @GDGID, @OLDGDSALE, @NEWGDSALE, @GD_INVPRC, @NEWPAYRATE
	        IF @ARET <> 0 
	        BEGIN
    	        SET @MSG = '更新商品:'+@GDCODE+'营销方式时，发生错误，方式0。'
    	        CLOSE GdSaleCur_C
    	        DEALLOCATE GdSaleCur_C
    	        RETURN 1 
	        END
	        UPDATE GOODS SET LSTUPDTIME = GETDATE(),MODIFIER = @OPERGID WHERE GID = @GDGID
	    END
	    ELSE IF @CHGFLAG IN (1,2,3) --修改本期数据
	    BEGIN
	        EXEC @ARET = GdChgSaleBasic @GDGID, @OLDGDSALE, @NEWGDSALE, @GD_INVPRC, @NEWPAYRATE
	        IF @ARET <> 0 
	        BEGIN
    	        SET @MSG = '更新商品:'+@GDCODE+'营销方式时，发生错误，方式0。'
    	        CLOSE GdSaleCur_C
    	        DEALLOCATE GdSaleCur_C
    	        RETURN 1 
	        END
	        IF @CHGFLAG = 2 SET @MODE = 0
	        ELSE IF @CHGFLAG = 1 SET @MODE = 1
	        ELSE IF @CHGFLAG = 4 SET @MODE = 2
	        ELSE
	        BEGIN
    	        SET @MSG = '更新商品:'+@GDCODE+'营销方式时，发现错误的更新模式。'
    	        CLOSE GdSaleCur_C
    	        DEALLOCATE GdSaleCur_C
    	        RETURN 1 
	        END
	        IF @MODE = 4 
	        BEGIN
	            SET @FROMDATE = @CHGFROMDATE
	            SET @TODATE = CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102))
	        END
	        ELSE BEGIN
	            SET @FROMDATE = NULL
	            SET @TODATE = NULL
	        END
	        
            IF OBJECT_ID('GdSaleCur_C2') IS NOT NULL DEALLOCATE GdSaleCur_C2
            DECLARE GdSaleCur_C2 CURSOR
                FOR SELECT BVDRGID, BWRH FROM V_VDRYRPT WHERE ASTORE = @USERGID AND BGDGID = @GDGID
            OPEN GdSaleCur_C2
            FETCH NEXT FROM GdSaleCur_C2 INTO @BVDRGID, @BWRH
            WHILE @@FETCH_STATUS=0
            BEGIN
                EXEC @ARET = GdChgSale 
                    @USERGID, @CURSETTLENO, @GDGID, @OLDGDSALE, @NEWGDSALE, 
                    @GD_INVPRC, @NEWPAYRATE, @MODE, @FROMDATE, @TODATE, @BVDRGID, @BWRH, @OPERGID
                IF @ARET <> 0
                BEGIN
                    SET @MSG = '更新商品:'+@GDCODE+'营销方式时，更新错误[GdChgSale]。'
                    CLOSE GdSaleCur_C2
                    DEALLOCATE GdSaleCur_C2
                    CLOSE GdSaleCur_C
                    DEALLOCATE GdSaleCur_C
                    RETURN 1
                END
                FETCH NEXT FROM GdSaleCur_C2 INTO @BVDRGID, @BWRH
            END
            CLOSE GdSaleCur_C2
            DEALLOCATE GdSaleCur_C2
            UPDATE GOODS SET LSTUPDTIME = GETDATE(),MODIFIER = @OPERGID WHERE GID = @GDGID
	    END
	    ELSE
	    BEGIN
	        SET @MSG = '更新商品:'+@GDCODE+'营销方式时，修改模式[CHGFLAG]错误。'
	        CLOSE GdSaleCur_C
	        DEALLOCATE GdSaleCur_C
	        RETURN 1 
	    END
        FETCH NEXT FROM GdSaleCur_C INTO @GDGID, @OLDGDSALE, @NEWGDSALE, @CHGFLAG, @NEWPAYRATE, @CHGFROMDATE 
    END
    CLOSE GdSaleCur_C
    DEALLOCATE GdSaleCur_C
	
	--DO APPLY PROCESS --
    UPDATE GdSaleAdj SET
        STAT = 800,
        CHKDATE = GETDATE(),
        CHECKER = @OPER,
        LSTUPDTIME = GETDATE()
    WHERE NUM = @NUM
    EXEC GdSaleAdjADDLOG @NUM,1400,'',@OPER
    RETURN 0
END
GO
