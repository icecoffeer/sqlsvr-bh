SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcVdrDRpt]
	@store int,
    @settleno int,
    @date datetime
as
begin
	/* 进货: 自营 */
	select m.billto vdrgid, d.wrh wrh, d.gdgid gdgid,
    	sum(d.qty) inq, sum(d.total) in_t
    	into #in
    	from stkin m, stkindtl d
        where m.cls = d.cls and m.num = d.num
        and m.cls = '自营' and m.stat = 6
        and m.chkdate >= @date and m.chkdate < dateadd(day, 1, @date)
        group by m.billto, d.wrh, d.gdgid
    /* 进货: 自营退 */
    insert into #in(vdrgid, wrh, gdgid, inq, in_t)
    	select m.billto, d.wrh, d.gdgid,
        	-sum(d.qty), -sum(d.total)
        from stkinbck m, stkinbckdtl d
        where m.cls = d.cls and m.num = d.num
        and m.cls = '自营' and m.stat = 6
        and m.chkdate >= @date and m.chkdate < dateadd(day, 1, @date)
        group by m.billto, d.wrh, d.gdgid
    /* 进货: 直配出 */
    insert into #in(vdrgid, wrh, gdgid, inq, in_t)
    	select m.vendor, d.wrh, d.gdgid,
        	sum(d.qty), sum(d.total)
        from diralc m, diralcdtl d
        where m.cls = d.cls and m.num = d.num
        and m.cls = '直配出' and stat = 6
        and m.chkdate >= @date and m.chkdate < dateadd(day, 1, @date)
        group by m.vendor, d.wrh, d.gdgid
    /* 进货: 直配出退 */
    insert into #in(vdrgid, wrh, gdgid, inq, in_t)
    	select m.vendor, d.wrh, d.gdgid,
        	-sum(d.qty), -sum(d.total)
        from diralc m, diralcdtl d
        where m.cls = d.cls and m.num = d.num
        and m.cls = '直配出退' and stat = 6
        and m.chkdate >= @date and m.chkdate < dateadd(day, 1, @date)
        group by m.vendor, d.wrh, d.gdgid
    select vdrgid, wrh, gdgid, sum(inq) inq, sum(in_t) in_t
    	into #in1
        from #in
        group by vdrgid, wrh, gdgid

    /* 销售 */
    select g.billto vdrgid, bwrh wrh, bgdgid gdgid,
    	dq1 + dq2 - dq5 - dq6 outq, dt1 + dt2 - dt5 - dt6 outt, 
        di1 + di2 - di5 - di6 outt2
    	into #out
        from outdrpt o, goodsh g
        where astore = @store and asettleno = @settleno
        and adate = @date
        and o.bgdgid = g.gid
--2001-04-15
    select vdrgid, wrh, gdgid, sum(outq) outq, sum(outt) outt,sum(outt2) outt2
    	into #out1
        from #out
        group by vdrgid, wrh, gdgid

    /* 销售分配 */

    /* 付款 */
    select m.billto vdrgid, m.wrh wrh, d.gdgid gdgid,
    	sum(qty) payq, sum(total) payt, sum(stotal) pays
    	into #pay
        from pay m, paydtl d
        where m.num = d.num and m.stat > 0
        and m.fildate >= @date and m.fildate < dateadd(day, 1, @date)
        group by m.billto, m.wrh, d.gdgid
--2001-04-15
    select vdrgid, wrh, gdgid, sum(payq) payq, sum(payt) payt,sum(pays) pays
    	into #pay1
        from #pay
        group by vdrgid, wrh, gdgid

    /* 应付款调整 */
    select m.billto vdrgid, m.wrh wrh, d.gdgid gdgid,
    	sum(nqty) adjq, sum(ntotal) adjt   --2001-04-15
    	into #adj
        from payadj m, payadjdtl d
        where m.num = d.num and m.stat > 0
        and m.fildate >= @date and m.fildate < dateadd(day, 1, @date)
        group by m.billto, m.wrh, d.gdgid
--2001-04-15
    select vdrgid, wrh, gdgid, sum(adjq) adjq, sum(adjt) adjt
    	into #adj1
        from #adj
        group by vdrgid, wrh, gdgid

	select vdrgid, wrh, gdgid into #all from #in1
    	union select vdrgid, wrh, gdgid from #out1
        union select vdrgid, wrh, gdgid from #pay1
        union select vdrgid, wrh, gdgid from #adj1

    delete from rvdrdrpt
    	where astore = @store
        and asettleno = @settleno
        and adate = @date

    insert into rvdrdrpt (
    	astore, asettleno, adate, bvdrgid, bwrh, bgdgid,
        dq1, dq2, dq3, dq4, dq5, dq6,
        dt1, dt2, dt3, dt4, dt5, dt6, dt7, di2)
    select
    	@store, @settleno, @date, #all.vdrgid, #all.wrh, #all.gdgid,
        sum(isnull(inq, 0)), sum(isnull(outq, 0)),
        sum(case when goodsh.sale = 1 then isnull(inq, 0) else isnull(outq, 0) end),
        sum(isnull(payq, 0)), 0, sum(isnull(adjq, 0)),
        sum(isnull(in_t, 0)), sum(isnull(outt, 0)),
        sum(case when goodsh.sale = 1 then isnull(in_t, 0) else isnull(outt2, 0) end),
--            when 2 then isnull(outt, 0) * invdrpt.fdxprc	2001-04-03
--            when 3 then isnull(outt, 0) * invdrpt.fpayrate / 100 end),
	sum(isnull(payt, 0)), 0, sum(isnull(adjt, 0)),
        sum(isnull(pays, 0)), sum(isnull(outt2, 0))
    from #all, #in1, #out1, #pay1, #adj1, goodsh(nolock)
    where #all.vdrgid *= #in1.vdrgid and #all.gdgid *= #in1.gdgid
    and #all.wrh *= #in1.wrh
    and #all.vdrgid *= #out1.vdrgid and #all.gdgid *= #out1.gdgid
    and #all.wrh *= #out1.wrh
    and #all.vdrgid *= #pay1.vdrgid and #all.gdgid *= #pay1.gdgid
    and #all.wrh *= #pay1.wrh
    and #all.vdrgid *= #adj1.vdrgid and #all.gdgid *= #adj1.gdgid
    and #all.wrh *= #adj1.wrh
    and #all.gdgid = goodsh.gid
--    and #all.gdgid *= invdrpt.bgdgid and #all.wrh *= invdrpt.bwrh	2001-04-03
    group by #all.vdrgid, #all.wrh, #all.gdgid
end
GO
