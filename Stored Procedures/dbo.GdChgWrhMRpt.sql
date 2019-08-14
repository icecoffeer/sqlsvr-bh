SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将INXRPT中@store, @settleno, @vdrgid, @gdgid的WRH从@oldwrh改成@wrh
*/
create procedure [dbo].[GdChgWrhMRpt]
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
		@CQ money, @CT money, @FQ money, @FT money,
		@CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money,
		@CQ5 money, @CQ6 money, @CQ7 money, 
		@CT1 money, @CT2 money, @CT3 money, @CT4 money,
		@CT5 money, @CT6 money, @CT7 money, @CT8 money, 
		@CT91 money, @CT92 money,
		@CI1 money, @CI2 money, @CI3 money, @CI4 money,
		@CI5 money, @CI6 money, @CI7 money,
		@CR1 money, @CR2 money, @CR3 money, @CR4 money,
		@CR5 money, @CR6 money, @CR7 money,
		@DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money,
		@DQ5 money, @DQ6 money, @DQ7 money,
		@DT1 money, @DT2 money, @DT3 money, @DT4 money,
		@DT5 money, @DT6 money, @DT7 money, @DT91 money, @DT92 money,
		@DI1 money, @DI2 money, @DI3 money, @DI4 money,
		@DI5 money, @DI6 money, @DI7 money,
		@DR1 money, @DR2 money, @DR3 money, @DR4 money,
		@DR5 money, @DR6 money, @DR7 money
		
	/* INMRPT */
	declare c_inmrpt cursor for
		select BVDRGID,
			CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
			CI1, CI2, CI3, CI4, CR1, CR2, CR3, CR4,
			DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
			DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
		from INMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh and BGDGID = @gdgid
	open c_inmrpt
	fetch next from c_inmrpt into
		@vdrgid,
		@CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
		@CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
		@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
		@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
	while @@fetch_status = 0
	begin
		if exists (
			select * from INMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
			)
		begin
			update INMRPT set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			CI1 = CI1 + @CI1, CI2 = CI2 + @CI2, CI3 = CI3 + @CI3, CI4 = CI4 + @CI4,
			CR1 = CR1 + @CR1, CR2 = CR2 + @CR2, CR3 = CR3 + @CR3, CR4 = CR4 + @CR4,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
			DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4,
			DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
			delete from INMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
		end
		else
		begin
			update INMRPT set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
		end
		fetch next from c_inmrpt into
			@vdrgid,
			@CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
			@CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
			@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
			@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
	end
	close c_inmrpt
	deallocate c_inmrpt	

	/* INVMRPT */
	declare c_invmrpt cursor for
		select CQ, CT, FQ, FT
		from INVMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BWRH = @oldwrh
	open c_invmrpt
	fetch next from c_invmrpt into @CQ, @CT, @FQ, @FT
	while @@fetch_status = 0
	begin
		if exists ( select * from INVMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @wrh)
		begin
			update INVMRPT set
			CQ = CQ + @CQ, CT = CT + @CT, FQ = FQ + @FQ, FT = FT + @FT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @wrh
			delete from INVMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		else
		begin
			update INVMRPT set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		fetch next from c_invmrpt into @CQ, @CT, @FQ, @FT
	end
	close c_invmrpt
	deallocate c_invmrpt

	/* INVCHGMRPT */
	declare c cursor for
		select
			CQ1 , CQ2 , CQ4 , CQ5 ,
			CI1 , CI2 , CI3 , CI4 , CI5 , 
			CR1 , CR2 , CR3 , CR4 , CR5,
			DQ1 , DQ2 , DQ4 , DQ5 , 
			DI1 , DI2 , DI3 , DI4 , DI5 , 
			DR1 , DR2 , DR3 , DR4 , DR5
		from INVCHGMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BWRH = @oldwrh
	open c
	fetch next from c into
		@CQ1 , @CQ2 , @CQ4 , @CQ5 , 
		@CI1 , @CI2 , @CI3 , @CI4 , @CI5 , 
		@CR1 , @CR2 , @CR3 , @CR4 , @CR5,
		@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
		@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , 
		@DR1 , @DR2 , @DR3 , @DR4 , @DR5
	while @@fetch_status = 0
	begin
		if exists ( select * from INVCHGMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @wrh)
		begin
			update INVCHGMRPT set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ4 = CQ4 + @CQ4, CQ5 = CQ5 + @CQ5,
			CI1 = CI1 + @CI1, CI2 = CI2 + @CI2, CI3 = CI3 + @CI3, CI4 = CI4 + @CI4, CI5 = CI5 + @CI5,
			CR1 = CR1 + @CR1, CR2 = CR2 + @CR2, CR3 = CR3 + @CR3, CR4 = CR4 + @CR4, CR5 = CR5 + @CR5,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5,
			DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5,
			DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @wrh
			delete from INVCHGMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		else
		begin
			update INVCHGMRPT set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		fetch next from c into
			@CQ1 , @CQ2 , @CQ4 , @CQ5 , 
			@CI1 , @CI2 , @CI3 , @CI4 , @CI5 , @CR1 , @CR2 , @CR3 , @CR4 , @CR5,
			@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
			@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , @DR1 , @DR2 , @DR3 , @DR4 , @DR5
	end
	close c
	deallocate c

	/* OUTMRPT */
	declare c cursor for
		select
			BCSTGID,
			/*CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT91, CT92,
			CI1, CI2, CI3, CI4, CI5, CI6, CI7,
			CR1, CR2, CR3, CR4, CR5, CR6, CR7,*/
			DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
			DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
			DI1, DI2, DI3, DI4, DI5, DI6, DI7,
			DR1, DR2, DR3, DR4, DR5, DR6, DR7
		from OUTMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BWRH = @oldwrh
	open c
	fetch next from c into
		@cstgid,
		/*@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6, @CQ7,
		@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT91, @CT92,
		@CI1, @CI2, @CI3, @CI4, @CI5, @CI6, @CI7,
		@CR1, @CR2, @CR3, @CR4, @CR5, @CR6, @CR7,*/
		@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
		@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
		@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
		@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
	while @@fetch_status = 0
	begin
		if exists ( select * from OUTMRPT
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @wrh)
		begin
			update OUTMRPT set
			/*CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4, CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6, CQ7 = CQ7 + @CQ7,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4, CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7, CT91 = CT91 + @CT91, CT92 = CT92 + @CT92,
			CI1 = CI1 + @CI1, CI2 = CI2 + @CI2, CI3 = CI3 + @CI3, CI4 = CI4 + @CI4, CI5 = CI5 + @CI5, CI6 = CI6 + @CI6, CI7 = CI7 + @CI7,
			CR1 = CR1 + @CR1, CR2 = CR2 + @CR2, CR3 = CR3 + @CR3, CR4 = CR4 + @CR4, CR5 = CR5 + @CR5, CR6 = CR6 + @CR6, CR7 = CR7 + @CR7,*/
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6, DQ7 = DQ7 + @DQ7,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4, DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7, DT91 = DT91 + @DT91, DT92 = DT92 + @DT92,
			DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5, DI6 = DI6 + @DI6, DI7 = DI7 + @DI7,
			DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5, DR6 = DR6 + @DR6, DR7 = DR7 + @DR7
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @wrh
			delete from OUTMRPT
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		else
		begin
			update OUTMRPT set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		fetch next from c into
			@cstgid,
			/*@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6, @CQ7,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT91, @CT92,
			@CI1, @CI2, @CI3, @CI4, @CI5, @CI6, @CI7,
			@CR1, @CR2, @CR3, @CR4, @CR5, @CR6, @CR7,*/
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
			@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
			@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
	end
	close c
	deallocate c

	/* CSTMRPT */
	declare c cursor for
		select BCSTGID, CQ1, CQ2, CQ3, 
			CT1, CT2, CT3, CT4,
			DQ1, DQ2, DQ3, DT1, DT2, DT3
		from CSTMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BWRH = @oldwrh
	open c
	fetch next from c into @cstgid,
	    @CQ1, @CQ2, @CQ3, 
	    @CT1, @CT2, @CT3, @CT4,	
	    @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
	while @@fetch_status = 0
	begin
		if exists ( select * from CSTMRPT
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @wrh)
		begin
			update CSTMRPT set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @wrh
			delete from CSTMRPT
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		else
		begin
			update CSTMRPT set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno and BCSTGID = @cstgid
				and BGDGID = @gdgid and BWRH = @oldwrh
		end
		fetch next from c into @cstgid,
			@CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4,
			@DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
	end
	close c
	deallocate c

	/* VDRMRPT */
	declare c_vdrmrpt cursor for
		select
			BVDRGID,
			CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8,
			DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
			DT1, DT2, DT3, DT4, DT5, DT6, DT7,
                        CI2, DI2
		from VDRMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh and BGDGID = @gdgid 
	open c_vdrmrpt
	fetch next from c_vdrmrpt into
		@vdrgid,
		@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
		@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
		@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
		@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7,
                @CI2, @DI2
	while @@fetch_status = 0
	begin
		if exists (select * from VDRMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid)
		begin
			update VDRMRPT set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
			CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7,
			CT8 = CT8 + @CT8,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
			DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
			DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
                        CI2 = CI2 + @CI2, DI2 = DI2 + @DI2
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
			delete from VDRMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
		end
		else
		begin
			update VDRMRPT set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
		end

		update VDRMRPTLOG set BWRH = @wrh
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
				
		fetch next from c_vdrmrpt into
			@vdrgid,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7,
                        @CI2, @DI2
	end
	close c_vdrmrpt
	deallocate c_vdrmrpt
end
GO
