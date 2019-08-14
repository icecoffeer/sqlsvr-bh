SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[recalccstmrpt]
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

  delete from cstmrpt where astore = @store and asettleno = @settleno
  
  insert into CSTMRPT(ASTORE, ASETTLENO, BGDGID, BCSTGID, BWRH,
		  DQ1, DQ2, DQ3,
		  DT1, DT2, DT3)
  select @STORE, @SETTLENO, BGDGID, BCSTGID, BWRH,
	  sum(DQ1), sum(DQ2), sum(DQ3),
	  sum(DT1), sum(DT2), sum(DT3)
  from CSTDRPT
  where ADATE between @begindate and @enddate
  and ASTORE = @store
  and ASETTLENO = @settleno
  group by BGDGID, BCSTGID, BWRH

  if @settleno > 1
  begin	  
	  if (select yno from v_ym where mno = @settleno) <>
		(select yno from v_ym where mno = @old_settleno)
		select @firstofyear = 1        --//两个月结转期不在同一个年结转期内
	  declare c_cstmrpt cursor for
	  select BGDGID, BCSTGID, BWRH,
		  CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3,
		  CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT3 - DT1
	  from CSTMRPT
	  where ASTORE = @store and ASETTLENO = @old_settleno
	  open c_cstmrpt
	  fetch next from c_cstmrpt into
		  @gdgid, @cstgid, @wrh,
		  @cq1, @cq2, @cq3,
		  @ct1, @ct2, @ct3, @ct4
	  while @@fetch_status = 0
	  begin		
		  if @firstofyear = 1
			select @cq1 = 0, @cq2 = 0, @cq3 = 0,
				  @ct1 = 0, @ct2 = 0, @ct3 = 0
				  
		  if exists(select * from CSTMRPT 
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BCSTGID = @cstgid
			  and BWRH = @wrh) 
		  begin
			  update CSTMRPT set
				  CQ1 = @cq1, CQ2 = @cq2, CQ3 = @cq3,
				  CT1 = @ct1, CT2 = @ct2, CT3 = @ct3, CT4 = @ct4
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BCSTGID = @cstgid
				  and BWRH = @wrh
		  end
		  else
		  begin
			insert into CSTMRPT(ASTORE, ASETTLENO, 
				BGDGID, BCSTGID, BWRH,
				CQ1, CQ2, CQ3, CT1, CT2, CT3, CT4)
			values(@store, @settleno, @gdgid, @cstgid, @wrh,
				@cq1, @cq2, @cq3, @ct1, @ct2, @ct3, @ct4)
		  end
		  fetch next from c_cstmrpt into
			  @gdgid, @cstgid, @wrh,
			  @cq1, @cq2, @cq3,
			  @ct1, @ct2, @ct3, @ct4
	  end
	  close c_cstmrpt
	  deallocate c_cstmrpt
  end
end

GO
