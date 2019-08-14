SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[FifocostInit](
    @settleno int,
    @date datetime,
    @intrecal smallint = 0
) as
begin
	declare @store int
	select @store = usergid from system

	select gdgid, costqty lastcostqty, costtotal lastcosttotal
    	into #init
        from fifocostcheck (nolock)
        where adate = dateadd(day, -1, @date)
    if @@error <> 0 return 1

    create table #inv(gdgid int, costqty money, inprc money)
    if @intrecal = 0 begin
	insert into #inv(gdgid, costqty, inprc)
        select goodsh.gid gdgid, sum(inv.qty) costqty, --max(isnull(lstinprc, 0)) inprc
		max(case when isnull(goodsh.lstinprc,0) = 0 then goodsh.inprc else goodsh.lstinprc end) inprc
	from inv(nolock), goodsh goodsh(nolock)
	where inv.gdgid = goodsh.gid
	and inv.store = @store
	and goodsh.sale = 1
	group by goodsh.gid
     end else begin
	insert into #inv(gdgid, costqty, inprc)
	select bgdgid gdgid, sum(fq) costqty, --max(lstinprc) inprc
		max(case when flstinprc = 0 then finprc else flstinprc end) inprc
	from invdrpt(nolock), goodsh goodsh(nolock)
	where invdrpt.bgdgid = goodsh.gid
	and adate = @date
	and asettleno = @settleno
	and astore = @store
	and goodsh.sale = 1
	group by bgdgid
     end
    if @@error <> 0 return 1

	select goodsh.gid gdgid, sum(dq1) zjqty, sum(dt1) zjtotal, 
		sum(dq4) zjtqty, sum(dt4) zjttotal
	into #in
	from indrpt (nolock), goodsh goodsh(nolock)
	where adate = @date
	and astore = @store
	and indrpt.bgdgid = goodsh.gid
	group by goodsh.gid
    if @@error <> 0 return 1

	select bgdgid gdgid, sum(dq1 + dq2 - dq5 - dq6) outqty, sum(dt1 + dt2 - dt5 - dt6) outtotal,
	sum(di1 + di2 - di5 - di6) outcost
	into #out
	from outdrpt(nolock)
	where adate = @date
	and astore = @store
	group by bgdgid
    if @@error <> 0 return 1

	select bgdgid gdgid, sum(di3) indj, sum(dq1 + dq2) invadjqty, sum(di1 + di2) invadjtotal
	into #invchg
	from invchgdrpt(nolock)
	where invchgdrpt.adate = @date
	and invchgdrpt.astore = @store
	and ( dq1 <> 0 or dq2 <> 0 or di3 <> 0)
	group by bgdgid
    if @@error <> 0 return 1

  insert into fifocostcheck(asettleno, adate, gdgid, lastcostqty, lastcosttotal,
	costqty, costtotal, zjqty, zjtotal, zjtqty, zjttotal, outqty, outtotal, indj,
	invadjqty, invadjtotal, outcost, inprc
  )
  select @settleno asettleno, @date adate, #inv.gdgid bgdgid,
	isnull(lastcostqty,0),	isnull(lastcosttotal, 0), isnull(costqty, 0),
	case when isnull(costqty, 0) < 0 or goodsh.sale > 1 then round(isnull(costqty * #inv.inprc, 0), 2) else 0 end,
	isnull(zjqty, 0),	isnull(zjtotal, 0),
	isnull(zjtqty, 0),	isnull(zjttotal, 0),
	isnull(outqty, 0),	isnull(outtotal, 0),	isnull(indj, 0),
	isnull(invadjqty, 0),	isnull(invadjtotal, 0),
	case when goodsh.sale > 1 then isnull(outcost, 0) else
		case when isnull(costqty,0) <= 0 then 
		isnull(lastcosttotal, 0) + isnull(zjtotal, 0) - isnull(zjttotal, 0) 
		+ isnull(invadjtotal, 0) - round(isnull(costqty * #inv.inprc, 0), 2) else 0 end end, 
	#inv.inprc
    from #inv, #init, #in, #out, #invchg, goodsh
    where #inv.gdgid = goodsh.gid
    	and #inv.gdgid *= #init.gdgid
	and #inv.gdgid *= #in.gdgid
	and #inv.gdgid *= #out.gdgid
	and #inv.gdgid *= #invchg.gdgid
    if @@error <> 0 return 1
    return 0
end
GO
