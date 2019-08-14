SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CheckOutDrpt]
    @date datetime
as
begin
	delete from testgd where adate = @date
	insert into testgd(adate,gdgid,bqty,bamt,biamt,rqty,ramt,riamt,rbqty,rbamt,rbiamt,inqty,inamt,iniamt,outqty,outamt,outiamt)
	select distinct adate,bgdgid,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 from invdrpt where adate = @date

	update testgd set bqty = bqty + b.qty,bamt = bamt + b.amount,biamt = biamt + b.iamt
	from (select gid,sum(b2.qty) qty,sum(b2.realamt) amount,sum(round(b2.qty*b2.inprc, 2)) iamt from buy1 b1,buy2 b2 where b1.posno = b2.posno and b1.flowno = b2.flowno and b1.fildate >= @date and b1.fildate < @date + 1 group by gid) b
	where testgd.gdgid = b.gid and adate = @date

	update testgd set rqty = rqty + r.qty,ramt = ramt + r.amount,riamt = riamt + r.iamt
	from (select gdgid,sum(rtldtl.qty) qty,sum(rtldtl.amount) amount,sum(round(rtldtl.qty*rtldtl.inprc, 2)) iamt from rtl,rtldtl where rtl.num=rtldtl.num and rtl.fildate >= @date and rtl.fildate < @date + 1 group by gdgid) r
	where testgd.gdgid = r.gdgid and adate = @date

	update testgd set rbqty = rbqty + rb.qty,rbamt = rbamt + rb.amount,rbiamt = rbiamt + rb.iamt
	from (select gdgid,sum(rtlbckdtl.qty) qty,sum(rtlbckdtl.amount) amount,sum(round(rtlbckdtl.qty*rtlbckdtl.inprc, 2)) iamt from rtlbck,rtlbckdtl where rtlbck.num=rtlbckdtl.num and fildate >= @date and fildate < @date + 1 group by gdgid) rb
	where testgd.gdgid = rb.gdgid and adate = @date

	update testgd set inqty = inqty + i.qty,inamt = inamt + i.amount,iniamt = iniamt + i.iamt
	from (select bgdgid,sum(dq2) qty,sum(dt2) amount,sum(di2) iamt from indrpt where adate = @date group by bgdgid) i
	where testgd.gdgid = i.bgdgid and adate = @date

	update testgd set outqty = outqty + o.qty,outamt = outamt + o.amount,outiamt = outiamt + o.iamt
	from (select bgdgid,sum(dq1-dq5) qty,sum(dt1-dt5) amount,sum(di1-di5) iamt from outdrpt where adate = @date group by bgdgid) o
	where testgd.gdgid = o.bgdgid and adate = @date
end
GO
