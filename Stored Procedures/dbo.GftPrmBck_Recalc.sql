SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GftPrmBck_Recalc]
as
begin
  declare @sndnum varchar(14), @qty1 money, @qty2 money, @amt1 money, @amt2 money
  declare @qty Money, @vAmt Money, @grpid int, @gdgid int, @count int
  declare @rcode varchar(18), @ctrtype int
  declare @ruledtlqty Money,@ruledtlallqty Money, @ruledtlallamt Money
----一、规则处理----
  --插入匹配为0的记录
  set @sndnum = (select top 1 sndnum from tmpGftSnded where spid = @@spid)
  insert into tmpgftsndresult(spid, rcode, [count])
  	select @@spid, RCode,0  from gftprmsndrule
  	where num = @sndnum and tag = 1
  	and RCode not in (select rcode from tmpgftsndresult where spid = @@spid)
  	and RCode in (select rcode from gftprmrulelmtdtl rlmt(nolock)
  					where name like 'BckBuyBck%' and value = 1 )
  --插入手工发放的回收次数
  if not exists(select 1 from tmpgftsndresult where rcode = '-' and spid = @@spid)
    if exists(select 1 from tmpGftSnded where RCode = '-' and spid = @@spid)
      insert into tmpgftsndresult(spid, rcode, [count]) select @@spid, '-',0

----二、赠品组处理----
  --赠品组的应退信息
  delete from Tmp_GrpGftSended where spid = @@spid
  insert into Tmp_GrpGftSended(spid, rcode, groupid, ctrtype, qty, tobckqty, amt, tobckamt, done )
  select @@spid, rcode, groupid, ctrtype, sum(qty), 0, sum(qty * gftinprc), 0, 0
  	from tmpGftSnded
  	where spid = @@spid --and ctrtype <> 3
  	group by rcode, groupid, ctrtype
  --ctrtype = 3
  update Tmp_GrpGftSended set done = 1, tobckqty = res.[count]  --TODO:该处记录次数而非实际退货数
  from tmpgftsndresult res
  where Tmp_GrpGftSended.ctrtype = 3  and Tmp_GrpGftSended.spid = @@spid
    and res.rcode = tmp_grpgftsended.rcode and res.spid = @@spid
    --and gft.rcode = res.rcode and gft.groupid = tmp_grpgftsended.groupid and gft.spid = @@spid
  --ctrtype = 2,1
  update Tmp_GrpGftSended set tobckqty =
  	case when (Tmp_GrpGftSended.qty - (res.[count] * gg.qty)) <= 0 then 0
  	else (Tmp_GrpGftSended.qty - (res.[count] * gg.qty)) end
  from tmpgftsndresult res, Gftprmgift gg
  where res.rcode = tmp_grpgftsended.rcode and  tmp_grpgftsended.spid = @@spid and res.spid = @@spid
  	and gg.rcode = res.rcode and gg.groupid = tmp_grpgftsended.groupid and gg.qty<>0 and res.rcode<>'-'
  --ctrtype = 2,1
  update Tmp_GrpGftSended set tobckamt =
    case when (tmp_grpgftsended.amt - (res.[count]* gg.amt))<=0 then 0
    else (tmp_grpgftsended.amt - (res.[count]* gg.amt)) end
  from tmpgftsndresult res, gftprmgift gg
  where res.rcode = tmp_grpgftsended.rcode and  tmp_grpgftsended.spid = @@spid and res.spid = @@spid
  	and gg.rcode = res.rcode and gg.groupid = tmp_grpgftsended.groupid and gg.amt<>0 and res.rcode<>'-'
  --手工发放赠品组处理
  update tmp_grpgftsended set tobckqty = qty, tobckamt = amt where rcode='-'
  --更新Done
  update Tmp_GrpGftSended set done = 1
  where tmp_grpgftsended.spid = @@spid and (tobckqty + tobckamt) = 0

----三、赠品明细处理----
  --自动处理应退赠品数量
  if object_id('tempdb..#tmp_tmpGftSnded') is not null drop table #tmp_tmpGftSnded
  select * into #tmp_tmpGftSnded from tmpGftSnded where spid = @@spid
  if object_id('c_gftsndrecalc') is not null deallocate c_gftsndrecalc
  declare c_gftsndrecalc cursor for
  select tmp.rcode, tmp.groupid, tmp.gdgid, tmp.ctrtype,
  		 res.[count], tmp.ruledtlqty, tmp.ruledtlallqty, tmp.ruledtlallamt
  	from #tmp_tmpGftSnded tmp,  tmpgftsndresult res
  	where res.spid = @@spid and tmp.rcode = res.rcode
  		and tmp.spid = @@spid and tmp.rcode <> '-'
  open c_gftsndrecalc
  fetch next from c_gftsndrecalc into
    @rcode, @grpid, @gdgid, @ctrtype, @count,@ruledtlqty, @ruledtlallqty, @ruledtlallamt
  while @@fetch_status = 0
  begin
    if @ctrtype = 1 --Qty
    begin
      --自动确定退货数量
      select @qty1 = sum(tobckqty) from tmpGftSnded where spid = @@spid and rcode = @rcode and groupid = @grpid
      select @qty2 = tobckqty from tmp_GrpGftSended where spid = @@spid and rcode = @RCode and groupid = @grpid
      set @qty1 = @qty2 - @qty1
      if @qty1>0
        if @qty1<(select qty from tmpGftSnded
            where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid)
          update tmpGftSnded set tobckqty = @qty1
            where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid
        else
          update tmpGftSnded set tobckqty = qty
            where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid
    end
    if @ctrtype = 2 --Amt
    begin
      --自动确定退货金额
      select @amt1 = sum(gftinprc * tobckqty) from tmpGftSnded where rcode = @rcode and groupid = @grpid and spid = @@spid
      select @amt2 = tobckamt from tmp_GrpGftSended where rcode = @RCode and groupid = @grpid and spid = @@spid
      set @amt1 = @amt2 - @amt1
      if @amt1>0
        if @amt1<(select gftinprc * qty from tmpGftSnded
            where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid)
          update tmpGftSnded set tobckqty = ceiling(@amt1/gftinprc)
            where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid
        else
          update tmpGftSnded set tobckqty = qty
            where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid
    end
    if @ctrtype = 3 --Def
    begin
    	update tmpGftSnded set tobckqty = Case When (Qty - @Count * @ruledtlqty) < 0 then 0 else (Qty - @Count * @ruledtlqty) end , done = 1
    	where rcode = @rcode and groupid = @grpid and gdgid = @gdgid and spid = @@spid
    end
    fetch next from c_gftsndrecalc into
        @rcode, @grpid, @gdgid, @ctrtype, @count,@ruledtlqty, @ruledtlallqty, @ruledtlallamt
  end
  close c_gftsndrecalc
  deallocate c_gftsndrecalc
  --手工发放处理
  update tmpGftSnded set tobckqty = qty, done = 0 where rcode = '-' and spid = @@spid

--四、赠品组再次处理
  --do nothing
  return 0
end
GO
