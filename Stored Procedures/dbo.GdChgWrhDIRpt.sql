SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将INXRPT中@store, @settleno, @vdrgid, @gdgid的WRH从@oldwrh改成@wrh
*/
create procedure [dbo].[GdChgWrhDIRpt]
	@store int,
	@settleno int,
	@gdgid int,
	@oldwrh int,
	@wrh int
as
begin
	if @oldwrh = @wrh
        	return(0)

	declare
		@ADATE datetime, @vdrgid int, @cstgid int,
		@CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money, 
		@CQ5 money, @CQ6 money, 
		@CT1 money, @CT2 money, @CT3 money, @CT4 money,
		@CT5 money, @CT6 money, @CT7 money, @CT8 money, 
		@CI1 money, @CI2 money, @CI3 money, @CI4 money,
		@CR1 money, @CR2 money, @CR3 money, @CR4 money,
		@DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money,
		@DT1 money, @DT2 money, @DT3 money, @DT4 money,
		@DI1 money, @DI2 money, @DI3 money, @DI4 money,
		@DR1 money, @DR2 money, @DR3 money, @DR4 money

	/* VDRDRPTI */
	declare c_vdrdrpti cursor for
		select ADATE, BVDRGID,
			CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, CI2
		from VDRDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh and BGDGID = @gdgid 
	open c_vdrdrpti
	fetch next from c_vdrdrpti into
		@ADATE, @vdrgid,
		@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
		@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8, @CI2
	while @@fetch_status = 0
	begin
		if exists (select * from VDRDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid)
		begin
			update VDRDRPTI set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
			CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7,
			CT8 = CT8 + @CT8, CI2 = CI2 + @CI2
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
			delete from VDRDRPTI
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
		end
		else
		begin
			update VDRDRPTI set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
		end
		fetch next from c_vdrdrpti into
			@ADATE, @vdrgid,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8, @CI2
	end
	close c_vdrdrpti
	deallocate c_vdrdrpti

	/* CSTDRPTI */
	declare c cursor for
		select ADATE, BCSTGID, CQ1, CQ2, CQ3, CT1, CT2, CT3, CT4
		from CSTDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BWRH = @oldwrh
	open c
	fetch next from c into 
		@ADATE, @cstgid, @CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4
	while @@fetch_status = 0
	begin
		if exists ( select * from CSTDRPTI
			where ASTORE = @store and ASETTLENO = @settleno 
				and ADATE = @ADATE and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @wrh)
		begin
			update CSTDRPTI set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4
			where ASTORE = @store and ASETTLENO = @settleno 
				and ADATE = @ADATE and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @wrh
			delete from CSTDRPTI
			where ASTORE = @store and ASETTLENO = @settleno 
				and ADATE = @ADATE and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		else
		begin
			update CSTDRPTI set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno 
				and ADATE = @ADATE and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		fetch next from c into
			@ADATE, @cstgid, @CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4
	end
	close c
	deallocate c	
end
GO
