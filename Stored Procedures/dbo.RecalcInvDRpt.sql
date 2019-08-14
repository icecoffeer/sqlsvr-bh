SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcInvDRpt]
	@store int,
	@settleno int,
	@date datetime
as
begin
	/* 取前一天的期末值作为新的一天的期初值 */
	select bwrh wrh, bgdgid gdgid, fq qty, ft total
	,finprc, frtlprc, fdxprc, fpayrate, finvprc, flstinprc,finvcost
    	into #init
        from rinvdrpt
        where adate = dateadd(day, -1, @date)
	and astore = @store

	select bwrh wrh, bgdgid gdgid, fq qty, ft total,finvcost
    	into #inv
        from rinvdrpt
        where adate = dateadd(day, -1, @date)
	and astore = @store

	/* 加上进货 */
    insert into #inv(wrh, gdgid, qty, total,finvcost)
    	select bwrh, bgdgid,
        	sum(dq1 + dq2 + dq3 - dq4),
            sum(dr1 + dr2 + dr3 - dr4),
            sum(dt1 + dt2 + dt3 - di4)
        from rindrpt
        where adate = @date
	and astore = @store
        group by bwrh, bgdgid

	/* 减去出货 */
    insert into #inv(wrh, gdgid, qty, total,finvcost)
    	select bwrh, bgdgid,
        	-sum(dq1 + dq2 + dq3 + dq4 - dq5 - dq6 - dq7),
            -sum(dr1 + dr2 + dr3 + dr4 - dr5 - dr6 - dr7),
            -sum(di1 + di2 + di3 + di4 - di5 - di6 - dt7)--配货退货的成本应该只是发生额
        from routdrpt
        where adate = @date
	and astore = @store
        group by bwrh, bgdgid

	/* 加上库存调整 */
    insert into #inv(wrh, gdgid, qty, total,finvcost)
    	select bwrh, bgdgid,
        	sum(dq1 + dq2 + dq4 - dq5 + dq6 - dq7),	--2002-08-15 2002071657763
            sum(dr1 + dr2 + dr3 + dr4 - dr5 + dr6 - dr7),
            sum(di1 + di2 + di3 + di4 - di5 + di6 - di7)
        from rinvchgdrpt
        where adate = @date
	and astore = @store
        group by bwrh, bgdgid

	/* 考虑生鲜加工 */
    insert into #inv(wrh, gdgid, qty, total,finvcost)
    	select bwrh, bgdgid,
        	sum(dq1), sum(dr1),sum(di1)
        from rprocdrpt
        where adate = @date
	and astore = @store
        group by bwrh, bgdgid

    /* 得到期末值 */
    select wrh, gdgid, sum(qty) qty, sum(total) total,sum(finvcost) finvcost
    	into #final
        from #inv
        group by wrh, gdgid

    select #final.wrh, #final.gdgid, isnull(#init.qty, 0) cq, isnull(#init.total, 0) ct,
    	#final.qty fq, #final.total ft
    	,isnull(#init.finprc, goods.inprc) finprc,
        isnull(#init.frtlprc, goods.rtlprc) frtlprc,
        isnull(#init.fdxprc, goods.dxprc) fdxprc,
        isnull(#init.fpayrate, goods.payrate) fpayrate,
        isnull(#init.finvprc, goods.invprc) finvprc,
        isnull(#init.flstinprc, goods.lstinprc) flstinprc,
        isnull(#final.finvcost,0) finvcost
    	into #all
        from #final, #init, goodsh goods
        where #final.wrh *= #init.wrh and #final.gdgid *= #init.gdgid
        and #final.gdgid = goods.gid

    -- 价格调整 --去掉价格调整
    declare @cls char(8), @gdgid int, @newprc money
    declare c_prc cursor for
    	select m.cls, d.gdgid, d.newprc
        from prcadj m, prcadjdtl d
        where m.cls = d.cls and m.num = d.num
        and m.fildate >= @date and m.fildate <= dateadd(day, -1, @date)
        order by m.fildate asc
        for read only
    open c_prc
    fetch next from c_prc into @cls, @gdgid, @newprc
    while @@fetch_status = 0
    begin
    	if exists (select 1 from #all where gdgid = @gdgid)
        begin
		/*	if @cls = '核算价' or @cls = '库存价'--因为反算，所以不需要修改了by azer 20050407
	        	update #all set finprc = @newprc where gdgid = @gdgid
            else */if @cls = '核算售价'
	        	update #all set frtlprc = @newprc where gdgid = @gdgid
            else if @cls = '代销价'
	        	update #all set fdxprc = @newprc where gdgid = @gdgid
            else if @cls = '联销率'
	        	update #all set fpayrate = @newprc where gdgid = @gdgid
        end
        fetch next from c_prc into @cls, @gdgid, @newprc
    end
    close c_prc
    deallocate c_prc
    
    -- 新价格调整 
    declare c_prc cursor for
    	select d.gdgid, isnull(d.newrtlprc,-1)
        from rtlprcadj m, rtlprcadjdtl d
        where  m.num = d.num
        and m.fildate >= @date and m.fildate <= dateadd(day, -1, @date)
        order by m.fildate asc
        for read only
    open c_prc
    fetch next from c_prc into @gdgid, @newprc
    while @@fetch_status = 0
    begin
    	if exists (select 1 from #all where gdgid = @gdgid)
        begin
	   if @newprc > 0
	      update #all set frtlprc = @newprc where gdgid = @gdgid
        end
        fetch next from c_prc into  @gdgid, @newprc
    end
    close c_prc
    deallocate c_prc    

    /* 写入rinvdrpt */
    delete from rinvdrpt
    	where astore = @store
        and asettleno = @settleno
        and adate = @date

    insert into rinvdrpt (astore, asettleno, adate, bgdgid, bwrh,
    	cq, ct, fq, ft,
        finprc, frtlprc, fdxprc, fpayrate, finvprc, flstinprc,FINVCOST) 
    select @store, @settleno, @date, gdgid, wrh,
    	cq, ct, fq, ft,
        FINVCOST/fq, frtlprc, fdxprc, fpayrate, FINVCOST/fq, flstinprc,FINVCOST
    from #all where fq<>0
    insert into rinvdrpt (astore, asettleno, adate, bgdgid, bwrh,
    	cq, ct, fq, ft,
        finprc, frtlprc, fdxprc, fpayrate, finvprc, flstinprc,FINVCOST) --对于库存数为0的商品，使用上一天的核算价
    select @store, @settleno, @date, gdgid, wrh,
    	cq, ct, fq, ft,
        finvprc, frtlprc, fdxprc, fpayrate, finvprc, flstinprc,FINVCOST
    from #all where fq=0
end
GO
