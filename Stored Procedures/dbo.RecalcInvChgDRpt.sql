SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcInvChgDRpt]
  @store int,
  @settleno int,
  @date datetime
as
begin
  /* stkin: 进货损溢#in */
  select gdgid, d.wrh,
    sum(loss) inq, sum(loss*price) int, sum(loss*price) ini, sum(loss*rtlprc) inr--成本应该为发生额
    into #in
    from stkindtl d, stkin m
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and m.num = d.num and d.cls = m.cls
    and stat not in (0,7) -- Modified by qyx 2002.04.01
    and loss <> 0
    and d.wrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid, d.wrh

  /* diralc: 直配和直销损溢#dir */
  select gdgid, d.wrh,
    sum(loss) dirq, sum(loss*price) dirt, sum(loss*price) diri, sum(loss*rtlprc) dirr
    into #dir
    from diralcdtl d, diralc m
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and m.num = d.num and d.cls = m.cls
    and stat not in (0,7) -- Modified by qyx 2002.04.01
    and m.cls in ('直配进','直配进退''直销','直销退') -- Add by qyx 2002.04.01 by azer 2005-04-07加上直销
    and loss <> 0 
    and d.wrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid, d.wrh

  /* ls: 损耗#ls */
  select gdgid, m.wrh,
    sum(qtyls) lsq, sum(d.amtls) lst, sum(d.cost) lsi, sum(qtyls*rtlprc) lsr
    into #ls
    from lsdtl d, ls m
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and m.num = d.num
    and stat > 0
    and m.wrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid, m.wrh

  /* ovf: 溢余#ovf */
  select gdgid, m.wrh,
    sum(qtyovf) ovfq, sum(d.amtovf) ovft, sum(d.cost) ovfi, sum(qtyovf*rtlprc) ovfr
    into #ovf
    from ovfdtl d, ovf m
    where fildate >= @date and fildate <= dateadd(day, 1, @date)
    and m.num = d.num
    and stat > 0
    and m.wrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid, m.wrh

  /* ck: 盘点盈亏#ck */
  select gdgid, d.wrh,
    sum(d.qty-d.acntqty) ckq, sum(d.ovfamt-d.losamt) ckt, sum(d.cost) cki, sum((d.qty-d.acntqty)*rtlprc2) ckr
    into #ck
    from ckdtl d, ck m
    where  m.num = d.num
    and ckdate >= @date and ckdate <= dateadd(day, 1, @date)
    and m.cls = 1
    and d.wrh not in (select gid from store(nolock))   --add by ysp 2002.03.06
    group by gdgid, d.wrh


  /* xf: 调拨#xfout, #xfin 加上-100仓 by azer */
  select gdgid, fromwrh wrh,
    sum(qty) xfoutq, sum(d.amt) xfoutt, sum(d.cost) xfouti, sum(qty*rtlprc) xfoutr
    into #xfout
    from xf m, xfdtl d
    where m.num = d.num
    and fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat > 0
    and m.fromwrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid, fromwrh

  select gdgid, -100 wrh,
    sum(qty) xfinq, sum(d.amt) xfint, sum(d.cost) xfini, sum(qty*rtlprc) xfinr
    into #xfin
    from xf m, xfdtl d
    where m.num = d.num
    and fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat > 0   -- Modified by qyx 2002.04.01
    and m.fromwrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid
    
  insert into #xfout(gdgid,  wrh,xfoutq,xfoutt,xfouti,xfoutr)
  select gdgid, -100 wrh,
    sum(qty) xfoutq, sum(d.amt) xfoutt, sum(d.cost) xfouti, sum(qty*rtlprc) xfoutr
    from xf m, xfdtl d
    where m.num = d.num
    and indate >= @date and indate <= dateadd(day, 1, @date)	--fildate——>indate by Ysp 2003-07-23
    and stat = 9
    and m.towrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid   
    
  insert into #xfin(gdgid, wrh,xfinq,xfint,xfini,xfinr)
  select gdgid, towrh wrh,
    sum(qty) xfinq, sum(d.amt) xfint, sum(d.cost) xfini, sum(qty*rtlprc) xfinr
    from xf m, xfdtl d
    where m.num = d.num
    and indate >= @date and indate <= dateadd(day, 1, @date)	--fildate——>indate by Ysp 2003-07-23
    and stat = 9   -- Modified by qyx 2002.04.01
    and m.towrh not in (select gid from store(nolock))   --Add by qyx 2002.04.01
    group by gdgid, towrh

