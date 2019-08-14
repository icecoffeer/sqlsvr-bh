SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCDIFFEX](
  @p_num char(14),
  @raw int  --0 = 产品；1 = 原料；
)
with encryption as
begin
  declare
    @return_status int,
    @astore int,
    @asettleno smallint,
    @adate datetime,
    @d_line smallint,
    @d_gdgid int,
    @d_raw smallint,
    @d_qty money,
    @d_total money,
    @d_cstprc money,
    @d_inprc money,
    @d_rtlprc money,
    @d_cntinprc money,
    @d_lwtrtlprc money,
    @d_wrh int,

    @CostAmt money,
    @pdtcost money,
    @rawcost money,
    @diffamt money,
    @diff money,
    @Tdiff money,
    @yno smallint

  select @astore = usergid from system
  select @asettleno = max(NO) from MONTHSETTLE
  select @adate = convert(datetime,convert(char,getdate(),102))
  select @yno = max(no) from yearsettle
  select @pdtcost = Sum(Total) from ProcExecProd where Num = @p_num
  select @rawcost = Sum(Total) from ProcExecRaw where Num = @p_num
  select @diffamt = @pdtcost - @rawcost
  if @raw = 0
  begin
    select @costamt = @pdtcost
  end else
  begin
    select @costamt = @rawcost
  end	       

  select @return_status = 0, @tdiff = 0  
  if @raw = 0
  begin
    declare c_diff cursor for
      select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, WRH
      from ProcExecProd where NUM = @p_num order by line desc
      for update
    open c_diff
    fetch next from c_diff into
      @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh
    while @@fetch_status = 0 begin
      if @d_line = 1
        select @diff = @diffamt - @tdiff
      else 
      begin
        select @diff = @d_total / @costamt *@diffamt
        select @tdiff = @tdiff + @diff
      end
      
      if not exists (select 1 from PROCDRPT where astore = @astore and asettleno = @asettleno and adate = @adate
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
         insert into PROCDRPT
            values(@astore, @asettleno, @adate, @d_wrh, @d_gdgid, @d_qty, @d_total, @d_inprc * @d_qty, @d_rtlprc * @d_qty, @diff)
      else
         update PROCDRPT set dq1 = dq1 + @d_qty, dt1 = dt1 + @d_total, di1 = di1 + @d_inprc * @d_qty,
                                dr1 = dr1 + @d_rtlprc * @d_qty, dd1 = dd1 + @diff
            where astore = @astore and asettleno = @asettleno and adate = @adate
                  and bwrh = @d_wrh and bgdgid = @d_gdgid

      if not exists (select 1 from PROCMRPT where astore = @astore and asettleno = @asettleno 
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
         insert into PROCMRPT(astore, asettleno, bwrh, bgdgid, dq1, dt1, di1, dr1, dd1)
            values(@astore, @asettleno, @d_wrh, @d_gdgid, @d_qty, @d_total, @d_inprc * @d_qty, @d_rtlprc * @d_qty, @diff)
      else
         update PROCMRPT set dq1 = dq1 + @d_qty, dt1 = dt1 + @d_total, di1 = di1 + @d_inprc * @d_qty,
                                dr1 = dr1 + @d_rtlprc * @d_qty, dd1 = dd1 + @diff
            where astore = @astore and asettleno = @asettleno  and bwrh = @d_wrh and bgdgid = @d_gdgid

      if not exists (select 1 from PROCYRPT where astore = @astore and asettleno = @yno
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
         insert into PROCYRPT(astore, asettleno, bwrh, bgdgid, dq1, dt1, di1, dr1, dd1)
            values(@astore, @yno, @d_wrh, @d_gdgid, @d_qty, @d_total, @d_inprc * @d_qty, @d_rtlprc * @d_qty, @diff)
      else
         update PROCYRPT set dq1 = dq1 + @d_qty, dt1 = dt1 + @d_total, di1 = di1 + @d_inprc * @d_qty,
                                dr1 = dr1 + @d_rtlprc * @d_qty, dd1 = dd1 + @diff
            where astore = @astore and asettleno = @yno  and bwrh = @d_wrh and bgdgid = @d_gdgid
            
      if @return_status <> 0  return(1)

      fetch next from c_diff into
        @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh            
    end 	
  end else
  begin
    declare c_diff cursor for
      select LINE, GDGID, QTY, TOTAL, INVPRC, RTLPRC, WRH
      from ProcExecRaw where NUM = @p_num order by line desc
      for update
    open c_diff
    fetch next from c_diff into
      @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh
    while @@fetch_status = 0 begin
      if @d_line = 1
        select @diff = @diffamt - @tdiff
      else 
      begin
        select @diff = @d_total / @costamt *@diffamt
        select @tdiff = @tdiff + @diff
      end
      if not exists (select 1 from PROCDRPT where astore = @astore and asettleno = @asettleno and adate = @adate
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
         insert into PROCDRPT
            values(@astore, @asettleno, @adate, @d_wrh, @d_gdgid, -@d_qty, -@d_total, -@d_inprc * @d_qty, -@d_rtlprc * @d_qty, -@diff)
      else
         update PROCDRPT set dq1 = dq1 -@d_qty, dt1 = dt1 - @d_total, di1 = di1 - @d_inprc * @d_qty,
                                dr1 = dr1 - @d_rtlprc * @d_qty, dd1 = dd1 - @diff
            where astore = @astore and asettleno = @asettleno and adate = @adate
                  and bwrh = @d_wrh and bgdgid = @d_gdgid

      if not exists (select 1 from PROCMRPT where astore = @astore and asettleno = @asettleno 
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
         insert into PROCMRPT(astore, asettleno, bwrh, bgdgid, dq1, dt1, di1, dr1, dd1)
            values(@astore, @asettleno, @d_wrh, @d_gdgid, -@d_qty, -@d_total, -@d_inprc * @d_qty, -@d_rtlprc * @d_qty, -@diff)
      else
         update PROCMRPT set dq1 = dq1 - @d_qty, dt1 = dt1 - @d_total, di1 = di1 - @d_inprc * @d_qty,
                                dr1 = dr1 - @d_rtlprc * @d_qty, dd1 = dd1 - @diff
            where astore = @astore and asettleno = @asettleno  and bwrh = @d_wrh and bgdgid = @d_gdgid

      if not exists (select 1 from PROCYRPT where astore = @astore and asettleno = @yno
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
         insert into PROCYRPT(astore, asettleno, bwrh, bgdgid, dq1, dt1, di1, dr1, dd1)
            values(@astore, @yno, @d_wrh, @d_gdgid, -@d_qty, -@d_total, -@d_inprc * @d_qty, -@d_rtlprc * @d_qty, -@diff)
      else
         update PROCYRPT set dq1 = dq1 - @d_qty, dt1 = dt1 - @d_total, di1 = di1 - @d_inprc * @d_qty,
                                dr1 = dr1 - @d_rtlprc * @d_qty, dd1 = dd1 - @diff
            where astore = @astore and asettleno = @yno  and bwrh = @d_wrh and bgdgid = @d_gdgid
      
      if @return_status <> 0  return(1)

      fetch next from c_diff into
        @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh      
    end  
  end
  close c_diff
  deallocate c_diff

end
GO
