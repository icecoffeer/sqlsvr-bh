SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[TA_VDRPAYMcs]
	@WHERE_CLAUSE VARCHAR(255)
As
declare @BeginDate char(10)
        ,@EndDate char(10)

declare @I int
select @I=charIndex(',',@WhERE_CLAUSE)

Select @BeginDate=SubString(@WHERE_CLAUSE,1,@I-1)
Select @EndDate=SubString(@WHERE_CLAUSE,@I+1,100)

EXEC ('DECLARE CUR_GETVOUCHER CURSOR GLOBAL FOR 
	 select lower(GOODSH.f1) a
        , convert(varchar(10),goodsh.taxrate) b
        , m.newCODE c
        , VENDOR.NAME d
,case when goodsh.taxrate=17 then convert(varchar(100),SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100))) else ''0'' end e
,case when goodsh.taxrate=13 then convert(varchar(100),SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100)))  else ''0'' end f
,case when goodsh.taxrate=10 then convert(varchar(100),SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100))) else ''0'' end g
,case when goodsh.taxrate=0  then convert(varchar(100),SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100)))  else ''0''end h
,case when goodsh.taxrate=17 then convert(varchar(100), SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100)*(goodsh.taxrate/100))) else ''0'' end i
,case when goodsh.taxrate=13 then convert(varchar(100), SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100)*(goodsh.taxrate/100))) else ''0'' end j
,case when goodsh.taxrate=10 then convert(varchar(100), SUM((isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))/(1+goodsh.taxrate/100)*(goodsh.taxrate/100)))  else ''0''end k
        ,convert(varchar(100), SUM(isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0))) l
        ,''g'' m
        ,''g'' n
        ,''g'' o
        FROM vdrdrpttmp vdrdrpttmp(NOLOCK),VENDOR VENDOR(NOLOCK), GOODSH GOODSH(NOLOCK),myhvendor1 m,
        dept dept(nolock)
        WHERE GOODSH.GID = vdrdrpttmp.bgdgid
 and  VENDOR.GID = vdrdrpttmp.bvdrgid
 and vendor.gid = m.lgid
 and dept.code=goodsh.f1
 and ( goodsh.sale<>1 )
--and vdrdrpttmp.adate>=''2004.12.18''  
 and GOODSH.f1  LIKE ''s%''  --班组代码
and isnull(vdrdrpttmp.di2,0)-isnull(vdrdrpttmp.dt4,0)+isnull(vdrdrpttmp.dt6,0)<>0
 AND CONVERT(VARCHAR(10),vdrdrpttmp.ADATE,102) BETWEEN '''+@BEGINDATE+''' AND '''+ @ENDDATE+''' '
 +'GROUP BY lower(GOODSH.f1)  ,dept.name, m.newcode,goodsh.taxrate, VENDOR.NAME'
)
RETURN 0

RETURN 0








































































GO
