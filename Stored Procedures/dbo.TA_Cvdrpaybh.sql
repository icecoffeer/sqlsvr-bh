SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[TA_Cvdrpaybh]
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
        , lower(substring(GOODSH.sort,1,1)) B
	, VENDOR.NAME  C
	, convert(VARCHAR(100),SUM(isnull(zhcheckdtl.nopayinvqty*  zhcheckdtl.inprc,0) +zhcheckdtl.dxoutintotal + zhcheckdtl.vdrchajia - zhcheckdtl.invalidtotal)) D
        ,convert(varchar(100),sum(zhcheckdtl.inprc * zhcheckdtl.invqty+zhcheckdtl.vdrchajia)/(1+goodsh.taxrate/100)) E
	,convert(varchar(100),sum(zhcheckdtl.inprc * zhcheckdtl.invqty+zhcheckdtl.vdrchajia)*(1-100/(100+goodsh.taxrate))) F
        ,convert(varchar(100),sum(isnull(zhcheckdtl.dxoutintotal,0) - isnull(zhcheckdtl.payinvqty *  zhcheckdtl.inprc,0) - isnull(zhcheckdtl.invalidtotal,0))) G
        , convert(varchar(100),SUM(zhcheckdtl.dxouttotal)) H
        , convert(varchar(100),SUM(zhcheckdtl.acnttotal)) I
        ,CONVERT(VARCHAR(2),SUM(0)) J
        ,CONVERT(VARCHAR(2),SUM(0)) K
        ,CONVERT(VARCHAR(2),SUM(0)) L
        ,CONVERT(VARCHAR(2),SUM(0)) M
        ,CONVERT(VARCHAR(2),SUM(0)) N
        ,CONVERT(VARCHAR(2),SUM(0)) O
FROM GOODSH GOODSH(NOLOCK), VENDOR VENDOR(NOLOCK), zhcheckdtl zhcheckdtl(NOLOCK), ZHCHECK ZHCHECK(NOLOCK),vdrdrpt v(nolock)
WHERE v.bvdrgid = VENDOR.GID
and v.bgdgid=zhcheckdtl.gdgid
 and  GOODSH.GID = zhcheckdtl.gdgid
AND V.ADATE=''2002.9.2''
-- and  DEPT.CODE = GOODSH.F1 
 AND ZHCHECKDTL.NUM=ZHCHECK.NUM
 and  GOODSH.sort LIKE ''s09%''  --班组代码
-- and zhcheckdtl.num LIKE ''0202%''  
 and (VENDOR.SETTLEACCOUNT<>''经销'' or VENDOR.SETTLEACCOUNT is null)
 
'
 +'GROUP BY VENDOR.CODE,VENDOR.CODE ,VENDOR.NAME ,goodsh.taxrate,lower(substring(GOODSH.sort,1,1))')

RETURN 0






































































































































GO
