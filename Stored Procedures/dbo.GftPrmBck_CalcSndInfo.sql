SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GftPrmBck_CalcSndInfo]
(
  @piGftSndNum varchar(14),
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @poErrMsg varchar(255) output
)
as
begin
  --Pre Procedure { gftprmbck_calcsaleinfo }
  --{ in tmpgftsndsale }
  declare
    @Ret int,
    @sndnum varchar(14),
    @posno varchar(10),
    @flowno varchar(14),
    @qty Money,
    @vAmt Money,
    @rcode varchar(18),
    @RuleCond varchar(1000)

  select Top 1 @sndnum = a.num from gftprmsndbill a(nolock), GFTPRMSND b(nolock), GFTPRMSNDGIFT c(nolock)
  where a.num = @piGftSndNum
    and a.cls = (select max(cls) from tmpgftsndsale(nolock) where spid = @@spid)
    and a.PosNo = @piPosNo and a.FlowNo = @piFlowNo
    and a.num = b.num and b.stat = 100
    and a.num = c.num and not exists (select 1 from GFTPRMSNDGIFT(nolock) where BCKQTY <> 0 and num = a.num)
  order by b.LSTUPDTIME

  --追加加送金额
  if (@sndnum <> '') and (@sndnum is not null)
    update tmpgftsndsale set
      tmpgftsndsale.amt = isnull(tmpgftsndsale.amt, 0) + isnull(gsale.addamt, 0)
        - isnull(gsale.deductamt, 0)  /*2005.09.23 增加限制金额扣除*/
      from gftprmsndsale gsale
      where tmpgftsndsale.spid = @@spid and gsale.num = @sndnum
        and gsale.posno = rtrim(tmpgftsndsale.posno)
        and gsale.flowno = rtrim(tmpgftsndsale.flowno)
        and gsale.gdgid = tmpgftsndsale.gdgid

  --填入已经发放赠品
  delete from tmpGftSnded where spid = @@spid
  insert into tmpGftSnded(
    spid, posno, flowno, sndnum, rcode, groupid,
    gdgid, qty, bckedqty, tobckqty,
    payamt, payprc, gftinprc,
    ctrtype, ruledtlqty, ruledtlallqty, ruledtlallamt,
    done)
  select
    @@spid, @piPosNo, @piFlowNo, @sndnum, snddtl.rcode, snddtl.groupid,
    snddtl.gftgid, snddtl.qty-snddtl.bckqty qty, snddtl.bckqty, 0 tobckqty,
    0 payamt, snddtl.payprc, snddtl.costprc gftinprc,
    0 ctrtype, gdtl.qty ruledtlqty, gmst.qty ruledtlallqty, gmst.amt ruledtlallamt,
    0 done
  from gftprmsnd sndmst(nolock), gftprmsndgift snddtl(nolock),
    gftprmgift gmst(nolock), gftprmgiftdtl gdtl(nolock)
  where snddtl.num = @sndnum and sndmst.num = snddtl.num
    and sndmst.stat = 100
    and snddtl.rcode = gmst.rcode and snddtl.groupid = gmst.groupid
    and snddtl.rcode = gdtl.rcode and snddtl.groupid = gdtl.groupid
    and snddtl.gftgid = gdtl.gftgid
    and snddtl.qty-snddtl.bckqty>0 and snddtl.rcode <> '-'
    and snddtl.rcode in (select rcode from gftprmrulelmtdtl rlmt(nolock)
          where name like 'BckBuyBck%' and value = 1)

  --手工发放
  insert into tmpGftSnded(
    spid, posno, flowno, sndnum, rcode, groupid,
    gdgid, qty, bckedqty, tobckqty, payamt, payprc, gftinprc,
    ctrtype, ruledtlqty, ruledtlallqty, ruledtlallamt,
    done)
  select
    @@spid, @piPosNo, @piFlowNo, @sndnum, snddtl.rcode, isnull(snddtl.groupid,1),
    snddtl.gftgid, snddtl.qty-snddtl.bckqty qty, snddtl.bckqty,
    snddtl.qty-snddtl.bckqty tobckqty,
    0 payamt, isnull(snddtl.payprc,0), snddtl.costprc gftinprc,
    3 ctrtype, 0 ruledtlqty, 0 ruledtlallqty, 0 ruledtlallamt,
    0 done
  from gftprmsnd sndmst(nolock), gftprmsndgift snddtl(nolock)
  where snddtl.num = @sndnum and sndmst.num = snddtl.num
    and sndmst.stat = 100 and snddtl.rcode = '-' and snddtl.qty > snddtl.bckqty

  --控制模式更新
  update tmpGftSnded set ctrtype = 3  where spid = @@spid
  update tmpGftSnded set ctrtype = 1  where spid = @@spid and ruledtlallqty<>0
  update tmpGftSnded set ctrtype = 2  where spid = @@spid and ruledtlallamt<>0
  --update tmpGftSnded set ctrtype = 3  where spid = @@spid and ruledtlqty<>0

  --重新匹配可赠送倍数 tmpgftsndresult
  Set @RuleCond = ' Code <> ''-'' and Code in (select ru.RCode from gftprmsndrule ru(nolock), gftprmrulelmtdtl lmt(nolock)  '
    + ' where lmt.rcode = ru.rcode and lmt.name like ''BckBuyBck%'' and lmt.value = 1 and ru.tag = 1 and ru.num = '''
    + RTrim(@sndnum) +''') '
  exec @ret = GFTSND_SEARCH @RuleCond, @poErrMsg Output
  return @ret
end
GO
