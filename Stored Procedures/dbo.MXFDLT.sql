SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFDLT] (
  @p_num varchar(14),
  @new_oper int,
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
          @payrate money,        @taxrate money,        @sale smallint,
          @reccnt int,           @dmdnum varchar(14)
          --,      @src int,        @modnum varchar(14),
          --@prntime datetime,   @sndtime datetime,   @note varchar(100)
  declare @storeflag int,        @i_price money,        @saletax money,
          @batchflag int,        @neg_rtlprc money,     @neg_inprc money,
          @money1 money,     @d_outcost money,    @tmp_qty money,
          @tmp_fromcost money
  declare
    @max_num varchar(14),
    @neg_num varchar(14)
  declare @old_num varchar(14)

  declare @MxfNotWriteRPT int, @AllBalanceInOut int, @mxfbalanceio int
  exec optreadint 505,'MxfBalanceInvIO',0,@mxfbalanceio output
  exec optreadint 505,'门店调拨单不记录交换门店报表', 0, @MxfNotWriteRPT output
  exec optreadint 0, '开启全局进出货成本平进平出', 0, @AllBalanceInOut output

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
    @reccnt = reccnt,
    @dmdnum = DMDNUM
    from MXF where NUM = @p_num
  set @old_num = @p_num
  /* get the @neg_num */  --modified by jinlei 修改取单号问题10位->14位
  EXEC GENNEXTBILLNUMEX NULL, 'MXF', @neg_num OUTPUT
  /*execute NEXTBN @p_num, @neg_num output
  while exists (select * from MXF where NUM = @neg_num)
  begin
    select @max_num = @neg_num
    execute NEXTBN @max_num, @neg_num output
  end*/

  execute @return_status = CanDeleteMXF @old_num, @err_msg output  -- @batchflag = 0 then continue else exit
  if @return_status != 0 begin
    raiserror(@err_msg, 16, 1)
    return(@return_status)
  end

  if @store = @fromstore
     select @storeflag = 0
  else if @store = @xchgstore
     select @storeflag = 1
  else
     select @storeflag = 2

  if @stat not in (1) begin
    set @err_msg = '审核的不是已审核的单据'
    raiserror('审核的不是已审核的单据', 16, 1)
    return(1)
  end
  update MXF set STAT = 2 where NUM = @p_num
  --create neg num
  if @storeflag = 0
  begin
    INSERT INTO MXF(NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, WRH, FILDATE,
    FILLER, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST, STAT,
    SRC, RECCNT, SNDTIME, PRNTIME, NOTE, MODNUM, DMDNUM)
    SELECT @neg_num, @cur_settleno, fromstore, tostore, xchgstore, wrh, getdate(),
    @new_oper, -fromtotal, -tototal, -fromtax, -totax, -fromcost, -tocost, 4,
    src, reccnt, SNDTIME, PRNTIME, note, @old_num, @dmdnum
    FROM MXF WHERE NUM = @old_num

    INSERT INTO MXFDTL(NUM, LINE, GDGID, WRH, QTY, FROMPRICE, FROMTOTAL,
    FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST, SUBWRH, INPRC, RTLPRC)
    SELECT @neg_num, LINE, GDGID, WRH, -QTY, -FROMPRICE, -FROMTOTAL,
    -FROMTAX, -TOPRICE, -TOTOTAL, -TOTAX, -FROMCOST, -TOCOST, SUBWRH, INPRC, RTLPRC
    FROM MXFDTL WHERE NUM = @old_num
  end
  else  --因为单据是全局唯一的所以接收时需要如下处理
  begin
      if not exists(select 1 from mxf where modnum = @p_num)
      begin
        set @err_msg = '没有找到本该存在的冲单,当前单号：['+@p_num+']'
        Raiserror(@err_msg, 16, 1)
        Return 1
      end
      select @neg_num = num from mxf where modnum = @p_num
  end

  declare c_mxfdtl cursor for
    select GDGID, QTY, FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST, INPRC, RTLPRC, WRH, LINE, SUBWRH
    from MXFDTL where NUM = @neg_num
  open c_mxfdtl
  fetch next from c_mxfdtl into
    @gdgid, @qty, @fromprice, @fromtotal, @fromtax, @toprice, @tototal, @totax, @fromcost, @tocost, @inprc, @rtlprc, @wrh, @line, @subwrh
  --------------------------
  while @@fetch_status = 0
  begin
    select @inprc = INPRC, @rtlprc = RTLPRC, @payrate = PAYRATE,
      @taxrate = TAXRATE, @saletax = SALETAX, @sale = SALE
    from GOODSH where GID = @gdgid
    select @neg_inprc = inprc, @neg_rtlprc = rtlprc from mxfdtl where num = @neg_num and line = @line
    if @sale = 3
    begin
      if @storeflag =0       select @neg_inprc = @fromtotal / @qty * @payrate / 100,     @inprc = @fromtotal / @qty * @payrate / 100
      else if @storeflag =1  select @neg_inprc = @fromtotal / @qty * @payrate / 100, @inprc = @fromtotal / @qty * @payrate / 100
      else if @storeflag =2  select @neg_inprc = @tototal / @qty * @payrate / 100,   @inprc = @tototal / @qty * @payrate / 100
    end
    --update MXFDTL set INPRC = @inprc, RTLPRC = @rtlprc
      --where NUM = @neg_num and LINE = @line
    if @batchflag = 2
    begin
      --MXFCHKFIFO
        return 1
    end
    select @tmp_qty = -@qty, @tmp_fromcost = -@fromcost
    if @storeflag =0
    begin
      execute UPDINVPRC '进货', @gdgid, @tmp_qty, @tmp_fromcost, @wrh /*2003.08.07*/
      if @return_status <> 0 break

      if (@subwrh is not null)
      begin
        execute @return_status = LOADINSUBWRH @wrh, @subwrh, @gdgid, @tmp_qty
        if @return_status <> 0 break
      end
      execute @return_status = LOADIN @wrh, @gdgid, @tmp_qty, @rtlprc, null
      if @return_status <> 0 break

      if @batchflag = 2
      begin
         --insert into db
         return 1
      end
      else
      begin
         insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
            DC_Q, DC_A, DC_T, DC_I, DC_R)
            values (@cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1, @fromstore,
            @qty, (@fromtotal-@fromtax), @fromtax, @qty * @neg_inprc, @qty * @rtlprc)
            /*冲单不变update MXFDTL set FROMCOST = @qty * @inprc, TOCOST = @qty * @inprc --2004-08-12
                   where NUM = @neg_num and LINE = @line
            update MXF set FROMCOST = FROMCOST + (@qty * @inprc), --2004-08-12
                           TOCOST = TOCOST + (@qty * @inprc)
                   where NUM = @neg_num */
      /* 生成调价差异, 库存已经按照当前售价退库了 */
      if @neg_inprc <> @inprc or @neg_rtlprc <> @rtlprc
      begin
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
          values (@cur_settleno, @cur_date, @gdgid, @wrh,
          (@inprc-@neg_inprc) * @qty, (@rtlprc-@neg_rtlprc) * @qty)
      end
      end
      if @return_status <> 0 break
    end
    else if @storeflag =1
    begin
      if @MxfNotWriteRPT = 0
      begin
        if @batchflag = 2
        begin
           --insert into DB
           return 1
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
               @qty, (@tototal-@totax), @totax, @qty * @neg_inprc, @qty * @rtlprc)
           if @return_status <> 0 break

           insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
             DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (
             @cur_date, @cur_settleno, @wrh, @gdgid, @fromstore, 1,
             @qty, (@fromtotal-@fromtax), @fromtax, @qty * @neg_inprc, @qty * @rtlprc, 0)
           if @return_status <> 0 break
        end
      end
    end
    else if @storeflag =2
    begin
      select @money1 = @qty * @inprc
      execute UPDINVPRC '进货', @gdgid, @qty, @money1, @wrh, @tototal output --3813 2005.04.11 @tmp_qty -> @qty, 销售->进货
      if @return_status <> 0 break

      execute @return_status = UNLOAD @wrh, @gdgid, @tmp_qty, @rtlprc, null
      if @return_status <> 0 break

      if (@subwrh is not null) and (@batchflag <> 2)
      begin
        if (select INPRCTAX from SYSTEM) = 1
          select @i_price = @toprice
        else
          select @i_price = @toprice/(1+@taxrate/100.0)
        execute @return_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @tmp_qty, @i_price
        if @return_status <> 0 break
      end

      if @batchflag = 2
      begin
         --insert into DB
         return 1
      end
      else
        if @sale = 1
        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
           DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (
           @cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1,
           @qty, (@tototal-@totax), @totax, isnull(@d_outcost, @qty * @neg_inprc), @qty * @rtlprc, 0)
        else
        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
           DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R, ACNT) values (
           @cur_date, @cur_settleno, @wrh, @gdgid, @xchgstore, 1,
           @qty, (@tototal-@totax), @totax, @qty * @neg_inprc, @qty * @rtlprc, 0)

        if @return_status <> 0 break
      /* 生成调价差异, 库存已经按照当前售价退库了 */
      if @neg_inprc <> @inprc or @neg_rtlprc <> @rtlprc
      begin
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
          values (@cur_settleno, @cur_date, @gdgid, @wrh,
          (@inprc-@neg_inprc) * @qty, (@rtlprc-@neg_rtlprc) * @qty)
      end
    end
    fetch next from c_mxfdtl into
    @gdgid, @qty, @fromprice, @fromtotal, @fromtax, @toprice, @tototal, @totax, @fromcost, @tocost, @inprc, @rtlprc, @wrh, @line, @subwrh
  end
  close c_mxfdtl
  deallocate c_mxfdtl
  if IsNull(@dmdnum, '') <> '' --回写申请单状态
  begin
    if (select STAT from MXFDMD(nolock) where NUM = @dmdnum) <> 300
    begin
      set @err_msg = '被导入的门店调拨申请单' + @dmdnum + '不是已完成状态，已经有其他门店调拨单使用了它。不能冲单。'
      return 1
    end
    update MXFDMD set STAT = 400, NOTE = NOTE  + ' 门店调拨单' + @p_num + '冲单时回写状态为总部已批准。'
      where NUM = @dmdnum and STAT = 300
  end
  return(@return_status)
end

GO
