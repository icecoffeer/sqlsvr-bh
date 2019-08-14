SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcOutDrpt]
  @store int,
  @settleno int,
  @date datetime
as
begin
  /* buy1: 零售#ls, 零售退货#lst, 后台优惠#lst91, 前台优惠#lst92 */
  select posno, flowno, wrh, realamt
    into #buy1
    from buy1
    where fildate >= @date and fildate < dateadd(day, 1, @date)
  select gid gdgid, /*2001-05-08*/#buy1.wrh, 1 cstgid,
    sum(qty) lsq, sum(buy2.realamt) lst, sum(buy2.cost) lsi, sum(qty*price) lsr--把qty*inprc改为cost因为有时候在销售之前取不到INPRC。是否考虑BUY表的INPRC取值过后再回写azer
    into #ls
    from buy2, #buy1
    where buy2.posno = #buy1.posno
    and buy2.flowno = #buy1.flowno
    and #buy1.realamt > 0
    group by gid, /*2001-05-08*/#buy1.wrh
  update #ls set wrh = goods.wrh from goods where #ls.wrh = 1 and gdgid = gid
  select gid gdgid, /*2001-05-08*/#buy1.wrh, 1 cstgid,
    -sum(qty) lstq, -sum(buy2.realamt) lstt, -sum(buy2.cost) lsti, -sum(qty*price) lstr
    into #lst
    from buy2, #buy1
    where buy2.posno = #buy1.posno
    and buy2.flowno = #buy1.flowno
    and #buy1.realamt < 0
    group by gid, /*2001-05-08*/#buy1.wrh
  update #lst set wrh = goods.wrh from goods where #lst.wrh = 1 and gdgid = gid
  select gid gdgid, /*2001-05-08*/#buy1.wrh, 1 cstgid, sum(buy21.favamt) lst91
    into #lst91
    from #buy1, buy2, buy21
    where buy2.posno = #buy1.posno
    and buy2.flowno = #buy1.flowno
    and buy21.posno = #buy1.posno
    and buy21.flowno = #buy1.flowno
    and buy21.itemno = buy2.itemno
    and FAVTYPE <= '08'
    group by gid, /*2001-05-08*/#buy1.wrh
  update #lst91 set wrh = goods.wrh from goods where #lst91.wrh = 1 and gdgid = gid
  select gid gdgid, /*2001-05-08*/#buy1.wrh, 1 cstgid, sum(buy21.favamt) lst92
    into #lst92
    from #buy1, buy2, buy21
    where buy2.posno = #buy1.posno
    and buy2.flowno = #buy1.flowno
    and buy21.posno = #buy1.posno
    and buy21.flowno = #buy1.flowno
    and buy21.itemno = buy2.itemno
    and FAVTYPE >= '09'
    group by gid, /*2001-05-08*/#buy1.wrh
  update #lst92 set wrh = goods.wrh from goods where #lst92.wrh = 1 and gdgid = gid

  /* stkout: 批发#wc, 调出#dc, 配出#pc */
  select cls, num, billto cstgid
    into #stkout
    from stkout
    where fildate >= @date and fildate < dateadd(day, 1, @date)
    and stat not in (0,7)  --2002.06.05
  select gdgid, wrh, cstgid,
    sum(qty) wcq, sum(qty*price) wct, sum(d.cost) wci, sum(qty*rtlprc) wcr
    into #wc
    from stkoutdtl d, #stkout m
    where m.cls = d.cls and m.num = d.num and m.cls = '批发'
    group by gdgid, wrh, cstgid
  select gdgid, wrh, cstgid,
    sum(qty) dcq, sum(qty*price) dct, sum(d.cost) dci, sum(qty*rtlprc) dcr
    into #dctemp
    from stkoutdtl d, #stkout m
    where m.cls = d.cls and m.num = d.num and m.cls = '调出'
    group by gdgid, wrh, cstgid
  select gdgid, wrh, cstgid,
    sum(qty) pcq, sum(qty*price) pct, sum(d.cost) pci, sum(qty*rtlprc) pcr
    into #pc
    from stkoutdtl d, #stkout m
    where m.cls = d.cls and m.num = d.num and m.cls = '配货'
    group by gdgid, wrh, cstgid

  /* 2005.04.07 by azer，只记录调出门店的出货日报*/    
  insert into #dctemp
  select d.gdgid, d.wrh, m.XCHGSTORE cstgid,
    sum(d.qty) djq, sum(d.tototal) dct, sum(d.tocost) dci, sum(d.qty*d.rtlprc) dcr
    from Mxfdtl d, Mxf m
    where m.stat in(1,2,4) and m.fromstore = (select usergid from system(nolock))
    	and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date) and m.num = d.num
    group by m.XCHGSTORE, d.gdgid, d.wrh    

  select gdgid, wrh, cstgid,
         sum(dcq) dcq, sum(dct) dct, sum(dci) dci, sum(dcr) dcr
    into #dc
    from #dctemp
    group by gdgid, wrh, cstgid

  /* stkoutbck: 批发退#wct, 配出退#pct 此处也没有考虑零售单退的azer*/
  select cls, num, billto cstgid
    into #stkoutbck
    from stkoutbck
    where fildate >= @date and fildate < dateadd(day, 1, @date)
    and stat not in (0,7)  --2002.06.05
  select gdgid, wrh, cstgid,
    sum(qty) wctq, sum(qty*price) wctt, sum(d.cost) wcti, sum(qty*rtlprc) wctr
    into #wct
    from stkoutbckdtl d, #stkoutbck m
    where m.cls = d.cls and m.num = d.num and m.cls = '批发'
    group by gdgid, wrh, cstgid
  select gdgid, wrh, cstgid,
    sum(qty) pctq, sum(qty*price) pctt, sum(d.cost) pcti, sum(qty*rtlprc) pctr
    into #pct
    from stkoutbckdtl d, #stkoutbck m
    where m.cls = d.cls and m.num = d.num and m.cls = '配货'
    group by gdgid, wrh, cstgid

  /* diralc: 直配出和直销#zpc, 直配出退和直销退#zpct*/
  select cls, num, receiver cstgid
    into #diralc
    from diralc
    where fildate >= @date and fildate < dateadd(day, 1, @date)
    and cls in ('直配出', '直配出退','直销','直销退')
    and stat not in (0,7)  --2002.06.05
  select gdgid, wrh, cstgid,
    sum(qty) zpcq, sum(qty*alcprc) zpct, sum(qty*alcprc) zpci, sum(qty*rtlprc) zpcr
    into #zpc
    from diralcdtl d, #diralc m
    where m.cls = d.cls and m.num = d.num and m.cls in( '直配出','直销')
    group by gdgid, wrh, cstgid
  select gdgid, wrh, cstgid,
    sum(qty) zpctq, sum(qty*alcprc) zpctt, sum(qty*alcprc/*2002.06.05*/) zpcti, sum(qty*rtlprc) zpctr
    into #zpct
    from diralcdtl d, #diralc m
    where m.cls = d.cls and m.num = d.num and m.cls in ('直配出退','直销退')
    group by gdgid, wrh, cstgid

  select gdgid, wrh, cstgid into #all from #ls
  union select gdgid, wrh, cstgid from #lst
  union select gdgid, wrh, cstgid from #lst91
  union select gdgid, wrh, cstgid from #lst92
  union select gdgid, wrh, cstgid from #wc
  union select gdgid, wrh, cstgid from #dc
  union select gdgid, wrh, cstgid from #pc
  union select gdgid, wrh, cstgid from #wct
  union select gdgid, wrh, cstgid from #pct
  union select gdgid, wrh, cstgid from #zpc
  union select gdgid, wrh, cstgid from #zpct

  select #all.gdgid, #all.wrh, #all.cstgid,
    isnull(lsq,0) dq1, isnull(lst,0) dt1, isnull(lsi,0) di1, isnull(lsr,0) dr1,
    isnull(wcq,0) dq2, isnull(wct,0) dt2, isnull(wci,0) di2, isnull(wcr,0) dr2,
    isnull(dcq,0) dq3, isnull(dct,0) dt3, isnull(dci,0) di3, isnull(dcr,0) dr3,
    isnull(pcq,0)+isnull(zpcq,0) dq4, isnull(pct,0)+isnull(zpct,0) dt4,
    isnull(pci,0)+isnull(zpci,0) di4, isnull(pcr,0)+isnull(zpcr,0) dr4
    into #temp1
    from #all, #ls, #wc, #dc, #pc, #zpc
    where #all.gdgid *= #ls.gdgid and #all.wrh *= #ls.wrh and #all.cstgid *= #ls.cstgid
    and #all.gdgid *= #wc.gdgid and #all.wrh *= #wc.wrh and #all.cstgid *= #wc.cstgid
    and #all.gdgid *= #dc.gdgid and #all.wrh *= #dc.wrh and #all.cstgid *= #dc.cstgid
    and #all.gdgid *= #pc.gdgid and #all.wrh *= #pc.wrh and #all.cstgid *= #pc.cstgid
    and #all.gdgid *= #zpc.gdgid and #all.wrh *= #zpc.wrh and #all.cstgid *= #zpc.cstgid

  select #all.gdgid, #all.wrh, #all.cstgid,
    isnull(lstq,0) dq5, isnull(lstt,0) dt5, isnull(lsti,0) di5, isnull(lstr,0) dr5,
    isnull(wctq,0) dq6, isnull(wctt,0) dt6, isnull(wcti,0) di6, isnull(wctr,0) dr6,
    isnull(pctq,0)+isnull(zpctq,0) dq7, isnull(pctt,0)+isnull(zpctt,0) dt7,
    isnull(pcti,0)+isnull(zpcti,0) di7, isnull(pctr,0)+isnull(zpctr,0) dr7,
    isnull(lst91,0) dt91, isnull(lst92,0) dt92
    into #temp2
    from #all, #lst, #lst91, #lst92, #wct, #pct, #zpct
    where #all.gdgid *= #lst.gdgid and #all.wrh *= #lst.wrh and #all.cstgid *= #lst.cstgid
    and #all.gdgid *= #lst91.gdgid and #all.wrh *= #lst91.wrh and #all.cstgid *= #lst91.cstgid
    and #all.gdgid *= #lst92.gdgid and #all.wrh *= #lst92.wrh and #all.cstgid *= #lst92.cstgid
    and #all.gdgid *= #wct.gdgid and #all.wrh *= #wct.wrh and #all.cstgid *= #wct.cstgid
    and #all.gdgid *= #pct.gdgid and #all.wrh *= #pct.wrh and #all.cstgid *= #pct.cstgid
    and #all.gdgid *= #zpct.gdgid and #all.wrh *= #zpct.wrh and #all.cstgid *= #zpct.cstgid

  delete from routdrpt where astore = @store and asettleno = @settleno and adate = @date

  insert into routdrpt (astore, asettleno, adate, bgdgid, bwrh, bcstgid,
    dq1, dt1, di1, dr1, dq2, dt2, di2, dr2, dq3, dt3, di3, dr3,
    dq4, dt4, di4, dr4, dq5, dt5, di5, dr5, dq6, dt6, di6, dr6,
    dq7, dt7, di7, dr7, dt91, dt92 )
  select @store, @settleno, @date, #temp1.gdgid, #temp1.wrh, #temp1.cstgid,
    dq1, dt1, di1, dr1, dq2, dt2, di2, dr2, dq3, dt3, di3, dr3,
    dq4, dt4, di4, dr4, dq5, dt5, di5, dr5, dq6, dt6, di6, dr6,
    dq7, dt7, di7, dr7, dt91, dt92
    from #temp1, #temp2
    where #temp1.gdgid = #temp2.gdgid and #temp1.wrh = #temp2.wrh and #temp1.cstgid = #temp2.cstgid
end
GO
