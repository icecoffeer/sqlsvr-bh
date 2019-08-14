SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_CHKTO100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vOperCode varchar(10), @vOperName varchar(10), @vOperGid int, @vStat int, @vAlgavgtag varchar(255), @cursettleno int,
    @m_checker int, @usergid int, @vTaskNum varchar(14), @vRet int, @vExpectPrc money


  select @usergid = UserGid from FASystem(nolock)
  select @vStat = Stat, @vAlgavgtag = Algavgtag, @vTaskNum = TaskNum from ProcExec(nolock) where Num = @Num

  if @@RowCount = 0
  begin
    Set @Msg = '取加工入库单(' + Convert(varchar(14), @Num) + ')失败！'
    return(1)
  end

  if @vStat <> 0
  begin
    Set @Msg = '此单据不是未审核单据！'
    return(1)
  end

  --更新单据信息
  select @vOperName = Substring(@Oper, 1, Charindex('[', @Oper) - 1)
  select @vOperCode = Substring(@Oper, Charindex('[', @Oper) + 1, Len(@Oper) - Charindex('[', @Oper) - 1)
  select @vOperGid = Gid from Employee(nolock) where Code = @vOperCode and Name = @vOperName
  select @cursettleno = max(NO) from MONTHSETTLE(nolock)
  select @m_checker = @vOperGid

  declare
    @d_inprc money, @d_invprc money, @d_rtlprc money, @d_cstprc money, @d_cntinprc money, @d_lwtrtlprc money,
    @d_gdgid int, @d_wrh int, @d_qty money, @d_pscpgid int, @PscpGdGid int, @d_sumrawamt money, @PscpGdQty money, @Amount money,
    @outcost money, @Mode int, @PscpGdInvPrc money, @curdate datetime, @d_cost money, @d_sale int, @outinprcmode int, @d_gdinprc money,
    @vCount int, @vSum money, @TotalAmount money

  declare c_Raw cursor for
    select GdGid, Wrh, Qty, PscpGid from ProcExecRaw d
    where d.Num = @Num
  open c_Raw
  fetch next from c_Raw into @d_gdgid, @d_wrh, @d_qty, @d_pscpgid
  while @@fetch_status = 0
  begin
    select @d_sale = Sale, @d_inprc = InPrc, @d_rtlprc = RtlPrc from Goods(nolock) where Gid = @d_gdgid
    if @d_sale = 2
    begin
      select @curdate = getdate()
      exec @vRet = GetGoodsPrmInprc @usergid, @d_gdgid, @curdate, @d_qty, @d_inprc output
      if @vRet <> 0
        select @d_inprc = InPrc from Goods(nolock) where Gid = @d_gdgid
    end
    select @outinprcmode = outinprcmode from FASystem(nolock)
    update ProcExecRaw set CstPrc = @d_inprc, Total = @d_inprc * @d_qty  where Num = @Num and GdGid = @d_gdgid and PscpGid = @d_pscpgid
    exec @vRet = unload @d_Wrh, @d_gdgid, @d_qty, @d_rtlprc, null
    if @vRet <> 0
    begin
      set @Msg = '库存操作失败.'
      close c_Raw
      deallocate c_Raw
      return(1)
    end
    execute @vRet = UPDINVPRC '销售', @d_gdgid, @d_qty, 0, @d_wrh, @d_cost output
    if @vRet <> 0
    begin
      set @Msg = '更新库存价失败.'
      close c_Raw
      deallocate c_Raw
      return(1)
    end
    if @d_sale = 1
      update ProcExecRaw set CstPrc = Round(@d_cost/@d_qty, 2), Total = @d_cost where Num = @Num and GdGid = @d_gdgid and PscpGid = @d_pscpgid
      update ProcTaskRaw set GenQty = IsNull(GenQty, 0) + @d_qty where (Num = @vTaskNum) and (PscpGid = @d_pscpgid) and (GdGid = @d_gdgid)

    --计算成本差异
    if @d_sale = 2 and @outinprcmode <> 1
    begin
      select @d_gdinprc = InPrc from Goods(nolock) where Gid = @d_gdgid
      if @d_inprc <> @d_gdinprc
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
          values (@cursettleno, getdate(), @d_gdgid, @d_wrh, (@d_inprc - @d_gdinprc) * @d_qty)
    end
    fetch next from c_Raw into @d_gdgid, @d_wrh, @d_qty, @d_pscpgid
  end
  close c_Raw
  deallocate c_Raw

  select @vCount = 0
  declare c_Product cursor for
    select GdGid, Wrh, PscpGid, Qty from ProcExecProd d
    where d.Num = @Num order by PscpGid for update
  open c_Product
  fetch next from c_Product into @d_gdgid, @d_wrh, @d_pscpgid, @d_qty
  while @@fetch_status = 0
  begin
    if (@vAlgavgtag = '配方原料总成本/配方产品系数') or (@vAlgavgtag = '预期售价额分摊原料总成本')
    begin
      select @Mode = [PscpType] from pscp(nolock) where Gid = @d_pscpgid
      if (@vCount = 0) and (@Mode <> 1)
      begin
        select @vCount = Count(1) from ProcExecProd(nolock) where Num = @Num and PscpGid = @d_pscpgid
        select @vSum = 0
        select @d_sumrawamt = 0
      end
    end

    select @d_inprc = InvPrc from GdWrh(nolock) where GdGid = @d_gdgid and Wrh = @d_wrh
    if @@RowCount = 0
      select @d_inprc = InvPrc from goods(nolock) where Gid = @d_gdgid
    select @d_rtlprc = RtlPrc, @d_cntinprc = CntInPrc, @d_lwtrtlprc = LwtRtlPrc from goods(nolock) where Gid = @d_gdgid

    select @d_cstprc = (case @vAlgavgtag
                          when '核算价' then @d_inprc
                          when '合同价' then @d_cntinprc
                          when '最低售价' then @d_lwtrtlprc
                        end)
    if @vAlgavgtag = '配方原料总成本/配方产品系数'
    begin
      select @Amount = Sum(Total)  from ProcExecRaw(nolock) where Num = @Num and PscpGid = @d_pscpgid
      if @Mode <> 1
      begin
        if @d_sumrawamt = 0
        begin
          declare c_Pscp cursor for
            select GdGid from PscpDtl(nolock) where Gid = @d_pscpgid and Raw = 0
          open c_Pscp
          fetch next from c_Pscp into @PscpGdGid
          while @@fetch_status = 0
          begin
            select @PscpGdInvPrc = InvPrc from GdWrh(nolock) where GdGid = @PscpGdGid and Wrh = @d_wrh
            if @@RowCount = 0
              select @PscpGdInvPrc = InvPrc from Goods(nolock) where Gid = @PscpGdGid
            select @PscpGdQty = Qty from ProcExecProd(nolock) where Num = @Num and GdGid = @PscpGdGid and PscpGid = @d_pscpgid
            select @d_sumrawamt = @d_sumrawamt + @PscpGdInvPrc * @PscpGdQty
            fetch next from c_Pscp into @PscpGdGid
          end
          close c_Pscp
          deallocate c_Pscp
        end
        if @vCount > 1
        begin
          set @Amount = Round(@Amount * ((@d_qty * @d_inprc)/@d_sumrawamt), 2)
          set @vSum = @vSum + @Amount
          set @vCount = @vCount - 1
        end else if @vCount = 1
        begin
          select @Amount = @Amount - @vSum, @vCount = 0, @d_sumrawamt = 0
        end
      end
    end else if @vAlgavgtag = '预期售价额分摊原料总成本'
    begin
      select @Amount = Round(Sum(Total), 2)  from ProcExecRaw(nolock) where Num = @Num and PscpGid = @d_pscpgid
      if @Mode <> 1
      begin
      	if @d_sumrawamt = 0
        begin
          declare c_Pscp cursor for
            select GdGid, ExpectPrc from PscpDtl dtl(nolock) where Gid = @d_pscpgid and Raw = 0
          open c_Pscp
          fetch next from c_Pscp into @PscpGdGid, @vExpectPrc
          while @@fetch_status = 0
          begin
            select @PscpGdQty = Qty from ProcExecProd(nolock) where Num = @Num and GdGid = @PscpGdGid and PscpGid = @d_pscpgid
            select @d_sumrawamt = @d_sumrawamt + @vExpectPrc * @PscpGdQty
            fetch next from c_Pscp into @PscpGdGid, @vExpectPrc
          end
          close c_Pscp
          deallocate c_Pscp
        end

        if @vCount > 1
        begin
          select @vExpectPrc = ExpectPrc from pscpdtl(nolock) where Gid = @d_pscpgid and GdGid = @d_gdgid and Raw = 0
          set @Amount = Round(@Amount * @d_qty * @vExpectPrc/@d_sumrawamt, 2)
          set @vSum = @vSum + @Amount
          set @vCount = @vCount - 1
        end else
        begin
          select @Amount = @Amount - @vSum, @vCount = 0, @d_sumrawamt = 0
        end
      end
    end else
      set @Amount = Round(@d_qty * @d_cstprc, 2)

    exec @vRet = UPDINVPRC '进货', @d_gdgid, @d_qty, @Amount, @d_Wrh, @outcost output
    if @vRet <> 0
    begin
      set @Msg = '审核加工入库单失败.'
      close c_Product
      deallocate c_Product
      return(1)
    end
    set @curdate = getdate()
    exec @vRet = loadin @d_Wrh, @d_gdgid, @d_qty, @d_rtlprc, @curdate
    if @vRet <> 0
    begin
      set @Msg = '审核加工入库单失败.'
      close c_Product
      deallocate c_Product
      return(1)
    end

    update ProcExecProd set CSTPRC = Round(@Amount/@d_qty, 2),  Total = @Amount where current of c_Product/*注意进货后的total*/
    update ProcTaskProd set GenQty = GenQty + @d_qty where (Num = @vTaskNum) and (PscpGid = @d_pscpgid) and (GdGid = @d_gdgid)

		--2006.12.19 added by zhanglong, 产品成本价大于核算售价时根据选项判断是否保存，若保存记录日志
    declare @ChkCostSave int, @t_gdCode varchar(13), @t_cstprc money, @t_rtlprc money, @t_note varchar(255)
    select @ChkCostSave = OptionValue from hdoption where moduleno = 647 and optioncaption = 'ChkCostSave'
    select @t_cstprc = cstprc, @t_rtlprc = rtlprc from ProcExecProd where Num = @Num and GdGid = @PscpGdGid and PscpGid = @d_pscpgid
		if @t_cstprc > @t_rtlprc
  	  if @ChkCostSave <> 0
  		begin
  			set @Msg = '产品成本价不允许大于其核算售价'
  			return(1)
  		end
  		else
  		begin
  			select @t_gdCode = code from goods where gid = @d_gdgid
  			select @t_note = '产品' + @t_gdCode + ' 成本价:' + cast(@t_cstprc as varchar(20)) + ' 大于 核算售价:' + cast(@t_rtlprc as varchar(20))
  			exec PROCEXEC_ADD_LOG @Num, 0, 100, @Oper, @t_note
			end;

		--2006.12.19 added by zhanglong, 产品成本价回写GOODS中最新进价（LSTINPRC）
		update Goods set LSTINPRC = @Amount/@d_qty where gid = @d_gdgid

    --2006.12.12 added by zhanglong, 加工任务单的已完成数大于等于待加工数时，修改单据状态为已完成
    if not exists(select 1 from ProcTaskProd where Num = @vTaskNum and GenQty < Qty)
     	update ProcTask set stat = 300 where Num = @vTaskNum and stat not in (300,110)

    fetch next from c_Product into @d_gdgid, @d_wrh, @d_pscpgid, @d_qty
  end
  close c_Product
  deallocate c_Product

  --Report
  execute @vRet = PROCDIFFEX @num, 0
  if @vRet <> 0
  begin
    set @Msg = '产品加工报表处理错误'
    return(1)
  end

  execute @vRet = PROCDIFFEX @num, 1
  if @vRet <> 0
  begin
    set @Msg = '原料加工报表处理错误'
    return(1)
  end

  declare
    @p_billto int, @adjnum varchar(10), @p_gdgid int, @p_inprc money, @p_rtlprc money,
    @p_qty money, @npqty money, @nptl money, @npstl money, @line int

  declare c_ProductVdr cursor for
    select distinct g.BillTo from ProcExecRaw r(nolock), Goods g(nolock) where Num = @Num and r.GdGid = g.Gid and g.sale in (2, 3)
    order by BillTo
  open c_ProductVdr
  fetch next from c_ProductVdr into @p_billto
  while @@fetch_status = 0
  begin
    select @adjnum = max(num) from PayAdj(nolock)
    if @adjnum is null select @adjnum = '0000000001'
       else execute nextbn @adjnum, @adjnum output
    insert into PayAdj(Num, SettleNo, FilDate, Filler, Checker, Wrh, BillTo, Stat, Note, PrnTime)
       values(@adjnum, @cursettleno, Getdate(), @m_checker, @m_checker, 1, @p_billto, 0, '由加工入库单'+@Num+'产生', null)

    select @line = 1
    declare c_procpay cursor for
      select GDGID, d.INVPRC, g.RTLPRC, sum(QTY)
      from ProcExecRaw d(nolock), GOODS g(nolock) where NUM = @num and d.gdgid=g.gid and g.sale in (2,3) and g.billto=@p_billto
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
      close c_ProductVdr
      deallocate c_ProductVdr
      return(1)
    end

    fetch next from c_ProductVdr into @p_billto
  end
  close c_ProductVdr
  deallocate c_ProductVdr

  update ProcExec set STAT = 100, SettleNo = @cursettleno, ChkEmp = @Oper, ChkTime = Getdate(), Modifier = @Oper, LstUpdTime = Getdate() where NUM = @Num

  exec PROCEXEC_ADD_LOG @Num, 0, 100, @Oper, ''
  return(0)
end
GO
