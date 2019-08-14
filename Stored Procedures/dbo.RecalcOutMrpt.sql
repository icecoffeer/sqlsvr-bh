SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcOutMrpt]
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
    @cstgid int,

    @cq1 money, @cq2 money, @cq3 money, @cq4 money,
    @cq5 money, @cq6 money, @cq7 money,
    @ct1 money, @ct2 money, @ct3 money, @ct4 money,
    @ct5 money, @ct6 money, @ct7 money,
    @ct91 money, @ct92 money,
    @ci1 money, @ci2 money, @ci3 money, @ci4 money,
    @ci5 money, @ci6 money, @ci7 money,
    @cr1 money, @cr2 money, @cr3 money, @cr4 money,
    @cr5 money, @cr6 money, @cr7 money,

    @dq1 money, @dq2 money, @dq3 money, @dq4 money,
    @dq5 money, @dq6 money, @dq7 money,
    @dt1 money, @dt2 money, @dt3 money, @dt4 money,
    @dt5 money, @dt6 money, @dt7 money,
    @dt91 money, @dt92 money,
    @di1 money, @di2 money, @di3 money, @di4 money,
    @di5 money, @di6 money, @di7 money,
    @dr1 money, @dr2 money, @dr3 money, @dr4 money,
    @dr5 money, @dr6 money, @dr7 money,

    @firstofyear smallint

    select @firstofyear = 0

  if @store is null select @store = usergid from system
  select @old_settleno = @settleno - 1

  --使用索引
  select @begindate = convert(datetime, convert(char(10), begindate, 102)),
	@enddate = convert(datetime, convert(char(10), enddate, 102)) 
  from monthsettle
  where no = @settleno

  delete from outmrpt where astore = @store and asettleno = @settleno

  insert into OUTMRPT(ASTORE, ASETTLENO, BGDGID, BCSTGID, BWRH,
		  DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
		  DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
		  DI1, DI2, DI3, DI4, DI5, DI6, DI7,
		  DR1, DR2, DR3, DR4, DR5, DR6, DR7)
  select @store, @SETTLENO, BGDGID, BCSTGID, BWRH,
	  sum(DQ1), sum(DQ2), sum(DQ3), sum(DQ4), sum(DQ5), sum(DQ6), sum(DQ7),
	  sum(DT1), sum(DT2), sum(DT3), sum(DT4), sum(DT5), sum(DT6), sum(DT7),
	  sum(DT91), sum(DT92),
	  sum(DI1), sum(DI2), sum(DI3), sum(DI4), sum(DI5), sum(DI6), sum(DI7),
	  sum(DR1), sum(DR2), sum(DR3), sum(DR4), sum(DR5), sum(DR6), sum(DR7)
  from OUTDRPT
  where ADATE between @begindate and @enddate
  and ASTORE = @store
  and ASETTLENO = @settleno
  group by BGDGID, BCSTGID, BWRH

  /*if @settleno > 1
  begin
  	  if (select yno from v_ym where mno = @settleno) <>
		(select yno from v_ym where mno = @old_settleno)
		select @firstofyear = 1        --//两个月结转期不在同一个年结转期内
		
	  declare c_outmrpt cursor for
		  select BGDGID, BCSTGID, BWRH,
			  CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
			  CQ5 + DQ5, CQ6 + DQ6, CQ7 + DQ7,
			  CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
			  CT5 + DT5, CT6 + DT6, CT7 + DT7,
			  CT91 + DT91, CT92 + DT92,
			  CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4,
			  CI5 + DI5, CI6 + DI6, CI7 + DI7,
			  CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4,
			  CR5 + DR5, CR6 + DR6, CR7 + DR7
		  from OUTMRPT
		  where ASTORE = @store and ASETTLENO = @old_settleno
	  open c_outmrpt
	  fetch next from c_outmrpt into
		  @gdgid, @cstgid, @wrh,
		  @cq1, @cq2, @cq3, @cq4, @cq5, @cq6, @cq7,
		  @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct91, @ct92,
		  @ci1, @ci2, @ci3, @ci4, @ci5, @ci6, @ci7,
		  @cr1, @cr2, @cr3, @cr4, @cr5, @cr6, @cr7
	  while @@fetch_status = 0
	  begin
		  if @firstofyear = 1
			select @cq1 = 0, @cq2 = 0, @cq3 = 0, @cq4 = 0,
				  @cq5 = 0, @cq6 = 0, @cq7 = 0,
				  @ct1 = 0, @ct2 = 0, @ct3 = 0, @ct4 = 0,
				  @ct5 = 0, @ct6 = 0, @ct7 = 0,
				  @ct91 = 0, @ct92 = 0,
				  @ci1 = 0, @ci2 = 0, @ci3 = 0, @ci4 = 0,
				  @ci5 = 0, @ci6 = 0, @ci7 = 0,
				  @cr1 = 0, @cr2 = 0, @cr3 = 0, @cr4 = 0,
				  @cr5 = 0, @cr6 = 0, @cr7 =0
		  if exists(select * from OUTMRPT 
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BCSTGID = @cstgid
			  and BWRH = @wrh)
		  begin
			  update OUTMRPT set
				  CQ1 = @cq1, CQ2 = @cq2, CQ3 = @cq3, CQ4 = @cq4,
				  CQ5 = @cq5, CQ6 = @cq6, CQ7 = @cq7,
				  CT1 = @ct1, CT2 = @ct2, CT3 = @ct3, CT4 = @ct4,
				  CT5 = @ct5, CT6 = @ct6, CT7 = @ct7,
				  CT91 = @ct91, CT92 = @ct92,
				  CI1 = @ci1, CI2 = @ci2, CI3 = @ci3, CI4 = @ci4,
				  CI5 = @ci5, CI6 = @ci6, CI7 = @ci7,
				  CR1 = @cr1, CR2 = @cr2, CR3 = @cr3, CR4 = @cr4,
				  CR5 = @cr5, CR6 = @cr6, CR7 = @cr7
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BCSTGID = @cstgid
				  and BWRH = @wrh
		  end
		  else
		  begin
			  insert into OUTMRPT(ASTORE, ASETTLENO, BGDGID, BCSTGID, BWRH,
				CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7, 
				CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT91, CT92,
				CI1, CI2, CI3, CI4, CI5, CI6, CI7, 
				CR1, CR2, CR3, CR4, CR5, CR6, CR7)
			  values(@store, @settleno, @gdgid, @cstgid, @wrh, 
				  @cq1, @cq2, @cq3, @cq4, @cq5, @cq6, @cq7,
				  @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7,
				  @ct91, @ct92,
				  @ci1, @ci2, @ci3, @ci4, @ci5, @ci6, @ci7,
				  @cr1, @cr2, @cr3, @cr4, @cr5, @cr6, @cr7)
		  end
		  fetch next from c_outmrpt into
			  @gdgid, @cstgid, @wrh,
			  @cq1, @cq2, @cq3, @cq4, @cq5, @cq6, @cq7,
			  @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct91, @ct92,
                          @ci1, @ci2, @ci3, @ci4, @ci5, @ci6, @ci7,
                          @cr1, @cr2, @cr3, @cr4, @cr5, @cr6, @cr7
          end
          close c_outmrpt
          deallocate c_outmrpt
  end*/
end
GO
