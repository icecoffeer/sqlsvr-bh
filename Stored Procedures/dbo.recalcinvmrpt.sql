SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[recalcinvmrpt]
  @settleno int,
  @store int = null
as
begin
declare
  @old_settleno int,
  
  @begindate datetime,
  @enddate datetime, 	
  @date datetime,
  @gdgid int,
  @wrh int,

  @cq1 money, @cq2 money, @cq3 money, @cq4 money,
  @ct1 money, @ct2 money, @ct3 money, @ct4 money,
  @ci1 money, @ci2 money, @ci3 money, @ci4 money,
  @cr1 money, @cr2 money, @cr3 money, @cr4 money,

  @cq money, @ct money,

  @dq1 money, @dq2 money, @dq3 money, @dq4 money,
  @dt1 money, @dt2 money, @dt3 money, @dt4 money,
  @di1 money, @di2 money, @di3 money, @di4 money,
  @dr1 money, @dr2 money, @dr3 money, @dr4 money

  if @store is null select @store = usergid from system
  select @old_settleno = @settleno - 1

  --使用索引
  select @begindate = convert(datetime, convert(char(10), begindate, 102)),
	@enddate = convert(datetime, convert(char(10), enddate, 102)) 
  from monthsettle
  where no = @settleno

  delete from invmrpt where astore = @store and asettleno = @settleno

  select @date =
	  (select max(ADATE) from INVDRPT where ASETTLENO = @settleno)

  insert into INVMRPT(ASTORE, ASETTLENO, BGDGID, BWRH, FQ, FT,
		  FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,FINVCOST) --2003.02.24 linbo 2003021936141
  select ASTORE, ASETTLENO, BGDGID, BWRH, FQ, FT,
		  FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,FINVCOST  --2003.02.24 linbo 2003021936141
  from INVDRPT
  where ADATE between @begindate and @enddate
  and ASTORE = @store
  and ASETTLENO = @settleno
  and ADATE = @date

  if @settleno > 1
  begin
	  declare c_invmrpt cursor for
		  select BGDGID, BWRH, FQ, FT
		  from INvMRPT
		  where ASTORE = @store and ASETTLENO = @old_settleno
	  open c_invmrpt
	  fetch next from c_invmrpt into
		  @gdgid, @wrh, @cq, @ct
	  while @@fetch_status = 0
	  begin
		  if exists(select * from INVMRPT 
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BWRH = @wrh)
		  begin
			  update INVMRPT set CQ = @cq, CT = @ct
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BWRH = @wrh
		  end
		  else
		  begin
			  insert into INVMRPT(ASTORE, ASETTLENO, BGDGID, BWRH,
				CQ, CT)
			  values(@store, @settleno, @gdgid, @wrh, @cq, @ct)
		  end
		  fetch next from c_invmrpt into
			  @gdgid, @wrh, @cq, @ct
	  end
	  close c_invmrpt
	  deallocate c_invmrpt
  end
end
GO
