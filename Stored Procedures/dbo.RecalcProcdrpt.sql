SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcProcdrpt]
  @astore int,
  @asettleno int,
  @adate datetime
as
begin
  declare
    @num char(10),
    @d_line smallint,
    @d_gdgid int,
    @d_qty money,
    @d_total money,
    @d_inprc money,
    @d_rtlprc money,
    @d_wrh int,

    @costAmt1 money,
    @costAmt2 money,
    @diffamt money,
    @diff money,
    @tdiff1 money,
    @tdiff2 money

  delete from rprocdrpt
    where astore = @astore
    and asettleno = @asettleno
    and adate = @adate

  declare c_proc cursor for
  select num from process
    where chkdate >= @adate and chkdate <= dateadd(day, 1, @adate)
    and stat not in (0,7)
  open c_proc
  fetch next from c_proc into @num
  while @@fetch_status = 0 begin
     select @costamt1 = RAWCOST, @costamt2 = PDTCOST, @diffamt = (PDTCOST - RAWCOST)
            from Process where num = @num

     select @tdiff1 = 0   
     declare c_diff1 cursor for
       select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, WRH
       from procdtl where NUM = @num and RAW = 1 order by line desc
     open c_diff1
     fetch next from c_diff1 into
       @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh
     while @@fetch_status = 0 begin
       if @d_line = 1
          select @diff = @diffamt - @tdiff1
       else 
       begin
         select @diff = @d_total / @costamt1 *@diffamt
         select @tdiff1 = @tdiff1 + @diff
       end

      if not exists (select 1 from rPROCDRPT where astore = @astore and asettleno = @asettleno and adate = @adate
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
       insert into rPROCDRPT
          values(@astore, @asettleno, @adate, @d_wrh, @d_gdgid, -@d_qty, -@d_total, -@d_inprc * @d_qty, -@d_rtlprc * @d_qty, -@diff)
      else
         update rPROCDRPT set dq1 = dq1 -@d_qty, dt1 = dt1 - @d_total, di1 = di1 - @d_inprc * @d_qty,
                                dr1 = dr1 - @d_rtlprc * @d_qty, dd1 = dd1 - @diff
            where astore = @astore and asettleno = @asettleno and adate = @adate
                  and bwrh = @d_wrh and bgdgid = @d_gdgid

       fetch next from c_diff1 into
         @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh
     end
     close c_diff1
     deallocate c_diff1

     select @tdiff2 = 0   
     declare c_diff2 cursor for
       select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, WRH
       from procdtl where NUM = @num and RAW = 0 order by line desc
     open c_diff2
     fetch next from c_diff2 into
       @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh
     while @@fetch_status = 0 begin
       if @d_line = 1
          select @diff = @diffamt - @tdiff2
       else 
       begin
         select @diff = @d_total / @costamt2 *@diffamt
         select @tdiff2 = @tdiff2 + @diff
       end

      if not exists (select 1 from rPROCDRPT where astore = @astore and asettleno = @asettleno and adate = @adate
                     and bwrh = @d_wrh and bgdgid = @d_gdgid)
       insert into rPROCDRPT
          values(@astore, @asettleno, @adate, @d_wrh, @d_gdgid, @d_qty, @d_total, @d_inprc * @d_qty, @d_rtlprc * @d_qty, @diff)
      else
         update rPROCDRPT set dq1 = dq1 + @d_qty, dt1 = dt1 + @d_total, di1 = di1 + @d_inprc * @d_qty,
                                dr1 = dr1 + @d_rtlprc * @d_qty, dd1 = dd1 + @diff
            where astore = @astore and asettleno = @asettleno and adate = @adate
                  and bwrh = @d_wrh and bgdgid = @d_gdgid    

       fetch next from c_diff2 into
         @d_line, @d_gdgid, @d_qty, @d_total, @d_inprc, @d_rtlprc, @d_wrh
     end
     close c_diff2
     deallocate c_diff2

    fetch next from c_proc into @num
  end
  close c_proc
  deallocate c_proc

end
GO
