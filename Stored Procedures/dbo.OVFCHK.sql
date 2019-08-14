SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OVFCHK](
  @p_num varchar(10),
  @isneg int = 0,  --是否是冲单 0-否，1-是   --2003-06-13
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,      @cur_date datetime,        @cur_settleno int,
    @m_wrh int,              @m_filler int,             @m_stat smallint,
    @m_amtovf money,         @d_settleno int,           @d_gdgid int,
    @d_qtyovf money,         @d_amtovf money,           @d_inprc money,
    @d_rtlprc money,         @d_validdate datetime,     @d_subwrh int,
    @modnum char(10),        @mod_qty money,	          @d_line int,
    @g_lstinprc money,       @d_cost money,             @money1 money /*2002-06-13*/,
    @sale smallint,          @g_inprc money,            @g_rtlprc money/*2003-06-13*/,
    @tmp_qty money/*2003-07-09*/
  select
    @cur_date = convert(datetime,convert(char,getdate(),102)),
    @cur_settleno = SETTLENO,
    @m_wrh = WRH,
    @m_stat = STAT,
    @m_amtovf = AMTOVF,
    @modnum = MODNUM
    from OVF where NUM = @p_num
  if @m_stat <> 0 begin
    raiserror('被审核的不是未审核的单据', 16, 1)
    return(1)
  end

 --ShenMin
  declare
    @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'OVF', @piCls = '', @piNum = @p_num, @piToStat = 2, @piOper = @Oper, @piWrh = @m_wrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return -1
    end

  select @cur_settleno = max(NO) from MONTHSETTLE
  update OVF set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno
  where NUM = @p_num
  select @return_status = 0
  declare c_ovfdtl cursor for
    select GDGID, QTYOVF, AMTOVF, INPRC, RTLPRC, VALIDDATE, SUBWRH, LINE, COST
    from OVFDTL where NUM = @p_num
    for update
  open c_ovfdtl
  fetch next from c_ovfdtl into
    @d_gdgid, @d_qtyovf, @d_amtovf, @d_inprc, @d_rtlprc, @d_validdate, @d_subwrh,
    @d_line, @d_cost
  while @@fetch_status = 0 begin

    /* set details inprc, rtlprc to current values */
    select @g_rtlprc = RTLPRC, @g_inprc = INPRC, @g_lstinprc = LSTINPRC, @sale = SALE/*2003-06-13*/
      from GOODSH where GID = @d_gdgid

    /* 00-3-25 */
    if (select batchflag from system) = 1
      select @g_inprc = /* 2000-06-26 0*/@g_lstinprc

    if @isneg = 0
    update OVFDTL set INPRC = @g_inprc, RTLPRC = @g_rtlprc
      where NUM = @p_num and LINE = @d_line
    /* inventory */
    /*
    if @d_qtyovf > 0
      execute @return_status = LOADIN
        @m_wrh, @d_gdgid, @d_qtyovf, @d_rtlprc, @d_validdate,0
    else
      execute @return_status = UNLOAD
        @m_wrh, @d_gdgid, @d_qtyovf, @d_rtlprc, @d_validdate
    */
    --2002-06-13
    if @isneg = 0
    begin
       select @money1 = @d_qtyovf * @g_inprc
       execute UPDINVPRC '销售退货', @d_gdgid, @d_qtyovf, @money1, @m_wrh, @d_cost output /*2002.08.18*/

       if @sale = 1
          update OVFDTL set COST = @d_cost
              where NUM = @p_num and LINE = @d_line
       else --2004-08-12
          update OVFDTL set COST = @money1
              where NUM = @p_num and LINE = @d_line
    end
    else
    begin
       select @money1 = @d_cost
       execute UPDINVPRC '进货', @d_gdgid, @d_qtyovf, @money1, @m_wrh /*2004-08-25*/
    end


    if @isneg = 0
      execute @return_status = LOADIN
        @m_wrh, @d_gdgid, @d_qtyovf, @d_rtlprc, @d_validdate,0
    else
    begin  /*2003-07-09*/
      select @tmp_qty = -1 * @d_qtyovf
      execute @return_status = UNLOAD
        @m_wrh, @d_gdgid, @tmp_qty, @g_rtlprc, @d_validdate,0
    end
    if @return_status <> 0 break

    /* 2000-3-25 增加了system.batchflag=1时的处理,
    ref 用货位实现批次管理(二).doc */
    if (select batchflag from system) = 1
    begin
      if @d_subwrh is null
      begin
        if @d_qtyovf >= 0
        begin
          execute @return_status =
                  GetSubWrhBatch @m_wrh, @d_subwrh output, @errmsg output
          if @return_status <> 0 break
          update OVFDTL set SUBWRH = @d_subwrh where NUM = @p_num and LINE = @d_line
        end
        else /* @d_qtyovf < 0 */
        begin
          select @errmsg = '负数进货必须指定货位'
          select @return_status = 1018
          break
        end
      end
      else /* @subwrh is not null */
      begin
        if @d_qtyovf < 0
        begin
          select @mod_qty = null
          select @mod_qty = qtyovf from ovfdtl
            where num = @modnum and subwrh = @d_subwrh
          if @mod_qty is null
          begin
            select @errmsg = '找不到对应的溢余单'
            select @return_status = 1019
            raiserror(@errmsg, 16, 1)
            break
          end
          if @mod_qty <> @d_qtyovf
          begin
            select @errmsg = '数量和对应的溢余单('+@modnum+')上的不符合'
            select @return_status = 1020
            raiserror(@errmsg, 16, 1)
            break
          end
        end
      end
    end

    if @d_subwrh is not null
    begin
      /*
      if @d_qtyovf > 0
        execute @return_status = LOADINSUBWRH
          @m_wrh, @d_subwrh, @d_gdgid, @d_qtyovf, @d_inprc
      else
        execute @return_status = UNLOADSUBWRH
          @m_wrh, @d_subwrh, @d_gdgid, @d_qtyovf
      */

      if @isneg = 0
        execute @return_status = LOADINSUBWRH
          @m_wrh, @d_subwrh, @d_gdgid, @d_qtyovf, @g_inprc
      else  /*2003-07-09*/
  	execute @return_status = UNLOADSUBWRH
	  @m_wrh, @d_subwrh, @d_gdgid, @tmp_qty

      if @return_status <> 0 break
    end

    /* reports */
    if @sale = 1/*2003-06-13*/
    begin
      if @isneg = 0
      begin
        execute @return_status = OVFDTLCHK
          @cur_date, @cur_settleno, @m_wrh, @d_gdgid, @d_qtyovf,
          @d_amtovf, @g_inprc, @g_rtlprc, @d_cost /*2002-06-13*/
        if @return_status <> 0 break
      end
      else
      begin
        execute @return_status = OVFDTLCHK
          @cur_date, @cur_settleno, @m_wrh, @d_gdgid, @d_qtyovf,
          @d_amtovf, @d_inprc, @d_rtlprc, @d_cost /*2002-06-13*/
        if @return_status <> 0 break

        if @d_rtlprc <> @g_rtlprc
           begin
                 insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                     values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
                     0, (@g_rtlprc-@d_rtlprc) * @d_qtyovf)
           end
      end
    end
    else
    begin
      if @isneg = 0
      begin
        execute @return_status = OVFDTLCHK
          @cur_date, @cur_settleno, @m_wrh, @d_gdgid, @d_qtyovf,
          @d_amtovf, @g_inprc, @g_rtlprc
        if @return_status <> 0 break
      end
      else begin
        execute @return_status = OVFDTLCHK
          @cur_date, @cur_settleno, @m_wrh, @d_gdgid, @d_qtyovf,
          @d_amtovf, @d_inprc, @d_rtlprc

        if @d_inprc <> @g_inprc or @d_rtlprc <> @g_rtlprc
           begin
                 insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                     values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
                     (@g_inprc-@d_inprc) * @d_qtyovf, (@g_rtlprc-@d_rtlprc) * @d_qtyovf)
           end
      end
    end

    fetch next from c_ovfdtl into
      @d_gdgid, @d_qtyovf, @d_amtovf, @d_inprc,@d_rtlprc,@d_validdate, @d_subwrh, @d_line, @d_cost
  end
  close c_ovfdtl
  deallocate c_ovfdtl
  return(@return_status)
end
GO
