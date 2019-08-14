SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFCHK] (  
  @p_num varchar(14),  
  @err_msg varchar(100) = '' output  
) --with encryption   
as  
begin  
  declare @return_status int,    @cur_date datetime,    @cur_settleno int,  
          @store int,            @wrh int,              @stat smallint,  
          @fromstore int,        @tostore int,          @xchgstore int,  
          @fromtotal money,      @fromtax money,        @fromcost money,  
          @tototal money,        @totax money,          @tocost money,  
          @filler int,           @gdgid int,            @line smallint,  
          @qty money,            @fromprice money,      @toprice money,  
          @inprc money,          @rtlprc money,         @subwrh int,  
          @payrate money,        @taxrate money,        @sale smallint  
  declare @storeflag int,        @i_price money,        @saletax money,  
          @batchflag int,        @d_outcost money,      @money1 money/*2003-08-07*/  
  declare @mxfbalanceio int,     @sumtototal money,     @sumfromtotal money,  
          @sumtotax money,       @sumfromtax money  
  declare @MxfNotWriteRPT int,   @AllBalanceInOut int  
  declare @FromTotalAmt money,   @ToTotalAmt money, --2006.3.20, ShenMin, Q6339, 加盟店信用额度增加对门店调拨单的控制,  
          @dmdnum varchar(14),
          @opt_UseLeaguestore int, --2006.3.20, ShenMin, Q6339, 加盟店信用额度增加对门店调拨单的控制,  
          @opt_AlwSale3 int --2008.9.1, ShenMin, Q14576, 增加选项控制门店调拨单是否允许输入联销商品  
  
  exec optreadint 505,'MxfBalanceInvIO',0,@mxfbalanceio output  
  exec optreadint 505,'门店调拨单不记录交换门店报表', 0, @MxfNotWriteRPT output  
  exec optreadint 0, '开启全局进出货成本平进平出', 0, @AllBalanceInOut output  
  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output  --2006.3.20, ShenMin, Q6339, 加盟店信用额度增加对门店调拨单的控制  
  exec Optreadint 505, 'AlwSale3', 1, @opt_AlwSale3 output --ShenMin, Q14576  
  
  if @AllBalanceInOut = 1 set @mxfbalanceio = 1  
  --if @AllBalanceInOut = 2 set @mxfbalanceio = 0  
  if @mxfbalanceio = 0 and @AllBalanceInOut in (0, 2)  
    set @MxfNotWriteRPT = 0  --只有平进平出才允许不记录交换门店报表  
  
  select @return_status = 0  
  select @cur_settleno = max(NO) from MONTHSETTLE  
  select @store = USERGID, @batchflag = BATCHFLAG from system  
  select  
    @cur_date = convert(datetime, convert(char, getdate(), 102)),  
    @fromstore = FROMSTORE,  
    @tostore = TOSTORE,  
    @xchgstore = XCHGSTORE,  
    @stat = STAT,  
    @filler = FILLER,  
    @FromTotalAmt = FROMTOTAL, --2006.3.20, ShenMin, Q6339, 加盟店信用额度增加对门店调拨单的控制  
    @ToTotalAmt = TOTOTAL, --2006.3.20, ShenMin, Q6339, 加盟店信用额度增加对门店调拨单的控制  
    @dmdnum = DMDNUM --zhujieD
    from MXF where NUM = @p_num  
  
  if @store = @fromstore  
     select @storeflag = 0  
  else if @store = @xchgstore  
     select @storeflag = 1  
  else  
     select @storeflag = 2  
  
  if @stat not in (0,7) begin  
    raiserror('审核的不是未审核的单据', 16, 1)  
    return(1)  
  end  
  
 --2006.3.20, ShenMin, Q6339, 加盟店信用额度增加对门店调拨单的控制  
  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output  
  if @opt_UseLeaguestore = 1  
    begin  
      exec UPDLEAGUESTOREALCACCOUNTTOTAL @p_num, @tostore, '门店调拨单', @ToTotalAmt  
      set @FromTotalAmt = -@FromTotalAmt  
      exec UPDLEAGUESTOREALCACCOUNTTOTAL @p_num, @fromstore, '门店调拨单', @FromTotalAmt  
    end  
  
  update MXF set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno  
    where NUM = @p_num
 
  --振华定制.在调出门店记录来源供应商和配货方式 ADD BY WUDIPING 20100810
   if @storeflag = 0
    update MXFDTL set MXFDTL.fromgdvdr = isnull(g.billto, 1), MXFDTL.fromgdalc = isnull(g.alc, '直配')
     from goods g(nolock) where MXFDTL.NUM = @p_num and MXFDTL.gdgid *= g.gid
     
  --在总部调整统配商品供应商
   if @storeflag = 1
    update MXFDTL set MXFDTL.fromgdvdr = g.billto 
     from goodsh g(nolock) where MXFDTL.NUM = @p_num and MXFDTL.gdgid = g.gid 
      and MXFDTL.fromgdalc = '统配' and MXFDTL.fromgdvdr <> g.billto
  --定制结束      
  
  declare c_mxfdtl cursor for  
    select GDGID, QTY, FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST, INPRC, RTLPRC, WRH, LINE, SUBWRH  
    from MXFDTL where NUM = @p_num  
  open c_mxfdtl  
  fetch next from c_mxfdtl into  
    @gdgid, @qty, @fromprice, @fromtotal, @fromtax, @toprice, @tototal, @totax, @fromcost, @tocost, @inprc, @rtlprc, @wrh, @line, @subwrh  
  while @@fetch_status = 0 begin  
  
    select @inprc = INPRC, @rtlprc = RTLPRC, @payrate = PAYRATE, @taxrate = TAXRATE, @saletax = SALETAX, @sale = SALE  
    from GOODSH where GID = @gdgid  
  
    if @sale = 3  
    begin  
      if @opt_AlwSale3 = 0  --ShenMin, Q14576  
      begin  
        set @err_msg = '第 ' + convert(varchar(8), @line) + ' 行的商品 ' + convert(varchar  (8), @gdgid) + ' 是联销商品，不允许审核';  
        raiserror(@err_msg, 16, 1);  
        return(1)  
      end;  
      if @storeflag =0  select @inprc = @fromtotal / @qty * @payrate / 100  
      else if @storeflag =1  select @inprc = @fromtotal / @qty * @payrate / 100  
      else if @storeflag =2  select @inprc = @tototal / @qty * @payrate / 100  
    end  
  
    update MXFDTL set INPRC = @inprc, RTLPRC = @rtlprc  
      where NUM = @p_num and LINE = @line  
  
    if @batchflag = 2  
    begin  
        exec @return_status = MXFCHKFIFO @p_num, @line, @wrh, @subwrh, @gdgid ,@qty, @taxrate, @saletax, @storeflag,  
                                         @fromprice output, @fromtotal output, @fromtax output, @fromcost output,  
                                         @toprice output, @tototal output, @totax output, @tocost output  
        if @return_status <> 0 break  
  
    end  
  
    if @storeflag =0  
    begin  
      if (@subwrh is not null)  
      begin  
        execute @return_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @qty  
        if @return_status <> 0 break  
      end  
      execute @return_status = UNLOAD @wrh, @gdgid, @qty, @rtlprc, null  
      if @return_status <> 0 break  
  
      select @money1 = @qty * @inprc  
      execute UPDINVPRC '销售', @gdgid, @qty, @money1, @wrh, @d_outcost output /*2003.08.07*/  
  
      if @batchflag = 2  
         insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
            DC_Q, DC_A, DC_T, DC_I, DC_R)  
            values (@cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1, @fromstore,  
            @qty, (@fromtotal-@fromtax), @fromtax, @fromcost, @qty * @rtlprc)  
      else  
      begin  
   if @sale = 1  
   begin  
            update MXFDTL set  
              FROMCOST = isnull(@d_outcost,@qty * @inprc), --2004-08-12  
              TOTOTAL = FROMTOTAL, --2005.03.20 应该和FROMTOTAL和TOTOTAL一致  
              TOCOST = FROMTOTAL --isnull(@d_outcost,@qty * @inprc),  
            where NUM = @p_num and LINE = @line  
  
            if @mxfbalanceio = 1 and @batchflag = 0  
            begin  
              update MXFDTL set  
                FROMTOTAL = FROMCOST,  
                FROMPRICE = FROMCOST / @qty,  
                FROMTAX = FROMCOST - FROMCOST / (1.0+(@SALETAX / 100.0)),  
                TOTOTAL = FROMCOST,  
                TOCOST = FROMCOST,  
                TOTAX = FROMCOST - FROMCOST / (1.0+(@SALETAX / 100.0)),  
                TOPRICE = FROMCOST / @qty  
              where NUM = @p_num and LINE = @line  
            end  
  
            insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
               DC_Q, DC_A, DC_T, DC_I, DC_R)  
               values (@cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1, @fromstore,  
               @qty, (@fromtotal-@fromtax), @fromtax, isnull(@d_outcost,@qty * @inprc)/*2003.08.07*/, @qty * @rtlprc)  
  
            select @tocost = TOCOST, @fromcost = FROMCOST  
              from MXFDTL where NUM = @p_num and LINE = @line  
  
            update MXF set FROMCOST = FROMCOST + @fromcost,  --isnull(@d_outcost,@qty * @inprc), --2004-08-12  
                           TOCOST = TOCOST + @tocost         --2005.03.20 isnull(@d_outcost,@qty * @inprc)  
                   where NUM = @p_num  
         end  
         else  
         begin  
            insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
               DC_Q, DC_A, DC_T, DC_I, DC_R)  
               values (@cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1, @fromstore,  
               @qty, (@fromtotal-@fromtax), @fromtax, @qty * @inprc, @qty * @rtlprc)  
  
            update MXFDTL set FROMCOST = @qty * @inprc, TOCOST = @qty * @inprc --2004-08-12  
                   where NUM = @p_num and LINE = @line  
  
            update MXF set FROMCOST = FROMCOST + (@qty * @inprc), --2004-08-12  
                              TOCOST = TOCOST + (@qty * @inprc)  
                   where NUM = @p_num  
         end  
      end  
      if @return_status <> 0 break  
   end  
  
    else if @storeflag = 1
    begin
      if @MxfNotWriteRPT = 0  
      begin  
        if @batchflag = 2  
        begin  
           insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
             DC_Q, DC_A, DC_T, DC_I, DC_R)  
             values (@cur_date, @cur_settleno, @wrh, @gdgid, @tostore, 1, @xchgstore,  
             @qty, (@tototal-@totax), @totax, @tocost, @qty * @rtlprc)  
           if @return_status <> 0 break  
  
           insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,  
             DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (  
             @cur_date, @cur_settleno, @wrh, @gdgid, @fromstore, 1,  
             @qty, (@fromtotal-@fromtax), @fromtax, @fromcost, @qty * @rtlprc, 0)  
           if @return_status <> 0 break  
        end  
        else  
        begin  
           if @sale = 1  
             insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
               DC_Q, DC_A, DC_T, DC_I, DC_R)  
               values (@cur_date, @cur_settleno, @wrh, @gdgid, @tostore, 1, @xchgstore,  
               @qty, (@tototal-@totax), @totax, @fromtotal, @qty * @rtlprc)  
           else  
             insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
               DC_Q, DC_A, DC_T, DC_I, DC_R)  
               values (@cur_date, @cur_settleno, @wrh, @gdgid, @tostore, 1, @xchgstore,  
               @qty, (@tototal-@totax), @totax, @qty * @inprc, @qty * @rtlprc)  
           if @return_status <> 0 break  
  
           insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,  
             DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (  
             @cur_date, @cur_settleno, @wrh, @gdgid, @fromstore, 1,  
             @qty, (@fromtotal-@fromtax), @fromtax, @qty * @inprc, @qty * @rtlprc, 0)  
           if @return_status <> 0 break  
        end  
      end  
    end  
    else if @storeflag =2  
    begin  
      execute UPDINVPRC '进货', @gdgid, @qty, @tototal, @wrh /*2003.08.07*/  
      if @return_status <> 0 break  
  
      execute @return_status = LOADIN @wrh, @gdgid, @qty, @rtlprc, null  
      if @return_status <> 0 break  
  
      if (@subwrh is not null) and (@batchflag <> 2)  
      begin  
        if (select INPRCTAX from SYSTEM) = 1  
          select @i_price = @toprice  
        else  
          select @i_price = @toprice/(1+@taxrate/100.0)  
        execute @return_status = LOADINSUBWRH @wrh, @subwrh, @gdgid, @qty, @i_price  
        if @return_status <> 0 break  
      end  
  
      if @batchflag = 2  
         insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,  
           DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (  
           @cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1,  
           @qty, (@tototal-@totax), @totax, @tocost, @qty * @rtlprc, 0)  
      else  
         insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,  
           DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (  
           @cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1,  
           @qty, (@tototal-@totax), @totax, @qty * @inprc, @qty * @rtlprc, 0)  
  
      if @return_status <> 0 break  
    end  
  
    fetch next from c_mxfdtl into  
    @gdgid, @qty, @fromprice, @fromtotal, @fromtax, @toprice, @tototal, @totax, @fromcost, @tocost, @inprc, @rtlprc, @wrh, @line, @subwrh  
  end  
  close c_mxfdtl  
  deallocate c_mxfdtl  
  --update sum value  
  if @storeflag =0  
  begin  
    select @sumfromtotal = sum(fromtotal), @sumtototal = sum(tototal),  
      @sumfromtax = sum(fromtax), @sumtotax = sum(totax)  
      from mxfdtl where num = @p_num  
    select @fromtotal = fromtotal, @tototal = tototal,  
      @fromtax = fromtax, @totax = totax  
      from mxf where num = @p_num  
    if (@fromtotal <> @sumfromtotal) or (@tototal <> @sumtototal) or  
       (@fromtax <> @sumfromtax) or (@totax <> @sumtotax)  
    begin  
      update mxf set  
        fromtotal = @sumfromtotal, tototal = @sumtototal,  
        fromtax = @sumfromtax, totax = @sumtotax  
    where num = @p_num  
    end  
  end  
  if IsNull(@dmdnum, '') <> '' --回写申请单状态
  begin
    if (select STAT from MXFDMD(nolock) where NUM = @dmdnum) <> 400
    begin
      set @err_msg = '被导入的门店调拨申请单' + @dmdnum + '不是总部批准状态，已经有其他门店调拨单使用了它。不能审核。'
      return 1
    end
    update MXFDMD set STAT = 300, NOTE = NOTE  + ' 门店调拨单' + @p_num + '审核时回写状态为已完成。'
      where NUM = @dmdnum and STAT = 400
  end
  return(@return_status)  
end  

GO
