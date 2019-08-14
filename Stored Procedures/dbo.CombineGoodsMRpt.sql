SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将月报表中@store, @settleno, 的商品@oldgdgid, 改成@gdgid
*/
create procedure [dbo].[CombineGoodsMRpt]
	@store int,
	@settleno int,
	@oldgdgid int,  --被合并商品
	@gdgid int      --并入商品
as
begin
	if @oldgdgid = @gdgid
        	return(0)
                
	declare
		@vdrgid int, @cstgid int, @wrh int,
		@CQ money, @CT money, @FQ money, @FT money,
		@CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money, @CQ5 money,
		@CQ6 money, @CQ7 money,
		@CT1 money, @CT2 money, @CT3 money, @CT4 money, @CT5 money,
		@CT6 money, @CT7 money, @CT8 money, @CT91 money, @CT92 money,
		@CI1 money, @CI2 money, @CI3 money, @CI4 money, @CI5 money,
		@CI6 money, @CI7 money,
		@CR1 money, @CR2 money, @CR3 money, @CR4 money, @CR5 money,
		@CR6 money, @CR7 money,
		@DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money, @DQ5 money,
		@DQ6 money, @DQ7 money,
		@DT1 money, @DT2 money, @DT3 money, @DT4 money, @DT5 money,
		@DT6 money, @DT7 money, @DT91 money, @DT92 money,
		@DI1 money, @DI2 money, @DI3 money, @DI4 money, @DI5 money,
		@DI6 money, @DI7 money, 
		@DR1 money, @DR2 money, @DR3 money, @DR4 money, @DR5 money,
		@DR6 money, @DR7 money  
				

	/* INMRPT */
	declare c_rpt cursor for
		select
			BVDRGID, BWRH,
			CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
			CI1, CI2, CI3, CI4, CR1, CR2, CR3, CR4,
			DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
			DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
		from INMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid
	open c_rpt
	fetch next from c_rpt into
		@vdrgid, @wrh,
		@CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
		@CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
		@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
		@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
	while @@fetch_status = 0
	begin
		if exists (
			select * from INMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh)
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
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh 

			delete from INMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh 
		end
		else
		begin
			update INMRPT set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh 
		end
		fetch next from c_rpt into
			@vdrgid, @wrh,
			@CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
			@CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
			@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
			@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
	end
	close c_rpt
	deallocate c_rpt

	/* INVMRPT */
	declare c_rpt cursor for
		select BWRH, CQ, CT, FQ, FT
		from INVMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid 
	open c_rpt
	fetch next from c_rpt into @wrh, @CQ, @CT, @FQ, @FT
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
				and BGDGID = @oldgdgid and BWRH = @wrh
		end
		else
		begin
			update INVMRPT set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @oldgdgid and BWRH = @wrh
		end
		fetch next from c_rpt into @wrh, @CQ, @CT, @FQ, @FT
	end
	close c_rpt
	deallocate c_rpt
	
	/* INVCHGMRPT */
	declare c_rpt cursor for
		select
			BWRH,
			CQ1 , CQ2 , CQ4 , CQ5 , 
			CI1 , CI2 , CI3 , CI4 , CI5 , 
			CR1 , CR2 , CR3 , CR4 , CR5,
			DQ1 , DQ2 , DQ4 , DQ5 , 
			DI1 , DI2 , DI3 , DI4 , DI5 , 
			DR1 , DR2 , DR3 , DR4 , DR5
		from INVCHGMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid 
	open c_rpt
	fetch next from c_rpt into
		@wrh,
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
				and BGDGID = @oldgdgid and BWRH = @wrh
		end
		else
		begin
			update INVCHGMRPT set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @oldgdgid and BWRH = @wrh
		end
		fetch next from c_rpt into
			@wrh,
			@CQ1 , @CQ2 , @CQ4 , @CQ5 , 
			@CI1 , @CI2 , @CI3 , @CI4 , @CI5 , @CR1 , @CR2 , @CR3 , @CR4 , @CR5,
			@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
			@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , @DR1 , @DR2 , @DR3 , @DR4 , @DR5
	end
	close c_rpt
	deallocate c_rpt

	/* OUTMRPT */
	declare c_rpt cursor for
		select
			BCSTGID, BWRH,
			--CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7,
			--CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT91, CT92,
			--CI1, CI2, CI3, CI4, CI5, CI6, CI7,
			--CR1, CR2, CR3, CR4, CR5, CR6, CR7,
			DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
			DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
			DI1, DI2, DI3, DI4, DI5, DI6, DI7,
			DR1, DR2, DR3, DR4, DR5, DR6, DR7
		from OUTMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid 
	open c_rpt
	fetch next from c_rpt into
		@cstgid, @wrh,
		--@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6, @CQ7,
		--@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT91, @CT92,
		--@CI1, @CI2, @CI3, @CI4, @CI5, @CI6, @CI7,
		--@CR1, @CR2, @CR3, @CR4, @CR5, @CR6, @CR7,
		@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
		@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
		@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
		@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
	while @@fetch_status = 0
	begin
		if exists ( select * from OUTMRPT
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
		begin
			update OUTMRPT set
			--CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4, CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6, CQ7 = CQ7 + @CQ7,
			--CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4, CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7, 
			--CT91 = CT91 + @CT91, CT92 = CT92 + @CT92,
			--CI1 = CI1 + @CI1, CI2 = CI2 + @CI2, CI3 = CI3 + @CI3, CI4 = CI4 + @CI4, CI5 = CI5 + @CI5, CI6 = CI6 + @CI6, CI7 = CI7 + @CI7,
			--CR1 = CR1 + @CR1, CR2 = CR2 + @CR2, CR3 = CR3 + @CR3, CR4 = CR4 + @CR4, CR5 = CR5 + @CR5, CR6 = CR6 + @CR6, CR7 = CR7 + @CR7,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6, DQ7 = DQ7 + @DQ7,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4, DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
			DT91 = DT91 + @DT91, DT92 = DT92 + @DT92,
			DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5, DI6 = DI6 + @DI6, DI7 = DI7 + @DI7,
			DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5, DR6 = DR6 + @DR6, DR7 = DR7 + @DR7
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
			delete from OUTMRPT
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
		end
		else
		begin
			update OUTMRPT set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
		end
		fetch next from c_rpt into
			@cstgid, @wrh,
			--@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6, @CQ7,
			--@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT91, @CT92,
			--@CI1, @CI2, @CI3, @CI4, @CI5, @CI6, @CI7,
			--@CR1, @CR2, @CR3, @CR4, @CR5, @CR6, @CR7,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
			@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
			@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
	end
	close c_rpt
	deallocate c_rpt

	/* VDRMRPT */
	declare c_rpt cursor for
		select
			BVDRGID, BWRH,
			CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
			CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8,
			DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
			DT1, DT2, DT3, DT4, DT5, DT6, DT7,
			CI2, DI2
		from VDRMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid 
	open c_rpt
	fetch next from c_rpt into
		@vdrgid, @wrh,
		@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
		@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
		@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
		@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7,
		@CI2, @DI2
	while @@fetch_status = 0
	begin
		if exists (select * from VDRMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh)
		begin
			update VDRMRPT set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
			CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7, CT8 = CT8 + @CT8,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
			DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
			DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
			CI2 = CI2 + @CI2, DI2 = DI2 + @DI2
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh 
			delete from VDRMRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh 
		end
		else
		begin
			update VDRMRPT set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh 
		end
		fetch next from c_rpt into
			@vdrgid, @wrh,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7,
			@CI2, @DI2
	end
	close c_rpt
	deallocate c_rpt

	/* CSTMRPT */
	declare c_rpt cursor for
		select BCSTGID, BWRH, CQ1, CQ2, CQ3, 
			CT1, CT2, CT3, CT4,
			DQ1, DQ2, DQ3, DT1, DT2, DT3
		from CSTMRPT
		where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @oldgdgid 
	open c_rpt
	fetch next from c_rpt into 
		@cstgid, @wrh,
		@CQ1, @CQ2, @CQ3, 
		@CT1, @CT2, @CT3, @CT4,	
		@DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
	while @@fetch_status = 0
	begin
		if exists ( select * from CSTMRPT
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
		begin
			update CSTMRPT set
			CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3,
			CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
			DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3,
			DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
			delete from CSTMRPT
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
		end
		else
		begin
			update CSTMRPT set BGDGID = @gdgid
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
		end
		fetch next from c_rpt into 
			@cstgid, @wrh,
			@CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4,
			@DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
	end
	close c_rpt
	deallocate c_rpt	
end
GO
