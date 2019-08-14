SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
  将VDRDRPT中@store, @settleno, @gdgid的SALE从@oldsale改成@sale
*/
create procedure [dbo].[GdChgSaleVdrDRpt]
  @store int,
  @settleno int,
  @gdgid int,
  @oldsale int,
  @sale int,
  @dxprc money,
  @payrate money,
  @mode int,
  --@mode 0 修改整期数据
  --@mode 1 修改日期范围内数据
  @begindate datetime,
  @enddate datetime
as
begin
	if @oldsale = @sale
        	return(0)
                
	/* VDRDRPT */
	if @mode = 0 
		select @begindate = convert(datetime, convert(char(10), BEGINDATE, 102)),
			@enddate = convert(datetime, convert(char(10), ENDDATE, 102))		
		from MONTHSETTLE where NO = @settleno
					
	if @oldsale = 1
	begin
		if @sale = 2
		begin
			update VDRDRPT set DQ3 = DQ2, DT3 = DQ2 * @dxprc
			 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			 and ADATE >= @begindate and ADATE <= @enddate
		end
		else if @sale = 3
		begin
			update VDRDRPT set DQ3 = DQ2, DT3 = DT2 * @payrate / 100.0
			 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			 and ADATE >= @begindate and ADATE <= @enddate
		end
	end
	else if @oldsale = 2
	begin
		if @sale = 1
		begin
			update VDRDRPT set DQ3 = DQ1, DT3 = DT1
			 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			 and ADATE >= @begindate and ADATE <= @enddate
		end
		else if @sale = 3
		begin
			update VDRDRPT set DT3 = DT2 * @payrate / 100.0
			 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			 and ADATE >= @begindate and ADATE <= @enddate
		end
	end
	else if @oldsale = 3
	begin
		if @sale = 1
		begin
			update VDRDRPT set DQ3 = DQ1, DT3 = DT1
			 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			 and ADATE >= @begindate and ADATE <= @enddate
		end
		else if @sale = 2
		begin
			update VDRDRPT set DT3 = DT2 * @dxprc
			 where BGDGID = @gdgid and ASTORE = @store and ASETTLENO = @settleno
			 and ADATE >= @begindate and ADATE <= @enddate
		end
	end
end

GO
