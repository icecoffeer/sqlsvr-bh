SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[TA_VDRPAYM]
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
        , dept.name b
        , VENDOR.CODE c
        , VENDOR.NAME d
        , convert(varchar(100), SUM(vdrdrpt.di2/(1+goodsh.taxrate/100))) e
        ,convert(varchar(100), SUM(vdrdrpt.di2/(1+goodsh.taxrate/100)*(goodsh.taxrate/100))) f
        ,convert(varchar(100), SUM(vdrdrpt.di2)) g
        ,''g'' h
        ,''g'' i
	,''A'' j
	,''B'' k
	, ''C'' l
	, ''D'' m
	, ''E'' n
	, ''F'' o
        FROM vdrdrpt vdrdrpt(NOLOCK), VENDOR VENDOR(NOLOCK), GOODSH GOODSH(NOLOCK),
        dept dept(nolock)
        WHERE GOODSH.GID = vdrdrpt.bgdgid
 and  VENDOR.GID = vdrdrpt.bvdrgid
 and dept.code=goodsh.f1
 and ( goodsh.sale<>1 )
--and vdrdrpt.adate>=''2004.12.18''  and goodsh.taxrate=17 --税率
 and GOODSH.f1  LIKE ''n0105%''  --班组代码
and vdrdrpt.di2<>0
 AND CONVERT(VARCHAR(10),vdrdrpt.ADATE,102) BETWEEN '''+@BEGINDATE+''' AND '''+ @ENDDATE+''' '
 +'GROUP BY lower(GOODSH.f1)  ,dept.name, VENDOR.CODE, VENDOR.NAME'
)
RETURN 0

RETURN 0



















































































































































































































































































































































































GO
