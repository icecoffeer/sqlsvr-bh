SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
  将VDRDIRPT中@store, @settleno, @gdgid的SALE从@oldsale改成@sale
*/
create procedure [dbo].[GdChgSaleVdrDIRpt]
  @store int,
  @settleno int,
  @gdgid int,
  @oldsale int,
  @sale int,
  @dxprc money,
  @payrate money,
  @mode int, 
  --@mode 0 修改全部数据 VDRDRPTI 的 CT8 需要重算, CT3直接修改
  --@mode 1 修改本期数据 VDRDRPTI 的 CT8 需要重算(本期第一天除外), CT3直接修改(本期第一天除外)
  --@mode 2 修改从@begindate 到 @enddate 的数据, CT8 和 CT3 都要重算
  @begindate datetime,
  @enddate datetime
as
begin
	if @oldsale = @sale
        	return(0)
                
	declare @date datetime, @vdrgid int, @wrh int, @ct8 money, @cq3 money, 
		@ct3 money

	/* VDRDRPTI */
	if @mode = 0 or @mode = 1
	begin
		select @begindate = convert(datetime, convert(char(10), BEGINDATE, 102)),
			@enddate = convert(datetime, convert(char(10), ENDDATE, 102))	
		from MONTHSETTLE where NO = @settleno

		if (select MAX(NO) from MONTHSETTLE) = @settleno
			select @enddate = convert(datetime, convert(char(10), getdate(), 102))
	end
	
	if @mode = 0
	begin
		if @oldsale = 1 
		begin 
			if @sale = 2
			begin
				update VDRDRPTI set CQ3 = CQ2, CT3 = CQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno      
			end 
			else if @sale = 3
			begin
				update VDRDRPTI set CQ3 = CQ2, CT3 = CT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 2
		begin
			if @sale = 1
			begin
				update VDRDRPTI set CQ3 = CQ1, CT3 = CT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRDRPTI set CT3 = CT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 3
		begin
			if @sale = 1
			begin
				update VDRDRPTI set CQ3 = CQ1, CT3 = CT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 2
			begin
				update VDRDRPTI set CT3 = CQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end

		/*重算第一天的CT8*/
		/*先查找本日上一期的数据*/
		if exists(select * from VDRDRPTI 
			where ASTORE = @store and ASETTLENO = @settleno - 1
				and ADATE = @begindate and BGDGID = @gdgid)
		begin
			declare c_vdrdrpt cursor for
                                select a.BVDRGID, a.BWRH, a.CT8 + ISNULL(b.DT3,0) - ISNULL(b.DT4,0) + ISNULL(b.DT6,0)
				from VDRDRPTI a, VDRDRPT b
				where a.ASTORE = @store and a.ASETTLENO = @settleno - 1
					and a.ADATE = @begindate and a.BGDGID = @gdgid
					and a.ASTORE *= b.ASTORE and a.ASETTLENO *= b.ASETTLENO
					and a.ADATE *= b.ADATE
					and a.BGDGID *= b.BGDGID and a.BVDRGID *= b.BVDRGID
					and a.BWRH *= b.BWRH
		end
		else /*再查找前一日上一期的数据*/
		begin
			declare c_vdrdrpt cursor for
				select a.BVDRGID, a.BWRH, a.CT8 + ISNULL(b.DT3,0) - ISNULL(b.DT4,0) + ISNULL(b.DT6,0)
				from VDRDRPTI a, VDRDRPT b
				where a.ASTORE = @store and a.ASETTLENO = @settleno - 1
					and a.ADATE = dateadd(day, -1, @begindate) and a.BGDGID = @gdgid
					and a.ASTORE *= b.ASTORE and a.ASETTLENO *= b.ASETTLENO 
					and a.ADATE *= b.ADATE
					and a.BGDGID *= b.BGDGID and a.BVDRGID *= b.BVDRGID
					and a.BWRH *= b.BWRH
		end
		
		open c_vdrdrpt
		fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8
				
		while @@fetch_status = 0
		begin
			update VDRDRPTI set CT8 = @ct8
			where ASTORE = @store and ASETTLENO = @settleno
			and ADATE = @begindate and BGDGID = @gdgid
			and BVDRGID = @vdrgid and BWRH = @wrh

			fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8
		end
		close c_vdrdrpt
		deallocate c_vdrdrpt

		/*重算第二天开始的CT8*/
		select @date = dateadd(day, 1, @begindate)
		while @date <= @enddate
		begin
			declare c_vdrdrpt cursor for
			select a.BVDRGID, a.BWRH, a.CT8 + ISNULL(b.DT3,0) - ISNULL(b.DT4,0) + ISNULL(b.DT6,0) 
			from VDRDRPTI a, VDRDRPT b
			where a.ASTORE = @store and a.ASETTLENO = @settleno
			and a.ADATE = dateadd(day, -1, @date)
			and a.BGDGID = @gdgid 
			and a.ASTORE *= b.ASTORE and a.ASETTLENO *= b.ASETTLENO
                        and a.ADATE *= b.ADATE
			and a.BGDGID *= b.BGDGID and a.BVDRGID *= b.BVDRGID
			and a.BWRH *= b.BWRH
			
			open c_vdrdrpt
			fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8
			while @@fetch_status = 0
			begin
				update VDRDRPTI set CT8 = @ct8
				where ASTORE = @store and ASETTLENO = @settleno
				and ADATE = @date and BGDGID = @gdgid 
				and BVDRGID = @vdrgid and BWRH = @wrh
				
				fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8
			end
			close c_vdrdrpt
			deallocate c_vdrdrpt
			select @date = dateadd(day, 1, @date)
		end	       
	end
	else if @mode = 1 
	begin
		if @oldsale = 1 
		begin 
			if @sale = 2
			begin
				update VDRDRPTI set CQ3 = CQ2, CT3 = CQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno      
			end 
			else if @sale = 3
			begin
				update VDRDRPTI set CQ3 = CQ2, CT3 = CT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 2
		begin
			if @sale = 1
			begin
				update VDRDRPTI set CQ3 = CQ1, CT3 = CT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRDRPTI set CT3 = CT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 3
		begin
			if @sale = 1
			begin
				update VDRDRPTI set CQ3 = CQ1, CT3 = CT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 2
			begin
				update VDRDRPTI set CT3 = CQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end

		/*重算第二天开始的CT8*/
		select @date = dateadd(day, 1, @begindate)
		while @date <= @enddate
		begin
			declare c_vdrdrpt cursor for
			select a.BVDRGID, a.BWRH, 
				a.CT8 + ISNULL(b.DT3,0) - ISNULL(b.DT4,0) + ISNULL(b.DT6,0) 
			from VDRDRPTI a, VDRDRPT b
			where a.ASTORE = @store and a.ASETTLENO = @settleno
			and a.ADATE = dateadd(day, -1, @date) and a.BGDGID = @gdgid 
			and a.ASTORE *= b.ASTORE and a.ASETTLENO *= b.ASETTLENO
			and a.ADATE *= b.ADATE
			and a.BGDGID *= b.BGDGID and a.BVDRGID *= b.BVDRGID
			and a.BWRH *= b.BWRH
			
			open c_vdrdrpt
			fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8
			while @@fetch_status = 0
			begin
				update VDRDRPTI set CT8 = @ct8
				where ASTORE = @store and ASETTLENO = @settleno
				and ADATE = @date and BGDGID = @gdgid 
				and BVDRGID = @vdrgid and BWRH = @wrh
				
				fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8
			end
			close c_vdrdrpt
			deallocate c_vdrdrpt
			select @date = dateadd(day, 1, @date)
		end	       
	end
	else   --@mode = 2
	begin
		--重算第二天开始的CQ3, CT3, CT8
		select @date = dateadd(day, 1, @begindate)
		while @date <= @enddate
		begin
			declare c_vdrdrpt cursor for
			select a.BVDRGID, a.BWRH, 
				a.CT8 + ISNULL(b.DT3, 0) - ISNULL(b.DT4, 0) + ISNULL(b.DT6, 0),
				a.CQ3 + ISNULL(b.DQ3, 0), a.CT3 + ISNULL(b.DT3, 0) 
			from VDRDRPTI a, VDRDRPT b
			where a.ASTORE = @store and a.ASETTLENO = @settleno
			and a.ADATE = dateadd(day, -1, @date) and a.BGDGID = @gdgid 
			and a.ASTORE *= b.ASTORE and a.ASETTLENO *= b.ASETTLENO
			and a.ADATE *= b.ADATE
			and a.BGDGID *= b.BGDGID and a.BVDRGID *= b.BVDRGID
			and a.BWRH *= b.BWRH
			
			open c_vdrdrpt
			fetch next from c_vdrdrpt into @vdrgid, @wrh, @ct8, @cq3, @ct3
			while @@fetch_status = 0
			begin
				update VDRDRPTI set CT8 = @ct8, CQ3 = @cq3, CT3 = @ct3
				where ASTORE = @store and ASETTLENO = @settleno
				and ADATE = @date and BGDGID = @gdgid 
				and BVDRGID = @vdrgid and BWRH = @wrh
				
				fetch next from c_vdrdrpt into 
					@vdrgid, @wrh, @ct8, @cq3, @ct3
			end
			close c_vdrdrpt
			deallocate c_vdrdrpt
			select @date = dateadd(day, 1, @date)
		end	       
	end
end

GO
