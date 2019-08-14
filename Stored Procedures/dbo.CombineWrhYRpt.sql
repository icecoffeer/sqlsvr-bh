SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将年报表中@store, @settleno, 的商品@oldwrh, 改成@wrh
*/
create procedure [dbo].[CombineWrhYRpt]
	@store int,
	@settleno int,
	@oldwrh int,  --被合并仓位
	@wrh int,     --并入仓位
	@mode int
	--@mode 0 修改全部数据 修改年报表的期初值和发生值
	--@mode 1 修改本期数据 重算年报表的发生值
as
begin
	if @oldwrh = @wrh
        	return(0)
                
	declare
		@vdrgid int, @cstgid int, @gdgid int,
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

	
	/* INYRPT */
	if @mode = 0
	begin
		declare c_rpt cursor for
			select
				BVDRGID, BGDGID,
				CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
				CI1, CI2, CI3, CI4, CR1, CR2, CR3, CR4,
				DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
				DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
			from INYRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh
		open c_rpt
		fetch next from c_rpt into
			@vdrgid, @gdgid,
			@CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
			@CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
			@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
			@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
		while @@fetch_status = 0
		begin
			if exists (
				select * from INYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh 
				)
			begin
				update INYRPT set
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
				delete from INYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh 
			end
			else
			begin
				update INYRPT set BWRH = @wrh
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh 
			end
			fetch next from c_rpt into
				@vdrgid, @gdgid,
				@CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
				@CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
				@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
				@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
		end
		close c_rpt
		deallocate c_rpt
	end
	else  --@mode = 1
	begin
		/*根据月报表重算被合并仓位的发生值*/
		update INYRPT set 
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DQ4 = 0, 
			DT1 = 0, DT2 = 0, DT3 = 0, DT4 = 0,
			DI1 = 0, DI2 = 0, DI3 = 0, DI4 = 0, 
			DR1 = 0, DR2 = 0, DR3 = 0, DR4 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh
			
		declare c_rpt cursor for
			select BVDRGID, BGDGID, 
				SUM(DQ1), SUM(DQ2), SUM(DQ3), SUM(DQ4), 
				SUM(DT1), SUM(DT2), SUM(DT3), SUM(DT4),
				SUM(DI1), SUM(DI2), SUM(DI3), SUM(DI4), 
				SUM(DR1), SUM(DR2), SUM(DR3), SUM(DR4)
			from INMRPT
			where ASTORE = @store 
			and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
			and BWRH = @oldwrh 
			group by BVDRGID, BGDGID 
		open c_rpt
		fetch next from c_rpt into @vdrgid, @gdgid,
			@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
			@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
		while @@fetch_status = 0
		begin
			update INYRPT set
			DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3, DQ4 = @DQ4,
			DT1 = @DT1, DT2 = @DT2, DT3 = @DT3, DT4 = @DT4,
			DI1 = @DI1, DI2 = @DI2, DI3 = @DI3, DI4 = @DI4,
			DR1 = @DR1, DR2 = @DR2, DR3 = @DR3, DR4 = @DR4
			where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh
			fetch next from c_rpt into 
				@vdrgid, @gdgid,
				@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
				@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
		end
		close c_rpt
		deallocate c_rpt

		/*根据月报表重算并入仓位的发生值*/
		update INYRPT set 
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DQ4 = 0, 
			DT1 = 0, DT2 = 0, DT3 = 0, DT4 = 0,
			DI1 = 0, DI2 = 0, DI3 = 0, DI4 = 0, 
			DR1 = 0, DR2 = 0, DR3 = 0, DR4 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @wrh
			
		declare c_rpt cursor  for
			select BVDRGID, BGDGID, 
				SUM(DQ1), SUM(DQ2), SUM(DQ3), SUM(DQ4), 
				SUM(DT1), SUM(DT2), SUM(DT3), SUM(DT4),
				SUM(DI1), SUM(DI2), SUM(DI3), SUM(DI4), 
				SUM(DR1), SUM(DR2), SUM(DR3), SUM(DR4)
			from INMRPT
			where ASTORE = @store 
			and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
			and BWRH = @wrh 
			group by BVDRGID, BGDGID 
		open c_rpt
		fetch next from c_rpt into @vdrgid, @gdgid,
			@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
			@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
		while @@fetch_status = 0
		begin
			if exists(select * from INYRPT
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh)
			begin
				update INYRPT set
				DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3, DQ4 = @DQ4,
				DT1 = @DT1, DT2 = @DT2, DT3 = @DT3, DT4 = @DT4,
				DI1 = @DI1, DI2 = @DI2, DI3 = @DI3, DI4 = @DI4,
				DR1 = @DR1, DR2 = @DR2, DR3 = @DR3, DR4 = @DR4
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh
			end
			else
			begin
				insert into INYRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
					DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
					DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4)
				values(@store, @settleno, @gdgid, @vdrgid, @wrh,
					@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
					@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4)
			end
			fetch next from c_rpt into 
				@vdrgid, @gdgid,
				@DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
				@DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
		end
		close c_rpt
		deallocate c_rpt
	end

	/* INVYRPT */
	if @mode = 0
	begin
		declare c_rpt cursor for
			select BGDGID, CQ, CT, FQ, FT
			from INVYRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh 
		open c_rpt
		fetch next from c_rpt into @gdgid, @CQ, @CT, @FQ, @FT
		while @@fetch_status = 0
		begin
			if exists ( select * from INVYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @wrh)
			begin
				update INVYRPT set
				CQ = CQ + @CQ, CT = CT + @CT, FQ = FQ + @FQ, FT = FT + @FT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @wrh
				delete from INVYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @oldwrh
			end
			else
			begin
				update INVYRPT set BWRH = @wrh
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @oldwrh
			end
			fetch next from c_rpt into @gdgid, @CQ, @CT, @FQ, @FT
		end
		close c_rpt
		deallocate c_rpt
	end
	else --@mode = 1
	begin
		/*根据INV重算并入商品的期末库存*/
		declare c_rpt cursor for
			select GDGID, SUM(QTY), SUM(TOTAL)
			from INV 
			where STORE = @store 
				and (WRH = @oldwrh or WRH = @wrh)
			group by GDGID
		open c_rpt
		fetch next from c_rpt into @gdgid, @FQ, @FT
		while @@fetch_status = 0
		begin
			if exists(select * from INVYRPT
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @wrh)
			begin
				update INVYRPT set FQ = @FQ, FT = @FT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @wrh
			end
			else
			begin
				insert into INVYRPT(ASTORE, ASETTLENO, BGDGID, BWRH,
					FQ, FT)
				values(@store, @settleno, @gdgid, @wrh, @FQ, @FT)
			end
			fetch next from c_rpt into @gdgid, @FQ, @FT
		end		
		close c_rpt
		deallocate c_rpt
		/*被合并仓位的期末库存 := 0 */
		update INVYRPT set FQ = 0, FT = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh
	end

	/* INVCHGYRPT */
	if @mode = 0
	begin
		declare c_rpt cursor for
			select
				BGDGID,
				CQ1 , CQ2 , CQ4 , CQ5 , 
				CI1 , CI2 , CI3 , CI4 , CI5 , 
				CR1 , CR2 , CR3 , CR4 , CR5,
				DQ1 , DQ2 , DQ4 , DQ5 , 
				DI1 , DI2 , DI3 , DI4 , DI5 , 
				DR1 , DR2 , DR3 , DR4 , DR5
			from INVCHGYRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh
		open c_rpt
		fetch next from c_rpt into
			@gdgid,
			@CQ1 , @CQ2 , @CQ4 , @CQ5 , 
			@CI1 , @CI2 , @CI3 , @CI4 , @CI5, 
			@CR1 , @CR2 , @CR3 , @CR4 , @CR5,
			@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
			@DI1 , @DI2 , @DI3 , @DI4 , @DI5, 
			@DR1 , @DR2 , @DR3 , @DR4 , @DR5
		while @@fetch_status = 0
		begin
			if exists ( select * from INVCHGYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @wrh)
			begin
				update INVCHGYRPT set
				CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ4 = CQ4 + @CQ4, CQ5 = CQ5 + @CQ5,
				CI1 = CI1 + @CI1, CI2 = CI2 + @CI2, CI3 = CI3 + @CI3, CI4 = CI4 + @CI4, CI5 = CI5 + @CI5,
				CR1 = CR1 + @CR1, CR2 = CR2 + @CR2, CR3 = CR3 + @CR3, CR4 = CR4 + @CR4, CR5 = CR5 + @CR5,
				DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5,
				DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5,
				DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @wrh
				delete from INVCHGYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @oldwrh
			end
			else
			begin
				update INVCHGYRPT set BWRH = @wrh
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @oldwrh
			end
			fetch next from c_rpt into
				@gdgid,
				@CQ1 , @CQ2 , @CQ4 , @CQ5 , 
				@CI1 , @CI2 , @CI3 , @CI4 , @CI5 , @CR1 , @CR2 , @CR3 , @CR4 , @CR5,
				@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
				@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , @DR1 , @DR2 , @DR3 , @DR4 , @DR5
		end
		close c_rpt
		deallocate c_rpt	
	end
	else --@mode = 1
	begin
		/*根据月报表重算被合并仓位的发生值*/
		update INVCHGYRPT set 
			DQ1 = 0, DQ2 = 0, DQ4 = 0, DQ5 = 0, 
			DI1 = 0, DI2 = 0, DI3 = 0, DI4 = 0, DI5 = 0, 
			DR1 = 0, DR2 = 0, DR3 = 0, DR4 = 0, DR5 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh
		
		declare c_rpt cursor for
			select
				BGDGID,
				SUM(DQ1), SUM(DQ2), SUM(DQ4), SUM(DQ5), 
				SUM(DI1), SUM(DI2), SUM(DI3), SUM(DI4), SUM(DI5), 
				SUM(DR1), SUM(DR2), SUM(DR3), SUM(DR4), SUM(DR5)
			from INVCHGMRPT
			where ASTORE = @store 
				and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
				and BWRH = @oldwrh 
			group by BGDGID
		open c_rpt
		fetch next from c_rpt into 
			@gdgid,
			@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
			@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , 
			@DR1 , @DR2 , @DR3 , @DR4 , @DR5
		while @@fetch_status = 0
		begin
			update INVCHGYRPT set
			DQ1 = @DQ1, DQ2 = @DQ2, DQ4 = @DQ4, DQ5 = @DQ5,
			DI1 = @DI1, DI2 = @DI2, DI3 = @DI3, DI4 = @DI4, DI5 = @DI5,
			DR1 = @DR1, DR2 = @DR2, DR3 = @DR3, DR4 = @DR4, DR5 = @DR5
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @oldwrh

			fetch next from c_rpt into 
				@gdgid,
				@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
				@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , 
				@DR1 , @DR2 , @DR3 , @DR4 , @DR5			
		end		
		close c_rpt
		deallocate c_rpt

		/*根据月报表重算并入仓位的发生值*/
		update INVCHGYRPT set 
			DQ1 = 0, DQ2 = 0, DQ4 = 0, DQ5 = 0, 
			DI1 = 0, DI2 = 0, DI3 = 0, DI4 = 0, DI5 = 0, 
			DR1 = 0, DR2 = 0, DR3 = 0, DR4 = 0, DR5 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @wrh
			
		declare c_rpt cursor for
			select
				BGDGID,
				SUM(DQ1), SUM(DQ2), SUM(DQ4), SUM(DQ5), 
				SUM(DI1), SUM(DI2), SUM(DI3), SUM(DI4), SUM(DI5), 
				SUM(DR1), SUM(DR2), SUM(DR3), SUM(DR4), SUM(DR5)
			from INVCHGMRPT
			where ASTORE = @store 
				and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
				and BWRH = @wrh 
			group by BGDGID
		open c_rpt
		fetch next from c_rpt into 
			@gdgid,
			@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
			@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , 
			@DR1 , @DR2 , @DR3 , @DR4 , @DR5
		while @@fetch_status = 0
		begin
			if exists(select * from INVCHGYRPT
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BWRH = @wrh)
			begin
				update INVCHGYRPT set
				DQ1 = @DQ1, DQ2 = @DQ2, DQ4 = @DQ4, DQ5 = @DQ5,
				DI1 = @DI1, DI2 = @DI2, DI3 = @DI3, DI4 = @DI4, DI5 = @DI5,
				DR1 = @DR1, DR2 = @DR2, DR3 = @DR3, DR4 = @DR4, DR5 = @DR5
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BWRH = @wrh
			end
			else
			begin
				insert into INVCHGYRPT(ASTORE, ASETTLENO, BGDGID, BWRH,
					DQ1, DQ2, DQ4, DQ5, DI1, DI2, DI3, DI4, DI5,
					DR1, DR2, DR3, DR4, DR5)
				values(@store, @settleno, @gdgid, @wrh,
					@DQ1, @DQ2, @DQ4, @DQ5, @DI1, @DI2, @DI3, @DI4, @DI5,
					@DR1, @DR2, @DR3, @DR4, @DR5)
			end
			fetch next from c_rpt into 
				@gdgid,
				@DQ1 , @DQ2 , @DQ4 , @DQ5 , 
				@DI1 , @DI2 , @DI3 , @DI4 , @DI5 , 
				@DR1 , @DR2 , @DR3 , @DR4 , @DR5			
		end		
		close c_rpt
		deallocate c_rpt		
	end

	/* OUTYRPT */
	if @mode = 0
	begin
		declare c_rpt cursor for
			select  
				BCSTGID, BGDGID,
				--CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7,
				--CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT91, CT92,
				--CI1, CI2, CI3, CI4, CI5, CI6, CI7,
				--CR1, CR2, CR3, CR4, CR5, CR6, CR7,
				DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
				DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
				DI1, DI2, DI3, DI4, DI5, DI6, DI7,
				DR1, DR2, DR3, DR4, DR5, DR6, DR7
			from OUTYRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh 
		open c_rpt
		fetch next from c_rpt into
			@cstgid, @gdgid,
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
			if exists ( select * from OUTYRPT
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
			begin
				update OUTYRPT set
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
				delete from OUTYRPT
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
			end     	
			else
			begin
				update OUTYRPT set BWRH = @wrh
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
			end
			fetch next from c_rpt into
				@cstgid, @gdgid,
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
	end
	else --@mode = 1
	begin
		/*根据月报表重算被合并仓位的发生值*/
		update OUTYRPT set
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DQ4 = 0, DQ5 = 0, DQ6 = 0, DQ7 = 0,
			DT1 = 0, DT2 = 0, DT3 = 0, DT4 = 0, DT5 = 0, DT6 = 0, DT7 = 0, 
			DT91 = 0, DT92 = 0,
			DI1 = 0, DI2 = 0, DI3 = 0, DI4 = 0, DI5 = 0, DI6 = 0, DI7 = 0,
			DR1 = 0, DR2 = 0, DR3 = 0, DR4 = 0, DR5 = 0, DR6 = 0, DR7 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh
			
		declare c_rpt cursor for
			select BCSTGID, BGDGID,
				SUM(DQ1), SUM(DQ2), SUM(DQ3), SUM(DQ4), SUM(DQ5), SUM(DQ6), SUM(DQ7),
				SUM(DT1), SUM(DT2), SUM(DT3), SUM(DT4), SUM(DT5), SUM(DT6), SUM(DT7), 
				SUM(DT91), SUM(DT92),
				SUM(DI1), SUM(DI2), SUM(DI3), SUM(DI4), SUM(DI5), SUM(DI6), SUM(DI7),
				SUM(DR1), SUM(DR2), SUM(DR3), SUM(DR4), SUM(DR5), SUM(DR6), SUM(DR7)
			from OUTMRPT
			where ASTORE = @store
			and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
			and BWRH = @oldwrh
			group by BCSTGID, BGDGID
		open c_rpt
		fetch next from c_rpt into 
			@cstgid, @gdgid,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
			@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
			@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
		while @@fetch_status = 0
		begin
			update OUTYRPT set
			DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3, DQ4 = @DQ4, DQ5 = @DQ5, DQ6 = @DQ6, DQ7 = @DQ7,
			DT1 = @DT1, DT2 = @DT2, DT3 = @DT3, DT4 = @DT4, DT5 = @DT5, DT6 = @DT6, DT7 = @DT7, 
			DT91 = @DT91, DT92 = @DT92,
			DI1 = @DI1, DI2 = @DI2, DI3 = @DI3, DI4 = @DI4, DI5 = @DI5, DI6 = @DI6, DI7 = @DI7,
			DR1 = @DR1, DR2 = @DR2, DR3 = @DR3, DR4 = @DR4, DR5 = @DR5, DR6 = @DR6, DR7 = @DR7					
			where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
						
			fetch next from c_rpt into 
				@cstgid, @gdgid,
				@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
				@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
				@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
				@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
		end
		close c_rpt
		deallocate c_rpt
				
		/*根据月报表重算并入仓位的发生值*/
		update OUTYRPT set
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DQ4 = 0, DQ5 = 0, DQ6 = 0, DQ7 = 0,
			DT1 = 0, DT2 = 0, DT3 = 0, DT4 = 0, DT5 = 0, DT6 = 0, DT7 = 0, 
			DT91 = 0, DT92 = 0,
			DI1 = 0, DI2 = 0, DI3 = 0, DI4 = 0, DI5 = 0, DI6 = 0, DI7 = 0,
			DR1 = 0, DR2 = 0, DR3 = 0, DR4 = 0, DR5 = 0, DR6 = 0, DR7 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @wrh
			
		declare c_rpt cursor for
			select BCSTGID, BGDGID,
				SUM(DQ1), SUM(DQ2), SUM(DQ3), SUM(DQ4), SUM(DQ5), SUM(DQ6), SUM(DQ7),
				SUM(DT1), SUM(DT2), SUM(DT3), SUM(DT4), SUM(DT5), SUM(DT6), SUM(DT7), SUM(DT91), SUM(DT92),
				SUM(DI1), SUM(DI2), SUM(DI3), SUM(DI4), SUM(DI5), SUM(DI6), SUM(DI7),
				SUM(DR1), SUM(DR2), SUM(DR3), SUM(DR4), SUM(DR5), SUM(DR6), SUM(DR7)
			from OUTMRPT
			where ASTORE = @store
			and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
			and BWRH = @wrh
			group by BCSTGID, BGDGID
		open c_rpt
		fetch next from c_rpt into 
			@cstgid, @gdgid,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
			@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
			@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
		while @@fetch_status = 0
		begin
			if exists(select * from OUTYRPT
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
			begin
				update OUTYRPT set
				DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3, DQ4 = @DQ4, DQ5 = @DQ5, DQ6 = @DQ6, DQ7 = @DQ7,
				DT1 = @DT1, DT2 = @DT2, DT3 = @DT3, DT4 = @DT4, DT5 = @DT5, DT6 = @DT6, DT7 = @DT7, 
				DT91 = @DT91, DT92 = @DT92,
				DI1 = @DI1, DI2 = @DI2, DI3 = @DI3, DI4 = @DI4, DI5 = @DI5, DI6 = @DI6, DI7 = @DI7,
				DR1 = @DR1, DR2 = @DR2, DR3 = @DR3, DR4 = @DR4, DR5 = @DR5, DR6 = @DR6, DR7 = @DR7					
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
			end
			else
			begin
				insert into OUTYRPT(ASTORE, ASETTLENO, BGDGID, BCSTGID, BWRH,
					DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
					DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
					DI1, DI2, DI3, DI4, DI5, DI6, DI7,
					DR1, DR2, DR3, DR4, DR5, DR6, DR7)
				values(@store, @settleno, @gdgid, @cstgid, @wrh,
					@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
					@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
					@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
					@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7)				
			end
			fetch next from c_rpt into 
				@cstgid, @gdgid,
				@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
				@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
				@DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
				@DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
		end
		close c_rpt
		deallocate c_rpt
	end

	/* CSTYRPT */
	if @mode = 0
	begin	
		declare c_rpt cursor for
			select BCSTGID, BGDGID, 
				CQ1, CQ2, CQ3, CT1, CT2, CT3, CT4, 
				DQ1, DQ2, DQ3, DT1, DT2, DT3
			from CSTYRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh
		open c_rpt  	
		fetch next from c_rpt into 
			@cstgid, @gdgid,
			@CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4,
			@DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
		while @@fetch_status = 0
		begin
			if exists ( select * from CSTYRPT
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
			begin
				update CSTYRPT set
				CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3,
				CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
				DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3,
				DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
				delete from CSTYRPT
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
			end
			else
			begin
				update CSTYRPT set BWRH = @wrh
				where ASTORE = @store and ASETTLENO = @settleno 
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
			end
			fetch next from c_rpt into 
				@cstgid, @gdgid,
				@CQ1, @CQ2, @CQ3, @CT1, @CT2, @CT3, @CT4,
				@DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
		end
		close c_rpt
		deallocate c_rpt
	end
	else --@mode = 1
	begin
		/*根据月报表重算被合并仓位的发生值*/
		update CSTYRPT set
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DT1 = 0, DT2 = 0, DT3 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh
			
		declare c_rpt cursor for
			select BCSTGID, BGDGID, SUM(DQ1), SUM(DQ2), SUM(DQ3), 
					SUM(DT1), SUM(DT2), sum(DT3)
			from CSTMRPT
			where ASTORE = @store 
				and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
				and BWRH = @oldwrh
			group by BCSTGID, BGDGID
		open c_rpt
		fetch next from c_rpt into 
			@cstgid, @gdgid, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
		while @@fetch_status = 0
		begin
			update CSTYRPT set
				DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3,
				DT1 = @DT1, DT2 = @DT2, DT3 = @DT3
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @oldwrh
			fetch next from c_rpt into 
				@cstgid, @gdgid, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
		end
		close c_rpt
		deallocate c_rpt

		/*根据月报表重算并入仓位的发生值*/
		update CSTYRPT set
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DT1 = 0, DT2 = 0, DT3 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @wrh
			
		declare c_rpt cursor for
			select BCSTGID, BGDGID, SUM(DQ1), SUM(DQ2), SUM(DQ3), 
					SUM(DT1), SUM(DT2), sum(DT3)
			from CSTMRPT
			where ASTORE = @store 
				and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
				and BWRH = @wrh
			group by BCSTGID, BGDGID
		open c_rpt
		fetch next from c_rpt into 
			@cstgid, @gdgid, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
		while @@fetch_status = 0
		begin
			if exists(select * from CSTYRPT
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
			begin
				update CSTYRPT set
					DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3,
					DT1 = @DT1, DT2 = @DT2, DT3 = @DT3
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
			end
			else
			begin
				insert into CSTYRPT(ASTORE, ASETTLENO, BGDGID, BCSTGID, BWRH,
					DQ1, DQ2, DQ3, DT1, DT2, DT3)
				values(@store, @settleno, @gdgid, @cstgid, @wrh,
					@DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3)
			end
			fetch next from c_rpt into 
				@cstgid, @gdgid, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
		end
		close c_rpt
		deallocate c_rpt
	end

	/* VDRYRPT */
	if @mode = 0
	begin
		declare c_rpt cursor for
			select
				BVDRGID, BGDGID,
				CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
				CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8,
				DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
				DT1, DT2, DT3, DT4, DT5, DT6, DT7, CI2, DI2
			from VDRYRPT
			where ASTORE = @store and ASETTLENO = @settleno
				and BWRH = @oldwrh
		open c_rpt
		fetch next from c_rpt into
			@vdrgid, @gdgid,
			@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
			@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @CI2, @DI2
		while @@fetch_status = 0
		begin
			if exists (select * from VDRYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh)
			begin
				update VDRYRPT set
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
				delete from VDRYRPT
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh 
			end
			else
			begin
				update VDRYRPT set BWRH = @wrh
				where ASTORE = @store and ASETTLENO = @settleno
					and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh 
			end

			update VDRYRPTLOG set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh 
								
			fetch next from c_rpt into
				@vdrgid, @gdgid,
				@CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
				@CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
				@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
				@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @CI2, @DI2
		end
		close c_rpt
		deallocate c_rpt
	end
	else --@mode = 1
	begin
		/*根据月报表重算被合并仓位发生值*/
		update VDRYRPT set
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DQ4 = 0, DQ5 = 0, DQ6 = 0,
			DT1 = 0, DT2 = 0, DT3 = 0, DT4 = 0, DT5 = 0, DT6 = 0, DT7 = 0,
			DI2 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @oldwrh
		
		declare c_rpt cursor for
			select BVDRGID, BGDGID,
				SUM(DQ1), SUM(DQ2), SUM(DQ3), SUM(DQ4), SUM(DQ5), SUM(DQ6),
				SUM(DT1), SUM(DT2), SUM(DT3), SUM(DT4), SUM(DT5), SUM(DT6), SUM(DT7),
				SUM(DI2)
			from VDRMRPT
			where ASTORE = @store 
				and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
				and BWRH = @oldwrh
			group by BVDRGID, BGDGID
		open c_rpt
		fetch next from c_rpt into
			@vdrgid, @gdgid,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
		while @@fetch_status = 0
		begin
			update VDRYRPT set 
			DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3, DQ4 = @DQ4,
			DQ5 = @DQ5, DQ6 = @DQ6,
			DT1 = @DT1, DT2 = @DT2, DT3 = @DT3, DT4 = @DT4,
			DT5 = @DT5, DT6 = @DT6, DT7 = @DT7,
			DI2 = @DI2		
			where ASTORE = @store and ASETTLENO = @settleno
			and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh

			update VDRYRPTLOG set BWRH = @wrh
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @oldwrh 
							
			fetch next from c_rpt into
				@vdrgid, @gdgid,
				@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
				@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
		end		
		close c_rpt
		deallocate c_rpt

		/*根据月报表重算并入仓位的发生值*/
		update VDRYRPT set
			DQ1 = 0, DQ2 = 0, DQ3 = 0, DQ4 = 0, DQ5 = 0, DQ6 = 0,
			DT1 = 0, DT2 = 0, DT3 = 0, DT4 = 0, DT5 = 0, DT6 = 0, DT7 = 0,
			DI2 = 0
		where ASTORE = @store and ASETTLENO = @settleno
			and BWRH = @wrh
			
		declare c_rpt cursor for
			select BVDRGID, BGDGID,
				SUM(DQ1), SUM(DQ2), SUM(DQ3), SUM(DQ4), SUM(DQ5), SUM(DQ6),
				SUM(DT1), SUM(DT2), SUM(DT3), SUM(DT4), SUM(DT5), SUM(DT6), SUM(DT7),
				SUM(DI2)
			from VDRMRPT
			where ASTORE = @store 
				and ASETTLENO in (select MNO from V_YM where YNO = @settleno) 
				and BWRH = @wrh
			group by BVDRGID, BGDGID
		open c_rpt
		fetch next from c_rpt into
			@vdrgid, @gdgid,
			@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
			@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
		while @@fetch_status = 0
		begin
			if exists(select * from VDRYRPT                         	
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh)
			begin
				update VDRYRPT set 
				DQ1 = @DQ1, DQ2 = @DQ2, DQ3 = @DQ3, DQ4 = @DQ4,
				DQ5 = @DQ5, DQ6 = @DQ6,
				DT1 = @DT1, DT2 = @DT2, DT3 = @DT3, DT4 = @DT4,
				DT5 = @DT5, DT6 = @DT6, DT7 = @DT7,
				DI2 = @DI2		
				where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh
			end
			else
			begin
				insert into VDRYRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
					DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
					DT1, DT2, DT3, DT4, DT5, DT6, DT7, DI2)
				values(@store, @settleno, @gdgid, @vdrgid, @wrh,
					@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
					@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2)
			end
							
			fetch next from c_rpt into
				@vdrgid, @gdgid,
				@DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
				@DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
		end
		close c_rpt
		deallocate c_rpt
	end
end
GO
