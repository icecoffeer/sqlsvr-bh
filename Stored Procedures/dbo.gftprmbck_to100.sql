SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprmbck_to100]
(
  @piNum char(14),
  @pioper	 char(30),
  @poErrmsg varchar(255) output
)
as
begin
  declare
    @stat int,                @return_status int,
    @rcode char(18),          @sndnum char(14),
    @cur_date datetime,       @cur_settleno int,
    @wrh int,                 @gdgid int,
    @vdr int,                 @billto int,
    @qty money,               @amount money,
    @stkoutbckstat int,       @stkoutbcknum varchar(14),
    @vRet int

  select @vRet = 0
  select @cur_date = convert(datetime, convert(char, getdate(), 102))
  select @cur_settleno = MAX(NO) from MONTHSETTLE(nolock)

  select @stat = stat,
         @stkoutbcknum = gennum,
         @sndnum = sndnum
    from gftprmbck where num = @pinum

  --一、检查单据
  if @stat <> 0
  begin
    set @poErrmsg = @piNum + '不是未审核单据，不能审核'
    return 1
  end
  /*手工回收时不处理
  select @stkoutbckstat = stat from stkoutbck (nolock) where num = @stkoutbcknum
  if @stkoutbckstat <> 0
  begin
    set @poErrmsg = @piNum + '不是未审核单据，不能审核'
    return 1
  end
  */

  --二、回写赠品发放单  已经回收赠品数量 GftPrmSndGift.BckQty
  update gftprmsndgift set
      bckqty = gftprmsndgift.bckqty + bckd.bckqty
    from gftprmbck bckm left join gftprmbckdtl bckd on bckm.num = bckd.num
    where bckm.Num = @piNum
      and gftprmsndgift.Num = bckm.SndNum
      and gftprmsndgift.rcode = bckd.rcode
      and gftprmsndgift.Groupid = bckd.Groupid
      and gftprmsndgift.gftgid = bckd.gftgid

  --三、回写赠品发放单  赠品发放倍数 GftPrmSndRule.BckCount
  if object_id('tempdb..#tmp_rulebckcnt') is not null
  	drop table #tmp_rulebckcnt
  select rcode, sum(rulebckcnt)/count(1) rulebckcnt, count(1) gftcnt
    into #tmp_rulebckcnt
    from gftprmbckdtl where num = @piNum
    group by rcode
  if object_id('tempdb..#tmp_rulebckcnt') is not null
    and exists(select 1 from #tmp_rulebckcnt)
  begin
    update gftprmsndrule set
  		bckcount = ru.bckcount + isnull(res.rulebckcnt, 0)
      from #tmp_rulebckcnt res(nolock),
          gftprmsndrule ru(nolock)
    	where res.rcode = ru.rcode
    		 and ru.num = @sndnum and res.rcode <> '-'
    if object_id('tempdb..#tmp_rulebckcnt') is not null
      drop table #tmp_rulebckcnt
  end else
  begin
    set @poErrmsg = '赠品回收单:[' + @piNum + '] 没有明细，或者临时表创建有误。'
    return 1
  end

  --四、退赠品明细处理 - BCKQTY
  if object_id('c_gftbck') is not null
  	deallocate c_gftbck
  declare c_gftbck cursor for
  	select gftgid, sum(bckqty), sum(realgftprc*bckqty)
  	from gftprmbckdtldtl  -- edited by jinlei
  	  where num = @piNum and bckqty<>0
  	group by gftgid
  open c_gftbck
  fetch next from c_gftbck into @gdgid, @qty, @amount

  while @@fetch_status = 0
  begin
    select @wrh = WRH, @billto = BILLTO
      from GOODS(nolock) where GID = @gdgid
    --A) 增加赠品库存
    execute @vRet = LOADIN @wrh, @gdgid, @qty, 0, null /*取售价为0*/
    if @vRet <> 0
    begin
      close c_gftbck
      deallocate c_gftbck
      set @poErrmsg = '加载库存时发生异常'
      raiserror('加载库存时发生异常', 16, 1)
      return 1
    end
    --B) 记录报表
    execute @vRet = StkOutBckDtlChkCrt
	      '零售', @cur_date, @cur_settleno, @cur_date,
	      @cur_settleno, 1, 1, @wrh,
	      @gdgid, @qty, @amount, 0, 0, 0, @billto, 1, 0 /* add by jinlei 3692*/
    if @vRet <> 0
    begin
      close c_gftbck
      deallocate c_gftbck
      set @poErrmsg = '加载库存时发生异常'
      raiserror('记录报表时发生异常', 16, 1)
      return 1
    end

    fetch next from c_gftbck into @gdgid, @qty, @amount
  end
  close c_gftbck
  deallocate c_gftbck

  --五、折价金额商品 - 销售
  -- (BCKQTY - QTY) 金额：AMT 单价: AMT/(BCKQTY-QTY)
  if object_id('c_gftbck') is not null
    deallocate c_gftbck
  declare c_gftbck cursor for
    select GFTGID, sum(BCKQTY - QTY) QTY, sum(AMT) from gftprmbckdtldtl --edited by jinlei
  	  where NUM = @piNum and (bckqty - qty) <> 0
  	  group by GFTGID
  open c_gftbck
  fetch next from c_gftbck into @gdgid, @qty, @amount

  while @@fetch_status = 0
  begin
    select @wrh = WRH, @billto = BILLTO
      from GOODS(nolock) where GID = @gdgid
    --A) 扣库存
    execute @vRet = UNLOAD @wrh, @gdgid, @qty, 0, null /*取售价为0*/
    if @vRet <> 0
    begin
      close c_gftbck
      deallocate c_gftbck
      raiserror('处理折价商品时发生异常', 16, 1)
      return 1
    end
    --B) 记销售报表
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
      LS_Q, LS_A, LS_T, LS_I, LS_R)
    values(@cur_date, @cur_settleno, @wrh,
    	   @gdgid, 1, 1, @billto, @qty, @amount, 0, 0, 0)

    fetch next from c_gftbck into @gdgid, @qty, @amount
  end
  close c_gftbck
  deallocate c_gftbck

  update gftprmbck set
      stat = 100,
      lstupdtime = getdate(),
      checker = @piOper,
      checkdate = getdate()
    where num = @piNum

  exec gftprmbck_addlog @piNum, 100, @piOper
  return 0
end
GO
