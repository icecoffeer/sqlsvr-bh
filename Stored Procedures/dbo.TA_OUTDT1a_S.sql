SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[TA_OUTDT1a_S]
	@WHERE_CLAUSE VARCHAR(255)
As
declare @BeginDate char(10)
        ,@EndDate char(10)

declare @I int

select @I=charIndex(',',@WhERE_CLAUSE)


Select @BeginDate=SubString(@WHERE_CLAUSE,1,@I-1)
Select @EndDate=SubString(@WHERE_CLAUSE,@I+1,100)

EXEC ('DECLARE CUR_GETVOUCHER CURSOR GLOBAL FOR 
	SELECT STORE.CODE A,
        STORE.NAME B,
        ''部门'' C,
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),SUM((OUTDRPT.DT1-OUTDRPT.DT5)/(1+ GOODSH.SALETAX/100)))) D,
	CONVERT(VARCHAR(100),SUM(OUTDRPT.DT1-OUTDRPT.DT5)-CONVERT(DEC(20,2),SUM((OUTDRPT.DT1-OUTDRPT.DT5)/(1+ GOODSH.SALETAX/100)))) E, 
	CONVERT(VARCHAR(100),SUM(OUTDRPT.DT1-OUTDRPT.DT5)) F,
	CONVERT(VARCHAR(2),SUM(0)) G,
	CONVERT(VARCHAR(2),SUM(0)) H, 
	''RMB'' I,
	''1'' J,
	V_GDSORTA.SORT K,
	V_GDSORTA.NAME L,
	''商品大类'' M,
	CONVERT(VARCHAR(2),SUM(0)) N,
	convert(int,GOODSH.SALETAX) O
      FROM OUTDRPT OUTDRPT(NOLOCK), GOODSH GOODSH(NOLOCK), V_GDSORTA V_GDSORTA(NOLOCK), 
           STORE STORE(NOLOCK)
      WHERE OUTDRPT.ASTORE = STORE.GID
      and OUTDRPT.BGDGID = V_GDSORTA.GID
      and OUTDRPT.BGDGID = GOODSH.GID
      and (OUTDRPT.DT1 <> 0 OR OUTDRPT.DT5 <>0)
      and v_gdsorta.sort = ''S''
 --     and GOODSH.SALE =1
--      and convert(int,GOODSH.SALETAX)<>5
      AND CONVERT(VARCHAR(10),OUTDRPT.ADATE,102) BETWEEN '''+@BEGINDATE+''' AND '''+ @ENDDATE+''' ' +  
	 'GROUP BY STORE.NAME, STORE.CODE, V_GDSORTA.SORT, V_GDSORTA.NAME,GOODSH.SALETAX')


RETURN 0









GO
