SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcInDRpt]
  @store int,
  @settleno int,
  @date datetime
as
begin
  /* stkin */
  select cls, num, billto
    into #stkin
    from stkin
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat not in (0,7)  --2002.06.05
  select billto, gdgid, wrh,
    sum(qty) zjq, sum(qty*price) zjt, sum(qty*price) zji, sum(qty*rtlprc) zjr--进货的成本，就是进货额azer
    into #zj
    from stkindtl d, #stkin m
    where m.cls = '自营' and m.num = d.num and d.cls = m.cls
    group by billto, gdgid, wrh
  select billto, gdgid, wrh,
    sum(qty) pjq, sum(qty*price) pjt, sum(qty*price) pji, sum(qty*rtlprc) pjr
    into #pj
    from stkindtl d, #stkin m
    where m.cls = '配货' and m.num = d.num and d.cls = m.cls
    group by billto, gdgid, wrh
  select billto, gdgid, wrh,
    sum(qty) djq, sum(qty*price) djt, sum(qty*price) dji, sum(qty*rtlprc) djr
    into #djtemp
    from stkindtl d, #stkin m
    where m.cls = '调入' and m.num = d.num and d.cls = m.cls
    group by billto, gdgid, wrh

  /* Mxf 2004.7.26 qyx - Fujing - Fanduoyi 2004.09.16 2706  只对调入门店记录进货日报by azer 2005-03-20*/
  insert into #djtemp
  select m.XCHGSTORE billto,d.gdgid, d.wrh,
    sum(d.qty) djq, sum(d.tototal) djt, sum(d.tototal) dji, sum(d.qty*d.rtlprc) djr
    from Mxfdtl d, Mxf m
    where m.stat in(1,2,4) and m.tostore = (select usergid from system(nolock)) 
    	and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date) and m.num = d.num
    group by m.XCHGSTORE, d.gdgid, d.wrh
    
  select billto, gdgid, wrh,
         sum(djq) djq, sum(djt) djt, sum(dji) dji, sum(djr) djr
    into #dj
    from #djtemp
    group by billto, gdgid, wrh

  /* stkinbck */
  select cls, num, billto
    into #stkinbck
    from stkinbck
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat not in (0,7)  --2002.06.05
  select billto, gdgid, wrh,
    sum(qty) tq, sum(qty*price) tt, sum(qty*inprc) ti, sum(qty*rtlprc) tr
    into #t
    from stkinbckdtl d, #stkinbck m
    where m.num = d.num and m.cls = d.cls
    group by billto, gdgid, wrh

  /* diralc */
  select cls, num, vendor
    into #diralc
    from diralc
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat not in (0,7)  --2002.06.05
  select vendor billto, gdgid, wrh,
    sum(qty) zpjq, sum(qty*price) zpjt, sum(qty*alcprc) zpji, sum(qty*rtlprc) zpjr
    into #zpj
    from diralcdtl d, #diralc m
    where m.cls = '直配进' and m.num = d.num and d.cls = m.cls
    group by vendor, gdgid, wrh
  select vendor billto, gdgid, wrh,
    sum(qty) zpcq, sum(qty*price) zpct, sum(qty*alcprc) zpci, sum(qty*rtlprc) zpcr
    into #zpc
    from diralcdtl d, #diralc m
    where m.cls = '直配出' and m.num = d.num and d.cls = m.cls
    group by vendor, gdgid, wrh
  select vendor billto, gdgid, wrh,
    sum(qty) zxq, sum(qty*price) zxt, sum(qty*alcprc) zxi, sum(qty*rtlprc) zxr
    into #zx
    from diralcdtl d, #diralc m
    where m.cls = '直销' and m.num = d.num and d.cls = m.cls
    group by vendor, gdgid, wrh    /*2005.04.07*/
  select vendor billto, gdgid, wrh,
    sum(qty) zptq, sum(qty*price) zptt, sum(qty*alcprc) zpti, sum(qty*rtlprc) zptr
    into #zpt
    from diralcdtl d, #diralc m
    where m.cls in ('直配进退') and m.num = d.num and d.cls = m.cls
    group by vendor, gdgid, wrh
  select vendor billto, gdgid, wrh, /*2002.06.05*/
    sum(qty) zptq2, sum(qty*price) zptt2, sum(qty*alcprc) zpti2, sum(qty*rtlprc) zptr2
    into #zpt2
    from diralcdtl d, #diralc m
    where m.cls in ('直配出退') and m.num = d.num and d.cls = m.cls
    group by vendor, gdgid, wrh
  select vendor billto, gdgid, wrh, /*2002.06.05*/
    sum(qty) zxtq, sum(qty*price) zxtt, sum(qty*alcprc) zxti, sum(qty*rtlprc) zxtr
    into #zxt
    from diralcdtl d, #diralc m
    where m.cls in ('直销退') and m.num = d.num and d.cls = m.cls
    group by vendor, gdgid, wrh /*2005.04.07加上了直销和直销退by azer*/

  select billto, gdgid, wrh
    into #all
    from #zj
    union select billto, gdgid, wrh from #pj
    union select billto, gdgid, wrh from #dj
    union select billto, gdgid, wrh from #t
    union select billto, gdgid, wrh from #zpj
    union select billto, gdgid, wrh from #zpc
    union select billto, gdgid, wrh from #zpt
    union select billto, gdgid, wrh from #zpt2  /*2002.06.05*/
    union select billto, gdgid, wrh from #zx/*2005.04.07*/
    union select billto, gdgid, wrh from #zxt /*2005.04.07*/

  delete from rindrpt
    where astore = @store
    and asettleno = @settleno
    and adate = @date

  insert into rindrpt(astore, asettleno, adate, bgdgid, bvdrgid, bwrh,
    dq1, dt1, di1, dr1,
    dq2, dt2, di2, dr2,
    dq3, dt3, di3, dr3,
    dq4, dt4, di4, dr4
  )
  select @store astore, @settleno asettleno, @date adate,
    #all.gdgid bgdgid, #all.billto bvdrgid, #all.wrh bwrh,
    isnull(zjq,0)+isnull(zpcq,0)+isnull(zxq,0) dq1,/*2005.04.07*/
    isnull(zjt,0)+isnull(zpct,0)+isnull(zxt,0) dt1,/*2005.04.07*/
    isnull(zji,0)+isnull(zpci,0)+isnull(zxi,0) di1,/*2005.04.07*/
    isnull(zjr,0)+isnull(zpcr,0)+isnull(zxr,0) dr1,/*2005.04.07*/
    isnull(pjq,0)+isnull(zpjq,0) dq2,
    isnull(pjt,0)+isnull(zpjt,0) dt2,
    isnull(pji,0)+isnull(zpji,0) di2,
    isnull(pjr,0)+isnull(zpjr,0) dr2,
    isnull(djq,0) dq3,
    isnull(djt,0) dt3,
    isnull(dji,0) di3,
    isnull(djr,0) dr3,
    isnull(tq,0)+isnull(zptq,0)+isnull(zptq2,0)+isnull(zxtq,0) dq4,  /*2005.04.07*/
    isnull(tt,0)+isnull(zptt,0)+isnull(zptt2,0)+isnull(zxtt,0) dt4,/*2005.04.07*/
    isnull(ti,0)+isnull(zpti,0)+isnull(zpti2,0)+isnull(zxti,0) di4,/*2005.04.07*/
    isnull(tr,0)+isnull(zptr,0)+isnull(zptr2,0)+isnull(zxtr,0) dr4/*2005.04.07*/
    from #all, #zj, #pj, #dj, #t, #zpj, #zpc, #zpt, #zpt2,#zx,#zxt
    where #all.billto *= #zj.billto
    and #all.gdgid *= #zj.gdgid
    and #all.wrh *= #zj.wrh
    and #all.billto *= #pj.billto
    and #all.gdgid *= #pj.gdgid
    and #all.wrh *= #pj.wrh
    and #all.billto *= #dj.billto
    and #all.gdgid *= #dj.gdgid
    and #all.wrh *= #dj.wrh
    and #all.billto *= #t.billto
    and #all.gdgid *= #t.gdgid
    and #all.wrh *= #t.wrh
    and #all.billto *= #zpj.billto
    and #all.gdgid *= #zpj.gdgid
    and #all.wrh *= #zpj.wrh
    and #all.billto *= #zpc.billto
    and #all.gdgid *= #zpc.gdgid
    and #all.wrh *= #zpc.wrh
    and #all.billto *= #zpt.billto
    and #all.gdgid *= #zpt.gdgid
    and #all.wrh *= #zpt.wrh
    and #all.billto *= #zpt2.billto
    and #all.gdgid *= #zpt2.gdgid
    and #all.wrh *= #zpt2.wrh
    and #all.billto *= #zx.billto
    and #all.gdgid *= #zx.gdgid
    and #all.wrh *= #zx.wrh    
    and #all.billto *= #zxt.billto
    and #all.gdgid *= #zxt.gdgid
    and #all.wrh *= #zxt.wrh        
end
GO
