SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将日期初值报表中@store, @settleno, 的商品@oldwrh, 改成@wrh
*/
create procedure [dbo].[CombineWrhDIRpt]
	@store int,
	@settleno int,
	@oldwrh int,  --被合并仓位
	@wrh int      --并入仓位
as
begin
	if @oldwrh = @wrh
        	return(0)

	declare
		@ADATE datetime, @vdrgid int, @cstgid int, @gdgid int,
		@CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money, @CQ5 money, @CQ6 money,
		@CT1 money, @CT2 money, @CT3 money, @CT4 money, @CT5 money, @CT6 money, @CT7 money,
		@CT8 money, @CI2 money

	
	/* VDRDRPTI */
	declare c_rpt cursor for
		select ADATE, BVDRGID, BGDGID,
			CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, CI2
		from VDRDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh 
	open c_rpt
	fetch next from c_rpt into
		@ADATE, @vdrgid, @gdgid,
		@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
		@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8, @CI2
	while @@fetch_status = 0
	begin
		if exists (select * from VDRDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @gdgid and BWRH = @wrh and BVDRGID = @vdrgid)
		begin
			update VDRDRPTI set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
			CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7,
			CT8 = CT8 + @CT8, CI2 = CI2 + @CI2
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @gdgid and BWRH = @wrh and BVDRGID = @vdrgid
			delete from VDRDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @gdgid and BWRH = @oldwrh and BVDRGID = @vdrgid
		end
		else
		begin
			update VDRDRPTI set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @gdgid and BWRH = @oldwrh and BVDRGID = @vdrgid
		end
		fetch next from c_rpt into
			@ADATE, @vdrgid, @gdgid,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8, @CI2
	end
	close c_rpt
	deallocate c_rpt	

		
	/* CSTDRPTI */
	declare c_rpt cursor for
		select ADATE, BCSTGID, BGDGID, CQ1, CQ2, CQ3, CT1, CT2, CT3, CT4
		from CSTDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh 
	open c_rpt
	fetch next from c_rpt into 
		@ADATE, @cstgid, @gdgid, @CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4
	while @@fetch_status = 0
	begin
		if exists ( select * from CSTDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE 
			and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
		begin
			update CSTDRPTI set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE 
			and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
			delete from CSTDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE 
			and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
		end
		else
		begin
			update CSTDRPTI set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE 
			and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
		end
		fetch next from c_rpt into 
			@ADATE, @cstgid, @gdgid, @CQ1, @CQ2, @CQ3, 
			@CT1, @CT2, @CT3, @CT4
	end
	close c_rpt
	deallocate c_rpt
end
GO
