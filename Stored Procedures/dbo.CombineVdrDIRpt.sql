SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*
  将日期初值报表中@store, @settleno, 的供应商@oldvdrgid, 改成@vdrgid
*/
create procedure [dbo].[CombineVdrDIRpt]
	@store int,       --店号
	@settleno int,    --期号
	@oldvdrgid int,   --原供应商
	@vdrgid int       --新供应商
as
begin
	if @oldvdrgid = @vdrgid
        	return(0)

	declare
		@ADATE datetime, @gdgid int, @wrh int,
		@CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money, @CQ5 money, @CQ6 money,
		@CT1 money, @CT2 money, @CT3 money, @CT4 money, @CT5 money, @CT6 money, @CT7 money,
		@CT8 money, @CI2 money

	/* VDRDRPTI */
	declare c_vdrdrpti cursor for
		select ADATE, BGDGID, BWRH,
			CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, CI2
		from VDRDRPTI
		where ASTORE = @store and ASETTLENO = @settleno
			and BVDRGID = @oldvdrgid 
	open c_vdrdrpti
	fetch next from c_vdrdrpti into
		@ADATE, @gdgid, @wrh,
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
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
		end
		else
		begin
			update VDRDRPTI set BVDRGID = @vdrgid
			where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
		end
		fetch next from c_vdrdrpti into
			@ADATE, @gdgid, @wrh,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8, @CI2
	end
	close c_vdrdrpti
	deallocate c_vdrdrpti			
end

GO
