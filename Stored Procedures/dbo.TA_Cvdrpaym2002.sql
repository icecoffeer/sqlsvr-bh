SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[TA_Cvdrpaym2002]
	@WHERE_CLAUSE VARCHAR(255)
As
declare @BeginDate char(10)
        ,@EndDate char(10)

declare @I int

select @I=charIndex(',',@WhERE_CLAUSE)


Select @BeginDate=SubString(@WHERE_CLAUSE,1,@I-1)
Select @EndDate=SubString(@WHERE_CLAUSE,@I+1,100)

EXEC ('DECLARE CUR_GETVOUCHER CURSOR GLOBAL FOR 
	SELECT VENDOR.CODE A
        , lower(substring(GOODSH.F1,1,4)) B
	, VENDOR.NAME  C
	, convert(VARCHAR(100),SUM(zhcheckdtl.dxouttotal)) D
        , convert(varchar(100),sum(zhcheckdtl.dxoutintotal/1.17*0.17)) E
	,convert(varchar(100),sum(zhcheckdtl.dxoutintotal))F
        ,convert(varchar(100),sum(zhcheckdtl.dxouttotal-zhcheckdtl.dxoutintotal/1.17)) G
        , convert(varchar(100),SUM(zhcheckdtl.dxouttotal)) H
        , convert(varchar(100),SUM(zhcheckdtl.acnttotal)) I
        ,CONVERT(VARCHAR(2),SUM(0)) J
        ,CONVERT(VARCHAR(2),SUM(0)) K
        ,CONVERT(VARCHAR(2),SUM(0)) L
        ,CONVERT(VARCHAR(2),SUM(0)) M
        ,CONVERT(VARCHAR(2),SUM(0)) N
        ,CONVERT(VARCHAR(2),SUM(0)) O
FROM GOODSH GOODSH(NOLOCK), VENDOR VENDOR(NOLOCK), zhcheckdtl zhcheckdtl(NOLOCK), DEPT DEPT(NOLOCK),ZHCHECK ZHCHECK(NOLOCK)
WHERE GOODSH.BILLTO = VENDOR.GID
 and  GOODSH.GID = zhcheckdtl.gdgid
 and  DEPT.CODE = GOODSH.F1 
 AND ZHCHECKDTL.NUM=ZHCHECK.NUM
 and  GOODSH.F1 LIKE ''2z%'' 
 and zhcheckdtl.num LIKE ''0202%''  
 and VENDOR.SETTLEACCOUNT<>''经销'''
 +'GROUP BY VENDOR.CODE,  lower(substring(GOODSH.F1,1,4)),VENDOR.CODE ,VENDOR.NAME ')
RETURN 0














GO
