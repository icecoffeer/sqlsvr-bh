SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Recalcvdrmrpt]
  @settleno int,
  @store int = null
as
begin
  declare
    @old_settleno int,
    
    @begindate datetime,
    @enddate datetime, 	
    @date datetime, @gdgid int,
    @vdrgid int, @wrh int,
    @cq1 money, @cq2 money, @cq3 money, @cq4 money, @cq5 money, @cq6 money,
    @ct1 money, @ct2 money, @ct3 money, @ct4 money,
    @ct5 money, @ct6 money, @ct7 money, @ct8 money,
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

  delete from vdrmrpt where astore = @store and asettleno = @settleno

  insert into VDRMRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
		  DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
		  DT1, DT2, DT3, DT4, DT5, DT6, DT7, di2)
  select @STORE, @SETTLENO, BGDGID, BVDRGID, BWRH,
	  sum(DQ1), sum(DQ2), sum(DQ3), sum(DQ4), sum(DQ5), sum(DQ6),
	  sum(DT1), sum(DT2), sum(DT3), sum(DT4),
	  sum(DT5), sum(DT6), sum(DT7), sum(di2)
  from VDRDRPT
  where ADATE between @begindate and @enddate
  and ASTORE = @store
  and ASETTLENO = @settleno
  group by BGDGID, BVDRGID, BWRH

  if @settleno > 1
  begin
  	  if (select yno from v_ym where mno = @settleno) <>
		(select yno from v_ym where mno = @old_settleno)
		select @firstofyear = 1        --//两个月结转期不在同一个年结转期内

	  declare c_vdrmrpt cursor for
		  select BGDGID, BVDRGID, BWRH,
			  CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
			  CQ5 + DQ5, CQ6 + DQ6,
			  CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
			  CT5 + DT5, CT6 + DT6, CT7 + DT7, CT8 + DT3 + DT6 - DT4,
                          ci2 + di2
		  from VDRMRPT
		  where ASTORE = @store and ASETTLENO = @settleno - 1
	  open c_vdrmrpt
	  fetch next from c_vdrmrpt into
		  @gdgid, @vdrgid, @wrh,
		  @cq1, @cq2, @cq3, @cq4, @cq5, @cq6,
		  @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct8, @ci2
	  while @@fetch_status = 0
	  begin
		  if @firstofyear = 1
			select @cq1 = 0, @cq2 = 0, @cq3 = 0, @cq4 = 0,
				  @ct1 = 0, @ct2 = 0, @ct3 = 0, @ct4 = 0,
				  @ct5 = 0, @ct6 = 0, @ct7 = 0, @ci2 = 0
		  if exists(select * from VDRMRPT
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BVDRGID = @vdrgid
			  and BWRH = @wrh)
		  begin
			  update VDRMRPT set
				  CQ1 = @cq1, CQ2 = @cq2, CQ3 = @cq3, CQ4 = @cq4,
				  CT1 = @ct1, CT2 = @ct2, CT3 = @ct3, CT4 = @ct4,
				  CT5 = @ct5, CT6 = @ct6, CT7 = @ct7, CT8 = @ct8,
                                  ci2 = @ci2
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BVDRGID = @vdrgid
				  and BWRH = @wrh
		  end
		  else
		  begin
			  insert into VDRMRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
				  CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
				  CT5, CT6, CT7, CT8, ci2)
			  values(@store, @settleno, @gdgid, @vdrgid, @wrh,
				  @cq1, @cq2, @cq3, @cq4,
				  @ct1, @ct2, @ct3, @ct4,
				  @ct5, @ct6, @ct7, @ct8, @ci2)
		  end
		  fetch next from c_vdrmrpt into
                          @gdgid, @vdrgid, @wrh,
                          @cq1, @cq2, @cq3, @cq4, @cq5, @cq6,
                          @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct8, @ci2
          end
          close c_vdrmrpt
          deallocate c_vdrmrpt
  end
end
GO
