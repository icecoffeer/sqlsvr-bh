SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[RecalcInyrpt]
  @settleno int ,
  @store int = null
as
begin
  declare
    @bmsettleno int,
    @emsettleno int,
    @lsettleno int,

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
    @dr1 money, @dr2 money, @dr3 money, @dr4 money

  if @store is null select @store = usergid from system
  select @bmsettleno = min(mno), @emsettleno = max(mno) from v_ym where yno = @settleno
  select @lsettleno = max(no) from yearsettle where no < @settleno

  delete from inyrpt where astore = @store and asettleno = @settleno

  insert into INYRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
		  DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
		  DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4)
  select @store, @settleno, BGDGID, BVDRGID, BWRH,
	  sum(DQ1), sum(DQ2), sum(DQ3), sum(DQ4),
	  sum(DT1), sum(DT2), sum(DT3), sum(DT4),
	  sum(DI1), sum(DI2), sum(DI3), sum(DI4),
	  sum(DR1), sum(DR2), sum(DR3), sum(DR4)
  from INMRPT
  where ASTORE = @store
  and ASETTLENO between @bmsettleno and @emsettleno
  group by BGDGID, BVDRGID, BWRH

  if @lsettleno is not null
  begin
	  declare c_inyrpt cursor for
		  select BGDGID, BVDRGID, BWRH,
			  CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
			  CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
			  CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4,
			  CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4
		  from INYRPT
		  where ASTORE = @store and ASETTLENO = @lsettleno
	  open c_inyrpt
	  fetch next from c_inyrpt into
		  @gdgid, @vdrgid, @wrh,
		  @cq1, @cq2, @cq3, @cq4, @ct1, @ct2, @ct3, @ct4,
		  @ci1, @ci2, @ci3, @ci4, @cr1, @cr2, @cr3, @cr4
	  while @@fetch_status = 0
	  begin
		  if exists(select * from INYRPT 
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BVDRGID = @vdrgid
			  and BWRH = @wrh)
		  begin
			  update INYRPT set CQ1 = @cq1, CQ2 = @cq2,
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
			  insert into INYRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH, 
				CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
				  CI1, CI2, CI3, CI4, 
				  CR1, CR2, CR3, CR4)
			  values(@store, @settleno, @gdgid, @vdrgid, @wrh,
				@cq1, @cq2, @cq3, @cq4,
				  @ct1, @ct2, @ct3, @ct4,
				  @ci1, @ci2, @ci3, @ci4,
				  @cr1, @cr2, @cr3, @cr4)
		  end
		  fetch next from c_inyrpt into
			  @gdgid, @vdrgid, @wrh,
			  @cq1, @cq2, @cq3, @cq4, @ct1, @ct2, @ct3, @ct4,
                          @ci1, @ci2, @ci3, @ci4, @cr1, @cr2, @cr3, @cr4
          end
          close c_inyrpt
          deallocate c_inyrpt
  end
end

GO
