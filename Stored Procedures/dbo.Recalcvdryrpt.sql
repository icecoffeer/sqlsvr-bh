SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Recalcvdryrpt]
  @settleno int ,
  @store int = null
as
begin
  declare
    @bmsettleno int,
    @emsettleno int,
    @lsettleno int,
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
    @dr1 money, @dr2 money, @dr3 money, @dr4 money

  if @store is null select @store = usergid from system
  select @bmsettleno = min(mno), @emsettleno = max(mno) from v_ym where yno = @settleno
  select @lsettleno = max(no) from yearsettle where no < @settleno

  delete from vdryrpt where astore = @store and asettleno = @settleno

  insert into VDRYRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
                  DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
                  DT1, DT2, DT3, DT4, DT5, DT6, DT7, di2)
  select @STORE, @SETTLENO, BGDGID, BVDRGID, BWRH,
          sum(DQ1), sum(DQ2), sum(DQ3), sum(DQ4), sum(DQ5), sum(DQ6),
          sum(DT1), sum(DT2), sum(DT3), sum(DT4),
          sum(DT5), sum(DT6), sum(DT7), sum(di2)
  from VDRMRPT
  where ASTORE = @store
  and ASETTLENO between @bmsettleno and @emsettleno
  group by BGDGID, BVDRGID, BWRH

  if @lsettleno is not null
  begin
          declare c_vdryrpt cursor for
                  select BGDGID, BVDRGID, BWRH,
                          CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
                          CQ5 + DQ5, CQ6 + DQ6,
                          CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
                          CT5 + DT5, CT6 + DT6, CT7 + DT7, CT8 + DT3 + DT6 - DT4,
                          ci2 + di2
                  from vdryrpt
                  where ASTORE = @store and ASETTLENO = @lsettleno
          open c_vdryrpt
          fetch next from c_vdryrpt into
                  @gdgid, @vdrgid, @wrh,
                  @cq1, @cq2, @cq3, @cq4, @cq5, @cq6,
                  @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct8, @ci2
          while @@fetch_status = 0
	  begin
		  if exists(select * from VDRYRPT
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BVDRGID = @vdrgid
			  and BWRH = @wrh)
		  begin
			  update vdryrpt set
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
			  insert into VDRYRPT(ASTORE, ASETTLENO, BGDGID, BVDRGID, BWRH,
				CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
				  CT5, CT6, CT7, CT8, ci2)
			  values(@store, @settleno, @gdgid, @vdrgid, @wrh,
				@cq1, @cq2, @cq3, @cq4, @ct1, @ct2, @ct3, @ct4,
				  @ct5, @ct6, @ct7, @ct8, @ci2)
		  end
		  fetch next from c_vdryrpt into
			  @gdgid, @vdrgid, @wrh,
			  @cq1, @cq2, @cq3, @cq4, @cq5, @cq6,
                          @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct8, @ci2
          end
          close c_vdryrpt
          deallocate c_vdryrpt
  end
end
GO
