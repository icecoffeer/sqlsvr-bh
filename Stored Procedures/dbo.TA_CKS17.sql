SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[TA_CKS17]
	@WHERE_CLAUSE VARCHAR(255)
As
declare @BeginDate char(10)
        ,@EndDate char(10)

declare @I int

select @I=charIndex(',',@WhERE_CLAUSE)


Select @BeginDate=SubString(@WHERE_CLAUSE,1,@I-1)
Select @EndDate=SubString( @WHERE_CLAUSE,@I+1,100)

EXEC ('DECLARE CUR_GETVOUCHER CURSOR GLOBAL FOR 
	SELECT ''部门'' A,
        vendor.code B,
        ''部门'' C,
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),sum((( CKDTL.QTY -CKDTL.ACNTQTY)*CKDTL.INPRC)/(1+goodsh.taxrate/100)))) D,
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),sum((( CKDTL.QTY -CKDTL.ACNTQTY)*CKDTL.INPRC)/(1+goodsh.taxrate/100)*goodsh.taxrate/100))) E, 
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),sum((( CKDTL.QTY -CKDTL.ACNTQTY)*CKDTL.INPRC)))) F,
	CONVERT(VARCHAR(100),CONVERT(DEC(20,2),sum((( CKDTL.QTY -CKDTL.ACNTQTY)*CKDTL.INPRC)/(1+goodsh.taxrate/100)*goodsh.taxrate/100)/1.17))  G,
	CONVERT(VARCHAR(2),SUM(0)) H, 
	''RMB'' I,
	''1'' J,
	''RMB'' K,
	''RMB'' L,
	''商品大类'' M,
	''RMB'' N,
	''RMB'' O
      FROM ck ck(NOLOCK),ckdtl ckdtl(nolock), GOODSH GOODSH(NOLOCK), vendor vendor(NOLOCK)
      WHERE ck.num=ckdtl.num and goodsh.gid=ckdtl.gdgid and vendor.gid=goodsh.billto
	and goodsh.f1 like ''s0102%'' and goodsh.taxrate=17
        and goodsh.prctype=0
      	and goodsh.sale<>1 
	AND CONVERT(VARCHAR(10),ck.ckdate,102) BETWEEN '''+@BEGINDATE+''' AND '''+ @ENDDATE+''' ' +  
	 'GROUP BY vendor.code')


RETURN 0























GO
