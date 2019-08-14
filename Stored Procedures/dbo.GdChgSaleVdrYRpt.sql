SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
  将VDRYRPT中@store, @settleno, @gdgid的SALE从@oldsale改成@sale
*/
create procedure [dbo].[GdChgSaleVdrYRpt]
  @store int,
  @settleno int,  --年期号
  @gdgid int,
  @oldsale int,
  @sale int,
  @dxprc money,
  @payrate money,
  @mode int 
  --@mode 0 修改全部数据 VDRYRPT 的期初值和发生值直接修改
  --@mode 1 修改本期数据 VDRYRPT 的发生值需要重算
  --@mode 2 修改从@begindate 到 @enddate 的数据, 发生值需要重算
as
begin
	if @oldsale = @sale
        	return(0)
                
	if @mode = 0
	begin
		if @oldsale = 1
		begin
			if @sale = 2
			begin
				update VDRYRPT set CQ3 = CQ2, CT3 = CQ2 * @dxprc,
					DQ3 = DQ2, DT3 = DQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRYRPT set CQ3 = CQ2, CT3 = CT2 * @payrate / 100.0,
					DQ3 = DQ2, DT3 = DT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 2
		begin
			if @sale = 1
			begin
				update VDRYRPT set CQ3 = CQ1, CT3 = CT1,
					DQ3 = DQ1, DT3 = DT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 3
			begin
				update VDRYRPT set CT3 = CT2 * @payrate / 100.0,
					DT3 = DT2 * @payrate / 100.0
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end
		else if @oldsale = 3
		begin
			if @sale = 1
			begin
				update VDRYRPT set CQ3 = CQ1, CT3 = CT1,
					DQ3 = DQ1, DT3 = DT1
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
			else if @sale = 2
			begin
				update VDRYRPT set CT3 = CQ2 * @dxprc,
					DT3 = DQ2 * @dxprc
				 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			end
		end	
	end
	else   --@mode = 1 or @mode = 2
	begin
		declare @vdrgid int, @wrh int, 
		@dq3 money, @dt3 money

		declare c_vdrmrpt cursor for
			select BVDRGID, BWRH, SUM(DQ3), SUM(DT3)
			from VDRMRPT
			where ASTORE = @store 
			and ASETTLENO in (select MNO from V_YM where YNO = @settleno)
			and BGDGID = @gdgid
			group by BVDRGID, BWRH
		open c_vdrmrpt
		fetch next from c_vdrmrpt into 
			@vdrgid, @wrh, @dq3, @dt3
		while @@fetch_status = 0
		begin
			update VDRYRPT set DQ3 = @dq3, DT3 = @dt3
			where ASTORE = @store
                        	and ASETTLENO = @settleno
                                and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh 

			fetch next from c_vdrmrpt into
				@vdrgid, @wrh, @dq3, @dt3
		end
		close c_vdrmrpt
		deallocate c_vdrmrpt
	end
end

GO
