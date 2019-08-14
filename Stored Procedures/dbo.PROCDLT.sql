SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCDLT](
  @old_num char(10),
  @new_oper int,
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,
    @cur_date datetime,
    @cur_settleno int,
    @old_settleno int,
    @old_pscpgid int,
    @old_multiple int,
    @old_fildate datetime,
    @old_filler int,
    @old_chkdate datetime,
    @old_checker int,
    @old_stat smallint,
    @old_modnum char(10),
    @old_rawcost money,
    @old_pdtcost money,
    @old_rawreccnt int,
    @old_pdtreccnt int,
    @old_note varchar(100),
    @old_prntime datetime,
    @d_sale smallint,
    @olddtl_gdgid int,
    @olddtl_qty money,
    @olddtl_total money,
    @olddtl_raw smallint,
    @olddtl_inprc money,
    @olddtl_rtlprc money,
    @olddtl_wrh int,
    @cur_inprc money,
    @cur_rtlprc money,
    @new_num char(10),
    @max_num char(10),
    @conflict smallint,
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
    @qty money,
    @total money,
    @d_cost money    
        
  select
    @old_settleno = SETTLENO,
    @old_pscpgid = PSCPGID,
    @old_multiple = MULTIPLE,
    @old_fildate = FILDATE,
    @old_filler = FILLER,
    @old_chkdate = CHKDATE,
    @old_checker = CHECKER,
    @old_stat = STAT,
    @old_modnum = MODNUM,
    @old_rawcost = RAWCOST,
    @old_pdtcost = PDTCOST,
    @old_rawreccnt = RAWRECCNT,
    @old_pdtreccnt = PDTRECCNT,
    @old_note = NOTE,
    @old_prntime = PRNTIME
    from PROCESS where NUM = @old_num

  if @old_stat <> 1 begin
    raiserror('被删除的不是已审核过的单据', 16, 1)
    return(1)
  end

  select @usergid = usergid from system 
  /* find the @neg_num */
  select @conflict = 1, @max_num = @old_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @new_num output
    if exists (select * from PROCESS where NUM = @new_num)
      select @max_num = @new_num, @conflict = 1
    else
      select @conflict = 0
  end

  update PROCESS set STAT = 2 where NUM = @old_num
  select @cur_date = convert(datetime,convert(char,getdate(),102))
  select @cur_settleno = max(NO) from MONTHSETTLE

  insert into PROCESS (NUM, PSCPGID, SETTLENO, FILDATE, FILLER, STAT, CHKDATE, CHECKER, PRNTIME, PRECHKDATE, PRECHECKER, 
                       MULTIPLE, RAWCOST, PDTCOST, RAWRECCNT, PDTRECCNT, MODNUM, NOTE)
   values (@new_num, @old_pscpgid, @cur_settleno, getdate(), @new_oper, 3, getdate(), @new_oper,  @old_prntime, getdate(), @new_oper,  
           @old_multiple, -@old_rawcost, -@old_pdtcost, @old_rawreccnt, @old_pdtreccnt, @old_num, @old_note)

  insert into PROCDTL (NUM, RAW, LINE, --SETTLENO,
    GDGID, QTY, TOTAL, CSTPRC, INPRC, RTLPRC, WRH)
    select @new_num, RAW, LINE, --@cur_settleno,
    GDGID, -QTY, -TOTAL, CSTPRC, INPRC, RTLPRC, PROCDTL.WRH
    from PROCDTL
    where NUM = @old_num

  select @return_status = 0
  declare c_procdtl cursor for
    select RAW, GDGID, QTY, TOTAL, INPRC, RTLPRC, WRH
    from PROCDTL where NUM = @old_num
  open c_procdtl
  fetch next from c_procdtl into
    @olddtl_raw, @olddtl_gdgid, @olddtl_qty, @olddtl_total,
    @olddtl_inprc, @olddtl_rtlprc, @olddtl_wrh
  while @@fetch_status = 0 begin
    select
      @cur_inprc = INPRC,
      @cur_rtlprc = RTLPRC,
      @d_sale = sale
      from GOODSH where GID = @olddtl_gdgid

    if @olddtl_raw = 0
    begin
      select @qty = -@olddtl_qty, @total = -@olddtl_total
      execute UPDINVPRC '进货', @olddtl_gdgid, @qty, @total, @olddtl_wrh
    end
    else
    begin
--            execute UPDINVPRC '销售退货', @olddtl_gdgid, @olddtl_qty, @olddtl_total, @olddtl_wrh, @d_cost output                 
      select @qty = -@olddtl_qty, @total = -@olddtl_total
      execute UPDINVPRC '进货', @olddtl_gdgid, @qty, @total, @olddtl_wrh        --2004-08-25
    end    

    if @olddtl_raw = 1
      execute @return_status = LOADIN
        @olddtl_wrh, @olddtl_gdgid, @olddtl_qty,
        @cur_rtlprc, null
    else
      execute @return_status = UNLOAD
        @olddtl_wrh, @olddtl_gdgid, @olddtl_qty,
        @cur_rtlprc, null

    if @return_status <> 0 
    begin
      raiserror('对库存进行操作失败', 16, 1)
      return(1)
    end 

    if (@olddtl_raw = 1 and @d_sale = 2)
    begin
       if @olddtl_inprc <> @cur_inprc or @olddtl_rtlprc <> @cur_rtlprc
       begin
         insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
           values (@cur_settleno, @cur_date, @olddtl_gdgid, @olddtl_wrh,
           (@cur_inprc-@olddtl_inprc) * @olddtl_qty, (@cur_rtlprc-@olddtl_rtlprc) * @olddtl_qty)
       end
    end

    if @return_status <> 0 
    begin
      raiserror('生成调价差异失败', 16, 1)
      return(1)
    end 

    fetch next from c_procdtl into
      @olddtl_raw, @olddtl_gdgid, @olddtl_qty, @olddtl_total,
      @olddtl_inprc, @olddtl_rtlprc, @olddtl_wrh
  end
  close c_procdtl
  deallocate c_procdtl

  execute @return_status = PROCDIFF
      @new_num, 0

   if @return_status <> 0 
   begin
        raiserror('产品加工报表处理错误', 16, 1)
        return(1)
   end 

  execute @return_status = PROCDIFF
      @new_num, 1

   if @return_status <> 0 
   begin
        raiserror('原料加工报表处理错误', 16, 1)
        return(1)
   end   

    declare c_procvdr cursor for
      select distinct g.BILLTO
      from PROCDTL d,GOODSH g where NUM = @new_num and d.gdgid=g.gid and g.sale in (2,3) and raw = 1
      order by BILLTO
    open c_procvdr
    fetch next from c_procvdr into @p_billto
    while @@fetch_status = 0 begin
      select @adjnum = max(num) from PayAdj
      if @adjnum is null select @adjnum = '0000000001'
         else execute nextbn @adjnum, @adjnum output
      insert into PayAdj
         values(@adjnum, @cur_settleno, @cur_date, @new_oper, @new_oper, 1, @p_billto, 0, '由加工单'+@new_num+'产生', null)

      select @line = 1
      declare c_procpay cursor for
        select GDGID, d.INPRC, g.RTLPRC, sum(QTY)
        from PROCDTL d, GOODSH g where NUM = @new_num and d.gdgid=g.gid and g.sale in (2,3) and g.billto=@p_billto
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
