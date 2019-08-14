SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LSUPD](
  @new_num char(10),
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @ma varchar(100),        @return_status int,        @cur_date datetime,
    @cur_settleno int,       @new_wrh_chkvd smallint,   @old_wrh_chkvd smallint,
    @g_chkvd smallint,       @g_rtlprc money,           @g_inprc money,
    @qty money,              @amt money,
    @new_settleno int,       @new_wrh int,              @new_fildate datetime,
    @new_filler int,         @new_checker int,          @new_stat smallint,
    @new_amtls money,        @new_reccnt int,           @new_modnum char(10),
    @new_note varchar(100),  @newdtl_gdgid int ,        @newdtl_qtyls money,
    @newdtl_amtls money,     @newdtl_inprc money,       @newdtl_rtlprc money,
    @newdtl_validdate datetime,                         @newdtl_subwrh int,
    @newdtl_cost money,      @newdtl_line smallint,/*2002-06-13*/

    @max_num char(10),       @neg_num char(10),

    @old_num char(10),       @old_settleno int,         @old_wrh int,
    @old_fildate datetime,   @old_filler int,           @old_checker int,
    @old_stat smallint,      @old_amtls money,          @old_reccnt int,
    @old_modnum char(10),    @old_note varchar(100),    @olddtl_gdgid int ,
    @olddtl_qtyls money,     @olddtl_amtls money,       @olddtl_inprc money,
    @olddtl_rtlprc money,    @olddtl_validdate datetime,@olddtl_subwrh int,
    @olddtl_cost money, /*2002-06-13*/
    @conflict smallint,      @old_cause varchar(40),    @sale smallint/*2003-06-13*/

  select
    @cur_date = convert(datetime, convert(char,FILDATE,102)),
    @cur_settleno = SETTLENO,
    @new_wrh = WRH,
    @new_fildate = FILDATE,
    @new_checker = CHECKER,
    @new_stat = STAT,
    @old_num = MODNUM
    from LS where NUM = @new_num
  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据', 16, 1)
    return(1)
  end

 --ShenMin
  declare
    @Oper char(30),
    @msg varchar(255)
  set @Oper = Convert(Char(1), @ChkFlag)
  select @old_num = MODNUM from LS where NUM = @new_num
  exec @return_status = WMSFILTER 'LS', @piCls = '', @piNum = @old_num, @piToStat = 2, @piOper = @Oper,@piWrh = @new_wrh, @piTag = 0, @piAct = null, @poMsg = @msg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@msg, 16, 1)
    	return -1
    end

  update LS set STAT = 1 where NUM = @new_num
  select
    @old_settleno = SETTLENO,
    @old_wrh = WRH,
    @old_fildate = FILDATE,
    @old_filler = FILLER,
    @old_checker = CHECKER,
    @old_stat = STAT,
    @old_modnum = MODNUM,
    @old_amtls = AMTLS,
    @old_reccnt = RECCNT,
    @old_note = NOTE,
    @old_cause = CAUSE
    from LS where NUM = @old_num
  if @old_stat <> 1 begin
    raiserror('被修改的不是已审核的单据', 16, 1)
    return(1)
  end

  /* find the @neg_num */
  select @conflict = 1, @max_num = @old_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from LS where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  update LS set STAT = 2 where NUM = @old_num
  insert into LS (NUM, SETTLENO, WRH, FILDATE, FILLER,
    CHECKER, STAT, MODNUM, AMTLS, RECCNT, NOTE, CAUSE)
  values(@neg_num, @cur_settleno, @old_wrh, @new_fildate, @new_checker,
    @new_checker, 3, @old_num, -@old_amtls, @old_reccnt, @old_note, @old_cause)
  insert into LSDTL ( NUM, LINE, SETTLENO, GDGID, QTYLS, AMTLS,
    INPRC, RTLPRC, VALIDDATE, SUBWRH, COST/*2002-06-13*/ )
    select @neg_num, LINE, @cur_settleno, GDGID, -QTYLS, -AMTLS,
    /*GOODSH.INPRC, GOODSH.RTLPRC 2003-06-13*/INPRC, RTLPRC, VALIDDATE, SUBWRH, -COST/*2002-06-13*/
    from LSDTL/*, GOODSH*/
    where LSDTL.NUM = @old_num /*and LSDTL.GDGID = GOODSH.GID*/
  select
    @new_wrh_chkvd = CHKVD from WAREHOUSE where GID = @new_wrh
  select
    @old_wrh_chkvd = CHKVD from WAREHOUSE where GID = @old_wrh
  select
    @return_status = 0
  declare c_newdtl cursor for
    select LINE, GDGID, QTYLS, AMTLS, INPRC, RTLPRC, VALIDDATE, SUBWRH
    from LSDTL where NUM = @new_num
    for update
  open c_newdtl
  fetch next from c_newdtl into @newdtl_line,
    @newdtl_gdgid, @newdtl_qtyls, @newdtl_amtls, @newdtl_inprc,
    @newdtl_rtlprc, @newdtl_validdate, @newdtl_subwrh
  while @@fetch_status = 0 begin
    select
      @g_chkvd = CHKVD,
      @g_rtlprc = RTLPRC,
      @g_inprc = INPRC,
      @sale = SALE/*2003-06-13*/
      from GOODSH where GID = @newdtl_gdgid
    select
      @olddtl_gdgid = GDGID,
      @olddtl_qtyls = QTYLS,
      @olddtl_amtls = AMTLS,
      @olddtl_inprc = INPRC,
      @olddtl_rtlprc = RTLPRC,
      @olddtl_validdate = VALIDDATE,
      @olddtl_subwrh = SUBWRH,
      @olddtl_cost = COST /*2002-06-13*/
      from LSDTL where NUM = @old_num and GDGID = @newdtl_gdgid
    if @@rowcount <> 0 begin
      --if @old_wrh <> @new_wrh or
      --  (@old_wrh_chkvd = 1 or @new_wrh_chkvd = 1) and @g_chkvd = 1
      --  and @olddtl_validdate <> @newdtl_validdate begin
        execute UPDINVPRC '进货', @olddtl_gdgid, @olddtl_qtyls, @olddtl_cost, @old_wrh /*2002-06-13 2002.08.18*/
        execute @return_status = LOADIN
          @old_wrh, @olddtl_gdgid, @olddtl_qtyls,
          @g_rtlprc, @olddtl_validdate
        if @return_status <> 0 break
        if @olddtl_subwrh is not null
        begin
          execute @return_status = LOADINSUBWRH
            @old_wrh, @olddtl_subwrh, @olddtl_gdgid, @olddtl_qtyls
          if @return_status <> 0 break
        end
        execute @return_status = UNLOAD
          @new_wrh, @newdtl_gdgid, @newdtl_qtyls,
          @g_rtlprc, @newdtl_validdate
        if @return_status <> 0 break
        if @newdtl_subwrh is not null
        begin
          execute @return_status = UNLOADSUBWRH
            @new_wrh, @newdtl_subwrh, @newdtl_gdgid, @newdtl_qtyls
          if @return_status <> 0 break
        end
        /*2002-06-13*/
        execute UPDINVPRC '销售', @newdtl_gdgid, @newdtl_qtyls, 0, @new_wrh, @newdtl_cost output /*2002.08.18*/
        if @sale = 1
            update LSDTL set COST = @newdtl_cost
                where NUM = @new_num and LINE = @newdtl_line
        else
            update LSDTL set COST = @newdtl_qtyls * @g_inprc --2004-08-12
                where NUM = @new_num and LINE = @newdtl_line

        if @sale = 1/*2003-06-13*/
        execute @return_status = LSDTLDLTCRT
          @cur_date, @cur_settleno, @old_fildate, @old_settleno,
	      @old_wrh, @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
          @olddtl_inprc, @olddtl_rtlprc, @olddtl_cost /*2002-06-13*/
        else
        execute @return_status = LSDTLDLTCRT
          @cur_date, @cur_settleno, @old_fildate, @old_settleno,
	      @old_wrh, @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
          @olddtl_inprc, @olddtl_rtlprc
        if @return_status <> 0 break

        if @olddtl_inprc <> @g_inprc or @olddtl_rtlprc <> @g_rtlprc  /*2003-06-13*/
        begin
          insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
            values (@cur_settleno, @cur_date, @olddtl_gdgid, @old_wrh,
            case @sale when 1 then 0 else (@g_inprc-@olddtl_inprc) * @olddtl_qtyls end, (@g_rtlprc-@olddtl_rtlprc) * @olddtl_qtyls)
        end

        select  @g_inprc = INPRC from GOODS where GID = @newdtl_gdgid  /*2003-06-13*/
        update LSDTL set INPRC = @g_inprc where NUM = @new_num and  GDGID = @newdtl_gdgid

        if @sale = 1/*2003-06-13*/
        execute @return_status = LSDTLCHKCRT
          @cur_date, @cur_settleno, @old_fildate, @old_settleno,
	      @new_wrh, @newdtl_gdgid, @newdtl_qtyls, @newdtl_amtls,
          @g_inprc, @g_rtlprc, @newdtl_cost  /*2003-04-15*/
        else
        execute @return_status = LSDTLCHKCRT
          @cur_date, @cur_settleno, @old_fildate, @old_settleno,
	      @new_wrh, @newdtl_gdgid, @newdtl_qtyls, @newdtl_amtls,
          @g_inprc, @g_rtlprc
        if @return_status <> 0 break
      /*end else begin
        if @olddtl_qtyls > @newdtl_qtyls begin
          select
            @qty = @olddtl_qtyls - @newdtl_qtyls,
            @amt = @olddtl_amtls - @newdtl_amtls
          execute @return_status = LOADIN
            @old_wrh, @olddtl_gdgid, @qty, @g_rtlprc, @olddtl_validdate
          if @return_status <> 0 break
          if @olddtl_subwrh is not null
          begin
            execute @return_status = LOADINSUBWRH
              @old_wrh, @olddtl_subwrh, @olddtl_gdgid, @qty
            if @return_status <> 0 break
          end
          execute @return_status = LSDTLDLTCRT
            @cur_date, @cur_settleno, @old_fildate, @old_settleno,
	        @old_wrh, @olddtl_gdgid, @qty, @amt, @g_inprc, @g_rtlprc
        end else if @olddtl_qtyls < @newdtl_qtyls begin
          select
            @qty = @newdtl_qtyls - @olddtl_qtyls,
            @amt = @newdtl_amtls - @olddtl_amtls
          execute @return_status = UNLOAD
            @old_wrh, @olddtl_gdgid, @qty, @g_rtlprc, @olddtl_validdate
          if @return_status <> 0 break
          if @olddtl_subwrh is not null
          begin
            execute @return_status = UNLOADSUBWRH
              @old_wrh, @olddtl_subwrh, @olddtl_gdgid, @qty
            if @return_status <> 0 break
          end
          execute @return_status = LSDTLCHKCRT
            @cur_date, @cur_settleno, @old_fildate, @old_settleno,
   	        @new_wrh, @newdtl_gdgid, @qty, @amt, @g_inprc, @g_rtlprc
          if @return_status <> 0 break
        end
      end*/
    end else begin
      execute @return_status = UNLOAD
        @new_wrh, @newdtl_gdgid, @newdtl_qtyls, @g_rtlprc, @newdtl_validdate
      if @return_status <> 0 break
      if @newdtl_subwrh is not null
      begin
        execute @return_status = UNLOADSUBWRH
          @new_wrh, @newdtl_subwrh, @newdtl_gdgid, @newdtl_qtyls
        if @return_status <> 0 break
      end
      /*2002-06-13*/
      execute UPDINVPRC '销售', @newdtl_gdgid, @newdtl_qtyls, 0, @new_wrh, @newdtl_cost output /*2002.08.18*/
      if @sale = 1
        update LSDTL set COST = @newdtl_cost
          where NUM = @new_num and LINE = @newdtl_line
      else
        update LSDTL set COST = @newdtl_qtyls * @g_inprc --2004-08-12
          where NUM = @new_num and LINE = @newdtl_line

      if @sale = 1/*2003-06-13*/
      execute @return_status = LSDTLCHKCRT
        @cur_date, @cur_settleno, @old_fildate, @old_settleno,
   	    @new_wrh, @newdtl_gdgid, @newdtl_qtyls, @newdtl_amtls,
        @g_inprc, @g_rtlprc, @newdtl_cost /*2002-06-13*/
      else
      execute @return_status = LSDTLCHKCRT
        @cur_date, @cur_settleno, @old_fildate, @old_settleno,
   	    @new_wrh, @newdtl_gdgid, @newdtl_qtyls, @newdtl_amtls,
        @g_inprc, @g_rtlprc
      if @return_status <> 0 break
    end
    fetch next from c_newdtl into @newdtl_line,
      @newdtl_gdgid, @newdtl_qtyls, @newdtl_amtls,
      @newdtl_inprc, @newdtl_rtlprc, @newdtl_validdate, @newdtl_subwrh
  end
  close c_newdtl
  deallocate c_newdtl
  if @return_status <> 0 return(@return_status)

  declare c_olddtl cursor for
    select GDGID, QTYLS, AMTLS, INPRC, RTLPRC, VALIDDATE, SUBWRH, COST /*2002-06-13*/
    from LSDTL where NUM = @old_num
  open c_olddtl
  fetch next from c_olddtl into
    @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
    @olddtl_inprc, @olddtl_rtlprc, @olddtl_validdate, @olddtl_subwrh,
    @olddtl_cost /*2002-06-13*/
  while @@fetch_status = 0 begin
    select
      @newdtl_gdgid = GDGID
      from LSDTL where NUM = @new_num and GDGID = @olddtl_gdgid
    if @@rowcount = 0 begin
      select
        @g_rtlprc = RTLPRC,
        @g_inprc = INPRC,
        @sale = SALE/*2003-06-13*/
        from GOODSH where GID = @olddtl_gdgid
      execute UPDINVPRC '进货', @olddtl_gdgid, @olddtl_qtyls, @olddtl_cost, @old_wrh /*2002-06-13 2002.08.18*/
      execute @return_status = LOADIN
        @old_wrh, @olddtl_gdgid, @olddtl_qtyls, @g_rtlprc, @olddtl_validdate
      if @return_status <> 0 break
      if @olddtl_subwrh is not null
      begin
        execute @return_status = LOADINSUBWRH
          @old_wrh, @olddtl_subwrh, @olddtl_gdgid, @olddtl_qtyls
        if @return_status <> 0 break
      end
      if @sale = 1/*2003-06-13*/
      execute @return_status = LSDTLDLTCRT
        @cur_date, @cur_settleno, @old_fildate, @old_settleno,
        @old_wrh, @olddtl_gdgid, @olddtl_qtyls,
        @olddtl_amtls, @olddtl_inprc, @olddtl_rtlprc, @olddtl_cost /*2003-04-15*/
      else
      execute @return_status = LSDTLDLTCRT
        @cur_date, @cur_settleno, @old_fildate, @old_settleno,
        @old_wrh, @olddtl_gdgid, @olddtl_qtyls,
        @olddtl_amtls, @olddtl_inprc, @olddtl_rtlprc
      if @return_status <> 0 break

      if @olddtl_inprc <> @g_inprc or @olddtl_rtlprc <> @g_rtlprc  /*2003-06-13*/
      begin
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
          values (@cur_settleno, @cur_date, @olddtl_gdgid, @old_wrh,
          case @sale when 1 then 0 else (@g_inprc-@olddtl_inprc) * @olddtl_qtyls end, (@g_rtlprc-@olddtl_rtlprc) * @olddtl_qtyls)
      end

    end
    fetch next from c_olddtl into
      @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
      @olddtl_inprc, @olddtl_rtlprc, @olddtl_validdate, @olddtl_subwrh,
      @olddtl_cost /*2002-06-13*/
  end
  close c_olddtl
  deallocate c_olddtl
  return (@return_status)
end
GO
