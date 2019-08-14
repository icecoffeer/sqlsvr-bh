SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将日期初值报表中@store, @settleno, 的商品@oldgdgid, 改成@gdgid
*/
create procedure [dbo].[CombineGoodsDIRpt]
	@store int,
	@settleno int,
	@oldgdgid int,  --被合并商品
	@gdgid int      --并入商品
as
begin
	if @oldgdgid = @gdgid
        	return(0)

	declare
		@ADATE datetime, @vdrgid int, @cstgid int, @wrh int,
		@CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money, @CQ5 money, @CQ6 money,
		@CT1 money, @CT2 money, @CT3 money, @CT4 money, @CT5 money, @CT6 money, @CT7 money,
		@CT8 money, @CI2 money


	/* VDRDRPTI */
	declare c_rpt cursor for
		select ADATE, BVDRGID, BWRH,
			CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8,
			CI2
		from VDRDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid 
	open c_rpt
	fetch next from c_rpt into
		@ADATE, @vdrgid, @wrh,
		@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
		@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
		@CI2
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
			CT8 = CT8 + @CT8,
			CI2 = CI2 + @CI2
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @gdgid and BWRH = @wrh and BVDRGID = @vdrgid
			delete from VDRDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @oldgdgid and BWRH = @wrh and BVDRGID = @vdrgid
		end
		else
		begin
			update VDRDRPTI set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BGDGID = @oldgdgid and BWRH = @wrh and BVDRGID = @vdrgid
		end
		fetch next from c_rpt into
			@ADATE, @vdrgid, @wrh,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
			@CI2
	end
	close c_rpt
	deallocate c_rpt	

		
	/* CSTDRPTI */
	declare c_rpt cursor for
		select ADATE, BCSTGID, BWRH, CQ1, CQ2, CQ3, CT1, CT2, CT3, CT4
		from CSTDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid
	open c_rpt
	fetch next from c_rpt into 
		@ADATE, @cstgid, @wrh, @CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4
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
			and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
		end
		else
		begin
			update CSTDRPTI set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE 
			and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
		end
		fetch next from c_rpt into 
			@ADATE, @cstgid, @wrh, @CQ1, @CQ2, @CQ3, 
			@CT1, @CT2, @CT3, @CT4
	end
	close c_rpt
	deallocate c_rpt
end
GO
