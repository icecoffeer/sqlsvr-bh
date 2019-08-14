SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[recalcinvyrpt]
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
  select @bmsettleno = min(mno), @emsettleno = max(mno) from v_ym where yno = @settleno
  select @lsettleno = max(no) from yearsettle where no < @settleno

  delete from invyrpt where astore = @store and asettleno = @settleno

  insert into INVYRPT(ASTORE, ASETTLENO, BGDGID, BWRH, FQ, FT,
		  FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,FINVCOST) --2003.02.24 linbo 2003021936141
  select @STORE, @SETTLENO, BGDGID, BWRH, FQ, FT,
		  FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,FINVCOST  --2003.02.24 linbo 2003021936141
  from INVMRPT
  where ASTORE = @store
  and ASETTLENO = @emsettleno
  if @lsettleno is not null
  begin
	  declare c_invyrpt cursor for
		  select BGDGID, BWRH, CQ, CT
		  from INVMRPT
		  where ASTORE = @store and ASETTLENO = @bmsettleno
	  open c_invyrpt
	  fetch next from c_invyrpt into
		  @gdgid, @wrh, @cq, @ct
	  while @@fetch_status = 0
	  begin
		  if exists(select * from INVYRPT
			where ASTORE = @store and ASETTLENO = @settleno
			  and BGDGID = @gdgid and BWRH = @wrh)
		  begin
			  update invyrpt set CQ = @cq, CT = @ct
			  where ASTORE = @store and ASETTLENO = @settleno
				  and BGDGID = @gdgid and BWRH = @wrh
		  end
		  else
		  begin
			  insert into invyrpt(ASTORE, ASETTLENO, BGDGID, BWRH, CQ, CT) 
			  values(@store, @settleno, @gdgid, @wrh, @cq, @ct)
		  end
		  fetch next from c_invyrpt into  --Modified by Jianweicheng 2003.01.28 c_inyrpt-->c_invyrpt
			  @gdgid, @wrh, @cq, @ct
	  end
	  close c_invyrpt
	  deallocate c_invyrpt
  end
end
GO
