SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
  将VDRMRPT中@store, @settleno, @gdgid的SALE从@oldsale改成@sale
*/
create procedure [dbo].[GdChgSaleVdrMRpt]
  @store int,
  @settleno int,
  @gdgid int,
  @oldsale int,
  @sale int,
  @dxprc money,
  @payrate money,
  @mode int
  --@mode 0 修改全部数据 修改期初值和发生值
  --@mode 1 修改本期数据 修改发生值
  --@mode 2 修改本期日期范围内数据 根据VDRDRPT重算发生值
as
begin
	if @oldsale = @sale
        	return(0)
                
	declare @vdrgid int, @wrh int, @CT8 money, @dq3 money, @dt3 money
	
	/* VDRMRPT */
	if @mode = 0
	begin
		if @oldsale = 1
		begin
			if @sale = 2
			begin
				update VDRMRPT set CQ3 = CQ2, CT3 = CQ2 * @dxprc,
					DQ3 = DQ2, DT3 = DQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRMRPT set CQ3 = CQ2, CT3 = CT2 * @payrate / 100.0,
						DQ3 = DQ2, DT3 = DT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 2
		begin
			if @sale = 1
			begin				
				update VDRMRPT set CQ3 = CQ1, CT3 = CT1,
						DQ3 = DQ1, DT3 = DT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRMRPT set CT3 = CT2 * @payrate / 100.0,
						DT3 = DT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 3
		begin
			if @sale = 1
			begin
				update VDRMRPT set CQ3 = CQ1, CT3 = CT1,
						DQ3 = DQ1, DT3 = DT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 2
			begin
				update VDRMRPT set CT3 = CQ2 * @dxprc,
						DT3 = DQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end

		/* 重算VDRMRPT 的CT8 */
		declare c_vdrmrpt cursor for
			select BVDRGID, BWRH, CT8 + DT3 - DT4 + DT6
			from VDRMRPT
			where ASTORE = @store and ASETTLENO = @settleno - 1
				and BGDGID = @gdgid 
		open c_vdrmrpt
		fetch next from c_vdrmrpt into 
			@vdrgid, @wrh, @CT8
		while @@fetch_status = 0
		begin
			update VDRMRPT set CT8 = @CT8
			where ASTORE = @store and ASETTLENO = @settleno
				and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh
				
			fetch next from c_vdrmrpt into 
				@vdrgid, @wrh, @CT8
		end
		close c_vdrmrpt
		deallocate c_vdrmrpt
	end
	else if @mode = 1 
	begin
		if @oldsale = 1
		begin
			if @sale = 2
			begin
				update VDRMRPT set DQ3 = DQ2, DT3 = DQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRMRPT set DQ3 = DQ2, DT3 = DT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 2
		begin
			if @sale = 1
			begin
				update VDRMRPT set DQ3 = DQ1, DT3 = DT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRMRPT set DT3 = DT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 3
		begin
			if @sale = 1
			begin
				update VDRMRPT set DQ3 = DQ1, DT3 = DT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 2
			begin
				update VDRMRPT set DT3 = DQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end		
	end
	else  --@mode = 2 根据日报表重算发生值
	begin		
		declare c_vdrdrpt cursor for
			  select BVDRGID, BWRH, SUM(DQ3), SUM(DT3)
			  from VDRDRPT			  
			  where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @gdgid
			  group by BVDRGID, BWRH	
		open c_vdrdrpt
		fetch next from c_vdrdrpt into
			@vdrgid, @wrh, @dq3, @dt3
		while @@fetch_status = 0
		begin		
			update VDRMRPT set DQ3 = @dq3, DT3 = @dt3
			where ASTORE = @store and ASETTLENO = @settleno 
				and BGDGID = @gdgid
				and BVDRGID = @vdrgid AND BWRH = @wrh
			fetch next from c_vdrdrpt into
				@vdrgid, @wrh, @dq3, @dt3	
		end
		close c_vdrdrpt
		deallocate c_vdrdrpt
	end
end

GO
