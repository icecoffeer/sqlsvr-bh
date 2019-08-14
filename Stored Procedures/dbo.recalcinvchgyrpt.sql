SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[recalcinvchgyrpt]
  @settleno int,
  @store int = null
as
begin
  declare
    @bmsettleno int,
    @emsettleno int,
    @lsettleno int,

    @date datetime,
    @gdgid int,
    @wrh int,

    @cq1 money, @cq2 money, @cq3 money, @cq4 money, @cq5 money, @cq6 money, @cq7 money, @ct6 money, @ct7 money,
    @ct1 money, @ct2 money, @ct3 money, @ct4 money,
    @ci1 money, @ci2 money, @ci3 money, @ci4 money, @ci5 money, @ci6 money, @ci7 money,
    @cr1 money, @cr2 money, @cr3 money, @cr4 money, @cr5 money, @cr6 money, @cr7 money,

    @dq1 money, @dq2 money, @dq3 money, @dq4 money, @dq5 money, @dq6 money, @dq7 money,
    @dt1 money, @dt2 money, @dt3 money, @dt4 money,
    @di1 money, @di2 money, @di3 money, @di4 money, @di5 money, @di6 money, @di7 money,
    @dr1 money, @dr2 money, @dr3 money, @dr4 money, @dr5 money, @dr6 money, @dr7 money

  if @store is null select @store = usergid from system
  select @bmsettleno = min(mno), @emsettleno = max(mno) from v_ym where yno = @settleno
  select @lsettleno = max(no) from yearsettle where no < @settleno

  delete from invchgyrpt where astore = @store and asettleno = @settleno

  insert into INVCHGYRPT(ASTORE, ASETTLENO, BGDGID, BWRH,
		  DQ1, DQ2, DQ4, DQ5, DQ6, DQ7, DT6, DT7,
		  DI1, DI2, DI3, DI4, DI5, DI6, DI7,
		  DR1, DR2, DR3, DR4, DR5, DR6, DR7)
  select @STORE, @SETTLENO, BGDGID, BWRH,
	  sum(DQ1), sum(DQ2), sum(DQ4), sum(DQ5), sum(DQ6), sum(DQ7), sum(DT6), sum(DT7),
	  sum(DI1), sum(DI2), sum(DI3), sum(DI4), sum(DI5), sum(DI6), sum(DI7),
	  sum(DR1), sum(DR2), sum(DR3), sum(DR4), sum(DR5), sum(DR6), sum(DR7)
  from INVCHGmRPT
  where ASTORE = @store
  and ASETTLENO between @bmsettleno and @emsettleno
  group by BGDGID, BWRH

  if @lsettleno is not null
  begin
	  declare c_invchgyrpt cursor for
		  select BGDGID, BWRH,
			  CQ1 + DQ1, CQ2 + DQ2, CQ4 + DQ4, CQ5 + DQ5, CQ6 + DQ6, CQ7 + DQ7, CT6 + DT6, CT7 + DT7,
			  CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4, CI5 + DI5, CI6 + DI6, CI7 + DI7,
			  CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4, CR5 + DR5, CR6 + DR6, CR7 + DR7
		  from INVCHGYRPT
		  where ASTORE = @store and ASETTLENO = @lsettleno
	  open c_invchgyrpt
	  fetch next from c_invchgyrpt into
		  @gdgid, @wrh,
		  @cq1, @cq2, @cq4, @cq5, @cq6, @cq7, @ct6, @ct7,
		  @ci1, @ci2, @ci3, @ci4, @ci5, @ci6, @ci7,
		  @cr1, @cr2, @cr3, @cr4, @cr5, @cr6, @cr7
	  while @@fetch_status = 0
	  begin
		  if exists(select * from INVCHGYRPT 
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BWRH = @wrh)
		  begin
			  update INVCHGYRPT set CQ1 = @cq1, CQ2 = @cq2,
				  CQ4 = @cq4, CQ5 = @cq5,
				  CQ6 = @cq6, CQ7 = @cq7,
				  CT6 = @ct6, CT7 = @ct7,
				  CI1 = @ci1, CI2 = @ci2,
				  CI3 = @ci3, CI4 = @ci4,
				  CI5 = @ci5,
				  CI6 = @ci6, CI7 = @ci7,
				  CR1 = @cr1, CR2 = @cr2,
				  CR3 = @cr3, CR4 = @cr4,
				  CR5 = @cr5,
				  CR6 = @cr6, CR7 = @cr7
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BWRH = @wrh
		  end
		  else
		  begin
			insert into INVCHGYRPT(ASTORE, ASETTLENO, BGDGID, BWRH,
				CQ1, CQ2, CQ4, CQ5, CQ6, CQ7, CT6, CT7,
				  CI1, CI2, CI3, CI4, CI5, CI6, CI7,
				  CR1, CR2, CR3, CR4, CR5, CR6, CR7)
			values(@store, @settleno, @gdgid, @wrh,
				@cq1, @cq2, @cq4, @cq5, @cq6, @cq7, @ct6, @ct7,
				  @ci1, @ci2, @ci3, @ci4, @ci5, @ci6, @ci7, 
				  @cr1, @cr2, @cr3, @cr4, @cr5, @cr6, @cr7)
		  end
		  fetch next from c_invchgyrpt into
			  @gdgid, @wrh,
			  @cq1, @cq2, @cq4, @cq5, @cq6, @cq7, @ct6, @ct7,
			  @ci1, @ci2, @ci3, @ci4, @ci5, @ci6, @ci7,
                          @cr1, @cr2, @cr3, @cr4, @cr5, @cr6, @cr7
          end
          close c_invchgyrpt
          deallocate c_invchgyrpt
  end
end
GO
