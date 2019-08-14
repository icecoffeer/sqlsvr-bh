SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[TA_stkin1]
	@WHERE_CLAUSE VARCHAR(255)
As
declare @BeginDate char(10)
        ,@EndDate char(10)

declare @I int

select @I=charIndex(',',@WhERE_CLAUSE)

Select @BeginDate=SubString(@WHERE_CLAUSE,1,@I-1)
Select @EndDate=SubString(@WHERE_CLAUSE,@I+1,100)

EXEC ('DECLARE CUR_GETVOUCHER CURSOR GLOBAL FOR 
	SELECT RTRIM(VENDOR.CODE) A,
        RTRIM(vendor.name) B,
        ''供应商'' C,
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),SUM(STKINDTL.TOTAL-STKINDTL.TAX))) D, 
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),SUM(STKINDTL.TAX))) E, 
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),SUM(STKINDTL.TOTAL))) F,
	V_GDSORTA.SORT G,
	V_GDSORTA.NAME H,
	''RMB'' I,
	''1'' J,
	''部门'' K,
	''00'' L,
	''海滨配送中心'' M,
	''商品大类'' N,
	convert(int,GOODSH.TAXRATE) O
	FROM STKINDTL STKINDTL(NOLOCK), STKIN STKIN(NOLOCK), 
	VENDOR VENDOR(NOLOCK),GOODSH GOODSH(NOLOCK),v_gdsorta v_gdsorta(nolock) -- ,EMPLOYEEH EMPLOYEEH(NOLOCK)
	WHERE STKIN.NUM = STKINDTL.NUM
	and  STKIN.CLS = STKINDTL.CLS
        and  STKIN.CLS =''自营''
	and  VENDOR.GID = STKIN.VENDOR
	and  (STKIN.STAT<>0)
        and  STKINDTL.GDGID = GOODSH.GID
        and  STKINDTL.GDGID = V_GDSORTA.GID
        and  (GOODSH.SALE = 1)
--        and  STKIN.PSR = EMPLOYEEH.GID
       AND CONVERT(VARCHAR(10),STKIN.FILDATE,102) BETWEEN '''+@BEGINDATE+''' AND '''+ @ENDDATE+''' ' +  
	' GROUP BY VENDOR.CODE,vendor.name,V_GDSORTA.SORT, V_GDSORTA.NAME,GOODSH.TAXRATE')

RETURN 0




























GO