--2002-08-15 2002071657763--这里要注意了。新的程序已经修改过。需要之后修改azer
  /* ZC: 库存转出#ZC */
  select gdgid, WRH wrh,
    sum(qty) zcq, sum(d.total) zct, sum(qty*inprc) zci, sum(qty*rtlprc) zcr
    into #ZC
    from gdinvchg m, gdinvchgdtl d
    where m.num = d.num
    and fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat not in (0,7)
    and d.wrh not in (select gid from store(nolock))
    group by gdgid, wrh
  /* ZR: 库存转入#ZR */
  select gdgid2 gdgid, WRH2 wrh,
    sum(qty) zrq, sum(d.total) zrt, sum(d.total) zri, sum(qty*rtlprc2) zrr
    into #ZR
    from gdinvchg m, gdinvchgdtl d
    where m.num = d.num
    and fildate >= @date and fildate <= dateadd(day, 1, @date)
    and stat not in (0,7)
    and d.wrh2 not in (select gid from store(nolock))
    group by gdgid2, wrh2

  /* prcadj: 调价#inprc #inprctmp,#rtlprctmp #rtlprc by azer*/
--核算售价调整单，记DR3 by azer
  select d.gdgid,g.wrh,
    sum(d.qty*(d.newprc-d.oldprc)) tjcr
    into #rtlprctmp
    from prcadj m ,prcadjdtl d,goodsh g
    where m.num=d.num and m.cls=m.cls and g.gid=d.gdgid    and m.cls='核算售价'
    and ((launch is null and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,g.wrh
--核算售价调整单，如果为联销还要记DI3 by azer    
  select d.gdgid,g.wrh,
    sum((d.qty*(d.newprc-d.oldprc)*g.payrate)/100) tjci
    into #inprctmp
    from prcadj m ,prcadjdtl d,goodsh g
    where m.num=d.num and m.cls=m.cls and g.gid=d.gdgid    and m.cls='核算售价' and g.sale=3
    and ((launch is null and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,g.wrh

--售价调整单，记DR3 by azer   
  insert  into #rtlprctmp 
  select d.gdgid,g.wrh,
    sum(d.qty*(isnull(d.newrtlprc,0)-isnull(d.oldrtlprc,0))) tjcr   
    from rtlprcadj m ,rtlprcadjdtl d,goodsh g
    where m.num=d.num  and g.gid=d.gdgid 
    and (isnull(d.newrtlprc,0)-isnull(d.oldrtlprc,0))<>0
    and ((launch is null and m.chkdate >= @date and m.chkdate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,g.wrh

--售价调整单，如果为联销还要记DI3 by azer        
  insert into #inprctmp   
  select d.gdgid,g.wrh,
    sum((d.qty*(isnull(d.newrtlprc,0)-isnull(d.oldrtlprc,0))*isnull(g.payrate,0))/100) tjci
    from rtlprcadj m ,rtlprcadjdtl d,goodsh g
    where m.num=d.num  and g.gid=d.gdgid and g.sale=3
    and ((launch is null and m.chkdate >= @date and m.chkdate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,g.wrh    
    
--合并调DR3
  select gdgid,wrh,sum(tjcr) tjcr
    into #rtlprc 
    from #rtlprctmp
    group by gdgid,wrh
 
--两种调价都需要记录DI3    
  insert into #inprctmp  
  select d.gdgid,g.wrh,
    sum(d.qty*(d.newprc-d.oldprc)) tjci
    from prcadj m ,prcadjdtl d,goodsh g
    where m.num=d.num and m.cls=m.cls and g.gid=d.gdgid    and m.cls in ('核算价','代销价')
    and ((launch is null and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,g.wrh 

--库存价，还要修改GDWRH。暂时不放在这里修改    
  insert into #inprctmp  
  select d.gdgid,m.wrh,
    sum(d.qty*(d.newprc-d.oldprc)) tjci
    from prcadj m ,prcadjdtl d
    where m.num=d.num and m.cls=m.cls  and m.cls = '库存价'
    and ((launch is null and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,m.wrh     

  /* ck: 盘点盈亏的DI3#ck */
 insert into #inprctmp  
  select gdgid, d.wrh,
    sum(d.cost-(d.qty-d.acntqty)*d.inprc) tjci
    from ckdtl d, ck m
    where  m.num = d.num
    and ckdate >= @date and ckdate <= dateadd(day, 1, @date)
    and m.cls = 1
    and abs((d.cost-(d.qty-d.acntqty)*d.inprc))>0.01
    and d.wrh not in (select gid from store(nolock))   --add by ysp 2002.03.06
    group by gdgid, d.wrh

--修改联销率，要记录DI3    
  insert into #inprctmp  
  select d.gdgid,g.wrh,
    sum((d.qty*(d.newprc-d.oldprc)/100)*g.rtlprc) tjci
    from prcadj m ,prcadjdtl d,goodsh g
    where m.num=d.num and m.cls=m.cls and g.gid=d.gdgid  and m.cls = '联销率'
    and ((launch is null and m.fildate >= @date and m.fildate <= dateadd(day, 1, @date)) 
    or (launch is not null and m.launch >= @date and m.launch <= dateadd(day, 1, @date)))
    group by d.gdgid,g.wrh

  select gdgid,wrh,sum(tjci) tjci
    into #inprc 
    from #inprctmp
    group by gdgid,wrh

  select gdgid, wrh into #all from #in
    union select gdgid, wrh from #dir
    union select gdgid, wrh from #ls
    union select gdgid, wrh from #ovf
    union select gdgid, wrh from #ck
    union select gdgid, wrh from #xfin
    union select gdgid, wrh from #xfout
    union select gdgid, wrh from #zc	--2002-08-15 2002071657763
    union select gdgid, wrh from #zr
    union select gdgid, wrh from #rtlprc
    union select gdgid, wrh from #inprc

  delete from rinvchgdrpt
    where astore = @store
    and asettleno = @settleno
    and adate = @date

  insert into rinvchgdrpt(astore, asettleno, adate, bgdgid, bwrh,
    dq1, di1, dr1,
    dq2, di2, dr2,
         di3, dr3,
    dq4, di4, dr4,
    dq5, di5, dr5,
    dq6, dt6, di6, dr6,	--2002-08-15 2002071657763
    dq7, dt7, di7, dr7
  )
  select @store, @settleno, @date, #all.gdgid, #all.wrh,
    isnull(inq,0)+isnull(ovfq,0)-isnull(lsq,0),
    isnull(ini,0)+isnull(ovfi,0)-isnull(lsi,0),
    isnull(inr,0)+isnull(ovfr,0)-isnull(lsr,0),
    isnull(ckq,0), isnull(cki,0), isnull(ckr,0),
    isnull(tjci,0), isnull(tjcr,0),
    isnull(xfinq,0), isnull(xfini,0), isnull(xfinr,0),
    isnull(xfoutq,0), isnull(xfouti,0), isnull(xfoutr,0),
    isnull(zrq,0), isnull(zrt,0), isnull(zri,0), isnull(zrr,0),
    isnull(zcq,0), isnull(zct,0), isnull(zci,0), isnull(zcr,0)
    from #all, #in, #dir, #ls, #ovf, #ck, #xfin, #xfout, #zc, #zr, #inprc, #rtlprc
    where #all.gdgid *= #in.gdgid
    and #all.wrh *= #in.wrh
    and #all.gdgid *= #dir.gdgid
    and #all.wrh *= #dir.wrh
    and #all.gdgid *= #ls.gdgid
    and #all.wrh *= #ls.wrh
    and #all.gdgid *= #ovf.gdgid
    and #all.wrh *= #ovf.wrh
    and #all.gdgid *= #ck.gdgid
    and #all.wrh *= #ck.wrh
    and #all.gdgid *= #xfin.gdgid
    and #all.wrh *= #xfin.wrh
    and #all.gdgid *= #xfout.gdgid
    and #all.wrh *= #xfout.wrh
    and #all.gdgid *= #zc.gdgid		--2002-08-15 2002071657763
    and #all.wrh *= #zc.wrh
    and #all.gdgid *= #zr.gdgid
    and #all.wrh *= #zr.wrh
    and #all.gdgid *= #inprc.gdgid
    and #all.wrh *= #inprc.wrh
    and #all.gdgid *= #rtlprc.gdgid
    and #all.wrh *= #rtlprc.wrh
    
end
GO
