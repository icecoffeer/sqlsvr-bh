SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCCHK](
  @num char(10),
  @costmode int ,  --0 = 核算价；1 = 合同进价； 2 = 最低售价
  @p_errmsg varchar(255) = '' output
) with encryption as
begin
  declare
    @return_status int,
    @cur_date datetime,
    @cur_settleno int,
    @curtime datetime,
    @m_wrh int,
    @m_checker int,
    @m_stat smallint,
    @m_rawcost money,
    @m_pdtcost money,
    @m_payflag smallint,
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
    @d_sale smallint,
    @gdinprc money,

    @p_gdgid int,
    @p_billto int,
    @p_qty money,
    @p_inprc money,
    @p_rtlprc money,
    @adjnum char(10),
    @line smallint,
    @usergid int,
    @npqty money,
    @nptl money,
    @npstl money,
    @d_cost money,    
    --2005.01.01
    @d_sumrawamt money,
    @d_currawamt money,
    @d_sumproductqty money,
    @d_sumproductrtlamt money,
    @d_sumproductcntamt money,
    @d_sumapp money,
    @d_dltcnt int
  select @d_sumrawamt = 0, @d_currawamt = 0, @d_sumproductqty = 0, @d_sumproductrtlamt = 0,@d_sumproductcntamt = 0

  select
    @cur_date = convert(datetime,convert(char,getdate(),102)),
    @m_stat = STAT,
    @m_checker = CHECKER
    from PROCESS where NUM = @num

  if @m_stat not in (0,7) begin
    raiserror('被审核的不是未审核或已预审的单据', 16, 1)
    return(1)
  end

  select @cur_settleno = max(NO) from MONTHSETTLE
  select @usergid = usergid from system  /*2001-10-09*/
  --2005.01.01 Fanduoyi
  select @d_SumProductQty = sum(dtl.qty), @d_SumProductRtlAmt = sum(dtl.qty * gd.rtlprc), @d_sumproductrtlamt = sum(dtl.qty * gd.CNTINPRC)
    from procdtl dtl, goods gd(nolock)
    where gd.gid = dtl.gdgid and raw = 0 and dtl.num = @num

  update PROCESS set STAT = 1, CHKDATE = getdate(), SETTLENO = @cur_settleno
         where NUM = @num

  select @return_status = 0
  select @d_dltcnt = count(1) from procdtl where NUM = @num and raw = 0
  select @d_sumapp = 0
   
  declare c_proc cursor for
    select GDGID, RAW, QTY, INPRC, RTLPRC, WRH
    from procdtl where NUM = @num order by raw desc, line --2005.01.01 desc 必须先处理原料得到原料成本合计
    for update
  open c_proc
  fetch next from c_proc into
    @d_gdgid, @d_raw, @d_qty, @d_inprc, @d_rtlprc, @d_wrh
  while @@fetch_status = 0 
  begin
    -- update detail set inprc, rtlprc to current values *
    select @d_inprc = INPRC, @d_rtlprc = RTLPRC, @d_cntinprc = CNTINPRC, @d_lwtrtlprc = LWTRTLPRC,
           @d_sale = SALE
      from GOODSH where GID = @d_gdgid
    
    if @d_raw = 1 and @d_sale = 2
    begin 
        select @curtime = getdate()
        execute @return_status=GetGoodsPrmInprc @usergid, @d_gdgid, @curtime, @d_qty, @d_inprc output
        if @return_status <> 0
            select @d_inprc = INPRC from GOODSH where GID = @d_gdgid
    end
    --2005.01.04 Fanduoyi
    
    set @d_currawamt = 0
    -- inventory
    if @d_raw = 1
      execute @return_status = UNLOAD
        @d_wrh, @d_gdgid, @d_qty, @d_rtlprc, null
    else
      execute @return_status = LOADIN
        @d_wrh, @d_gdgid, @d_qty, @d_rtlprc, null

    if @return_status <> 0 
    begin
      raiserror('对库存进行操作失败', 16, 1)
      return(1)
    end 
    
    --取得原料成本
    if @d_raw = 1
    begin
      execute UPDINVPRC '销售', @d_gdgid, @d_qty, @d_total, @d_wrh, @d_cost output    
             
      if @d_sale = 1
      begin
      	update PROCDTL set TOTAL = @d_cost, CSTPRC = ROUND(@d_cost/@d_qty, 2)  --2002-06-13
        	where current of c_proc                     
        set @d_sumrawamt = @d_sumrawamt + @d_cost
      end
      else
        set @d_sumrawamt = @d_sumrawamt + @d_inprc * @d_qty
    end else 
    begin
        if @costmode = 3 and @d_sumproductqty <> 0
            set @d_currawamt = @d_sumrawamt / @d_SumProductQty
        else if @costmode = 4 and @d_sumproductrtlamt <> 0
            set @d_currawamt = @d_sumrawamt * (@d_rtlprc / @d_SumProductRtlAmt)
        else if @costmode = 5 and @d_sumproductcntamt <> 0
        	set @d_currawamt = @d_sumrawamt * @d_qty * @d_cntinprc / @d_sumproductcntamt
        if @d_dltcnt = 1
           select @d_currawamt = @d_sumrawamt - @d_sumapp
        ELSE
        begin
          select @d_sumapp = @d_sumapp + @d_currawamt
          select @d_dltcnt = @d_dltcnt - 1
        end
    end
    select @d_cstprc = (case @d_raw 
                            when 1 then @d_inprc 
                            when 0 then 
                                (case @costmode 
                                    when 0 then @d_inprc 
                                    when 1 then @d_cntinprc 
                                    when 2 then @d_lwtrtlprc 
                                    when 3 then @d_currawamt/@d_qty
                                    when 4 then @d_currawamt/@d_qty
                                    when 5 then @d_currawamt/@d_qty
                                 end)
                        end)
    update procdtl set INPRC = @d_inprc, RTLPRC = @d_rtlprc, 
                          CSTPRC = @d_cstprc
   where current of c_proc

  if @d_raw = 0
    begin
      select @d_total = @d_currawamt
      update procdtl set Total = @d_currawamt
        where current of c_proc

       execute UPDINVPRC '进货', @d_gdgid, @d_qty, @d_total, @d_wrh
    end
    else
    BEGIN
      select @d_total = round(@d_inprc * @d_qty, 2)
      update procdtl set Total = @d_total
         where current of c_proc
    end

    --成本差异
    if @d_raw = 1 and @d_sale = 2  and (select outinprcmode from system) <> 1
    begin
      select @gdinprc = inprc from goodsh where gid = @d_gdgid
      if @d_inprc <> @gdinprc
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
        values (@cur_settleno, @cur_date, @d_gdgid, @d_wrh,
        (@d_inprc-@gdinprc) * @d_qty)
      if @return_status <> 0 
      begin
        raiserror('计算成本差异错误', 16, 1)
        return(1)
      end 
    end

    fetch next from c_proc into
      @d_gdgid, @d_raw, @d_qty, @d_inprc, @d_rtlprc, @d_wrh
  end
  close c_proc
  deallocate c_proc

  --Report
  update Process set RAWCOST = (select sum(total) from ProcDtl where num = @num and raw = 1),
                     PDTCOST = (select sum(total) from ProcDtl where num = @num and raw = 0)
    where num = @num

  execute @return_status = PROCDIFF
      @num, 0

   if @return_status <> 0 
   begin
        raiserror('产品加工报表处理错误', 16, 1)
        return(1)
   end 

  execute @return_status = PROCDIFF
      @num, 1

   if @return_status <> 0 
   begin
        raiserror('原料加工报表处理错误', 16, 1)
        return(1)
   end   

    declare c_procvdr cursor for
      select distinct g.BILLTO
      from PROCDTL d,GOODSH g where NUM = @num and d.gdgid=g.gid and g.sale in (2,3)
      order by BILLTO
    open c_procvdr
    fetch next from c_procvdr into @p_billto
    while @@fetch_status = 0 begin
      select @adjnum = max(num) from PayAdj
      if @adjnum is null select @adjnum = '0000000001'
         else execute nextbn @adjnum, @adjnum output
      insert into PayAdj
         values(@adjnum, @cur_settleno, @cur_date, @m_checker, @m_checker, 1, @p_billto, 0, '由加工单'+@num+'产生', null)

      select @line = 1
      declare c_procpay cursor for
        select GDGID, d.INPRC, g.RTLPRC, sum(QTY)
        from PROCDTL d, GOODSH g where NUM = @num and d.gdgid=g.gid and g.sale in (2,3) and g.billto=@p_billto
        group by GDGID, d.INPRC, g.RTLPRC
      open c_procpay
      fetch next from c_procpay into @p_gdgid, @p_inprc, @p_rtlprc, @p_qty
      while @@fetch_status = 0 begin
         select @npqty = isnull(sum(v.NPQTY),0), @nptl = isnull(sum(v.NPTL),0), @npstl = isnull(sum(v.NPSTL),0)
             from v_vdryrpt v, goodsh g
             where g.gid *= v.bgdgid and g.gid = @p_gdgid 
             and v.bvdrgid = @p_billto and v.astore = @usergid

        insert into PayAdjDtl
           values(@adjnum, @line, @cur_settleno, @p_gdgid, @NPQTY, @NPTL, @NPSTL, 
                  @p_qty, @p_qty*@p_inprc, 0, @p_inprc, @p_rtlprc)

        select @line = @line + 1 

        fetch next from c_procpay into @p_gdgid, @p_inprc, @p_rtlprc, @p_qty
      end
      close c_procpay
      deallocate c_procpay

      exec PAYADJCHK @adjnum
      if @@error <> 0 begin
        raiserror('审核结算调整单失败', 16, 1)
        return(1)
      end

      fetch next from c_procvdr into @p_billto
    end
    close c_procvdr
    deallocate c_procvdr

  return(@return_status)
end
GO
