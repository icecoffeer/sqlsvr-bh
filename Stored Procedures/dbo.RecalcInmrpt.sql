SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[RecalcInmrpt]
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
    @vdrgid int,
    @wrh int,

    @cq1 money, @cq2 money, @cq3 money, @cq4 money,
    @ct1 money, @ct2 money, @ct3 money, @ct4 money,
    @ci1 money, @ci2 money, @ci3 money, @ci4 money,
    @cr1 money, @cr2 money, @cr3 money, @cr4 money,

    @dq1 money, @dq2 money, @dq3 money, @dq4 money,
    @dt1 money, @dt2 money, @dt3 money, @dt4 money,
    @di1 money, @di2 money, @di3 money, @di4 money,
    @dr1 money, @dr2 money, @dr3 money, @dr4 money,

    @firstofyear smallint

    select @firstofyear = 0

  if @store is null select @store = usergid from system
  select @old_settleno = @settleno - 1
  
  --使用索引
  select @begindate = convert(datetime, convert(char(10), begindate, 102)),
	@enddate = convert(datetime, convert(char(10), enddate, 102)) 
  from monthsettle
  where no = @settleno

  delete from inmrpt where astore = @store and asettleno = @settleno

  insert into INMRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
		  DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
		  DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4)
  select @store, @settleno, BGDGID, BVDRGID, BWRH,
	  sum(DQ1), sum(DQ2), sum(DQ3), sum(DQ4),
	  sum(DT1), sum(DT2), sum(DT3), sum(DT4),
	  sum(DI1), sum(DI2), sum(DI3), sum(DI4),
	  sum(DR1), sum(DR2), sum(DR3), sum(DR4)
  from INDRPT
  where ADATE between @begindate and @enddate
  and ASTORE = @store
  and ASETTLENO = @settleno
  group by BGDGID, BVDRGID, BWRH

  if @settleno > 1
  begin
	  if (select yno from v_ym where mno = @settleno) <>
		(select yno from v_ym where mno = @old_settleno)
		select @firstofyear = 1        --//两个月结转期不在同一个年结转期内
		
	  declare c_inmrpt cursor for
		  select BGDGID, BVDRGID, BWRH,
			  CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
			  CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
			  CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4,
			  CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4
		  from INMRPT
		  where ASTORE = @store and ASETTLENO = @old_settleno
	  open c_inmrpt
	  fetch next from c_inmrpt into
		  @gdgid, @vdrgid, @wrh,
		  @cq1, @cq2, @cq3, @cq4, @ct1, @ct2, @ct3, @ct4,
		  @ci1, @ci2, @ci3, @ci4, @cr1, @cr2, @cr3, @cr4
	  while @@fetch_status = 0
	  begin
		  if @firstofyear = 1
			select @cq1 = 0, @cq2 = 0, @cq3 = 0, @cq4 = 0, 
				  @ct1 = 0, @ct2 = 0, @ct3 = 0, @ct4 = 0,
				  @ci1 = 0, @ci2 = 0, @ci3 = 0, @ci4 = 0,
				  @cr1 = 0, @cr2 = 0, @cr3 = 0, @cr4 = 0
		  if exists(select * from INMRPT 
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BVDRGID = @vdrgid
				  and BWRH = @wrh)
		  begin
			  update INMRPT set CQ1 = @cq1, CQ2 = @cq2,
				  CQ3 = @cq3, CQ4 = @cq4,
				  CT1 = @ct1, CT2 = @ct2,
				  CT3 = @ct3, CT4 = @ct4,
				  CI1 = @ci1, CI2 = @ci2,
				  CI3 = @ci3, CI4 = @ci4,
				  CR1 = @cr1, CR2 = @cr2,
				  CR3 = @cr3, CR4 = @cr4
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BVDRGID = @vdrgid
				  and BWRH = @wrh
		  end
		  else
		  begin
			  insert into INMRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
				CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
				CI1, CI2, CI3, CI4, CR1, CR2, CR3, CR4)
			  values(@store, @settleno, @gdgid, @vdrgid, @wrh,
				@cq1, @cq2, @cq3, @cq4, @ct1, @ct2, @ct3, @ct4,
				@ci1, @ci2, @ci3, @ci4, @cr1, @cr2, @cr3, @cr4)
		  end
		  fetch next from c_inmrpt into
			  @gdgid, @vdrgid, @wrh,
			  @cq1, @cq2, @cq3, @cq4, @ct1, @ct2, @ct3, @ct4,
			  @ci1, @ci2, @ci3, @ci4, @cr1, @cr2, @cr3, @cr4
	  end
	  close c_inmrpt
	  deallocate c_inmrpt
  end
end

GO
