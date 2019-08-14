SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_CHKTO110]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vOperCode varchar(10),@vOperName varchar(10),@vOperGid int,@vStat int,@cursettleno int, @usergid int, @m_checker int,
    @vRet int, @new_num varchar(14)

  select @vStat = Stat from ProcExec(nolock) where Num = @Num

  if @@RowCount = 0
  begin
    Set @Msg = '取加工入库单(' + Convert(varchar(14), @Num) + ')失败！'
    return(1)
  end

  if @vStat = 0
  begin
    Set @Msg = '此单据为未审核单据，请先审核！'
    return(1)
  end

  if @vStat = 110
  begin
    Set @Msg = '此单据已被其他人作废！'
    return(1)
  end

  --更新单据信息
  select @vOperName = Substring(@Oper, 1, Charindex('[', @Oper) - 1)
  select @vOperCode = Substring(@Oper, Charindex('[', @Oper) + 1, Len(@Oper) - Charindex('[', @Oper) - 1)
  select @vOperGid = Gid from Employee(nolock) where Code = @vOperCode and Name = @vOperName
  select @m_checker = @vOperGid

  select @usergid = usergid from system(nolock)
  exec GenNextBillNumEx '', 'PROCEXEC', @new_num output
  update ProcExec set STAT = 110, Modifier = @Oper, LstUpdTime = getdate() where NUM = @Num

  select @cursettleno = max(NO) from MONTHSETTLE(nolock)


  insert into ProcExec(Num, Bocls, TaskNum, Stat, BgnTime, EndTime, Filler, FilDate,
    ChkTime, ChkEmp, Subject, Modifier, LstUpdTime, Note, Algavgtag, SettleNo, Src, Mode)
    select @new_num, Bocls, TaskNum, 120, BgnTime, EndTime, @Oper, getdate(),
    getdate(), @Oper, Subject, @Oper, getdate(), Note, Algavgtag, @cursettleno, Src, Mode from ProcExec(nolock) where Num = @Num


  insert into ProcExecRaw(Num, Line, PscpCode, GdGid, Qty, Total, Cstprc, Invprc, Rtlprc, Wrh, PscpGid)
    select @new_num, Line, PscpCode, GdGid, -Qty, -Total, Cstprc, Invprc, Rtlprc, Wrh, PscpGid from ProcExecRaw(nolock) where Num = @Num
  insert into ProcExecProd(Num, Line, PscpCode, GdGid, Qty, Total, Cstprc, Inprc, Rtlprc, Wrh, PscpGid)
    select @new_num, Line, PscpCode, GdGid, -Qty, -Total, Cstprc, Inprc, Rtlprc, Wrh, PscpGid from ProcExecProd(nolock) where Num = @Num

  declare
    @d_gdgid int, @d_wrh int, @d_qty money, @d_cstprc money, @d_rtlprc money, @Amount money, @outcost money, @curdate datetime, @d_pscpgid int,
    @d_sale int, @d_inprc money, @outinprcmode int, @d_total money

  select @outinprcmode = outinprcmode from FASystem(nolock)
  declare c_Raw cursor for
    select GdGid, Wrh, Qty, CstPrc from ProcExecRaw d(nolock)
    where d.Num = @Num
  open c_Raw
  fetch next from c_Raw into @d_gdgid, @d_wrh, @d_qty, @d_cstprc
  while @@fetch_status = 0
  begin
    select @d_sale = Sale, @d_inprc = InPrc, @d_rtlprc = RtlPrc from Goods(nolock) where Gid = @d_gdgid
    select @Amount  = @d_qty * @d_cstprc
    exec @vRet = UPDINVPRC '进货', @d_gdgid, @d_qty, @Amount, @d_Wrh, @outcost output
    if @vRet <> 0
    begin
      set @Msg = '更新库存价失败.'
      close c_Raw
      deallocate c_Raw
      return(1)
    end
    set @curdate = getdate()
    exec @vRet = loadin @d_Wrh, @d_gdgid, @d_qty, @d_rtlprc, @curdate
    if @vRet <> 0
    begin
      set @Msg = '库存操作失败.'
      close c_Raw
      deallocate c_Raw
      return(1)
    end
    if (@outinprcmode <> 1) and (@d_sale = 2)
    begin
      if @d_inprc <> @d_cstprc
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
          values (@cursettleno, getdate(), @d_gdgid, @d_wrh, (@d_cstprc - @d_inprc) * @d_qty)
    end
    fetch next from c_Raw into @d_gdgid, @d_wrh, @d_qty, @d_cstprc
  end
  close c_Raw
  deallocate c_Raw

  declare
    @d_updqty money, @d_updtotal money

  declare c_Product cursor for
    select GdGid, Wrh, Qty, PscpGid, Total from ProcExecProd d(nolock)
    where d.Num = @Num
  open c_Product
  fetch next from c_Product into @d_gdgid, @d_wrh, @d_qty, @d_pscpgid, @d_total
  while @@fetch_status = 0
  begin
    select @d_updqty = 0 - @d_qty, @d_updtotal = 0 - @d_total
    exec @vRet = UPDINVPRC '进货', @d_gdgid, @d_updqty, @d_updtotal, @d_Wrh, @outcost output
    if @vRet <> 0
    begin
      set @Msg = '更新库存价失败.'
      close c_Raw
      deallocate c_Raw
      return(1)
    end
    select @d_rtlprc = RtlPrc from goods(nolock) where Gid = @d_gdgid
    exec @vRet = unload @d_Wrh, @d_gdgid, @d_qty, @d_rtlprc, null
    if @vRet <> 0
    begin
      set @Msg = '作废加工入库单失败.'
      close c_Product
      deallocate c_Product
      return(1)
    end
    update ProcExecProd set GenQty = GenQty - @d_qty where Num = @Num and GdGid = @d_gdgid and PscpGid = @d_pscpgid
    fetch next from c_Product into @d_gdgid, @d_wrh, @d_qty, @d_pscpgid, @d_total
  end
  close c_Product
  deallocate c_Product

  execute @vRet = PROCDIFFEX @new_num, 0
  if @vRet <> 0
  begin
    set @Msg = '产品加工报表处理错误'
    return(1)
  end

  execute @vRet = PROCDIFFEX @new_num, 1
  if @vRet <> 0
  begin
    set @Msg = '原料加工报表处理错误'
    return(1)
  end

  declare
    @p_billto int, @adjnum varchar(10), @p_gdgid int, @p_inprc money, @p_rtlprc money,
    @p_qty money, @npqty money, @nptl money, @npstl money, @line int

  declare c_procvdr cursor for
    select distinct g.BILLTO
    from ProcExecRaw d(nolock),GOODSH g(nolock) where NUM = @new_num and d.gdgid=g.gid and g.sale in (2,3)
    order by BILLTO
  open c_procvdr
  fetch next from c_procvdr into @p_billto
  while @@fetch_status = 0 begin
    select @adjnum = max(num) from PayAdj(nolock)
    if @adjnum is null select @adjnum = '0000000001'
       else execute nextbn @adjnum, @adjnum output
    insert into PayAdj(Num, SettleNo, FilDate, Filler, Checker, Wrh, BillTo, Stat, Note, PrnTime)
       values(@adjnum, @cursettleno, getdate(), @m_checker, @m_checker, 1, @p_billto, 0, '由加工入库单'+@new_num+'产生', null)

    select @line = 1
    declare c_procpay cursor for
      select GDGID, d.INVPRC, g.RTLPRC, sum(QTY)
      from ProcExecRaw d(nolock), GOODSH g(nolock) where NUM = @new_num and d.gdgid=g.gid and g.sale in (2,3) and g.billto=@p_billto
      group by GDGID, d.INVPRC, g.RTLPRC
    open c_procpay
    fetch next from c_procpay into @p_gdgid, @p_inprc, @p_rtlprc, @p_qty
    while @@fetch_status = 0 begin
       select @npqty = isnull(sum(v.NPQTY),0), @nptl = isnull(sum(v.NPTL),0), @npstl = isnull(sum(v.NPSTL),0)
           from v_vdryrpt v(nolock), goodsh g(nolock)
           where g.gid *= v.bgdgid and g.gid = @p_gdgid
           and v.bvdrgid = @p_billto and v.astore = @usergid

      insert into PayAdjDtl
         values(@adjnum, @line, @cursettleno, @p_gdgid, @NPQTY, @NPTL, @NPSTL,
                @p_qty, @p_qty*@p_inprc, 0, @p_inprc, @p_rtlprc)

      select @line = @line + 1

      fetch next from c_procpay into @p_gdgid, @p_inprc, @p_rtlprc, @p_qty
    end
    close c_procpay
    deallocate c_procpay

    exec PAYADJCHK @adjnum
    if @@error <> 0 begin
      set @Msg = '审核结算调整单失败'
      close c_procvdr
      deallocate c_procvdr
      return(1)
    end

    fetch next from c_procvdr into @p_billto
  end
  close c_procvdr
  deallocate c_procvdr

  exec PROCEXEC_ADD_LOG @Num, 100, 110, @Oper, ''
  return(0)
end
GO
