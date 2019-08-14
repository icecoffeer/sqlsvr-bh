SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolClearPoolFromGenBill]
as
begin
	declare @psrdatediff int
	declare @orddatediff int
	declare	@GenAlcLimit int		--是否对没有分货员和配货员的配货池数据生成单据,任务单1536
	declare @BillSrcFilter VarChar(20)
    declare @vErrMsg varchar(255)
  	declare @AVLINVAVGMETHOD int


	exec OptReadInt 500, 'GenAlcLimit', 0, @GenAlcLimit output
	exec OptReadInt 500, 'psrdatediff', 0, @psrdatediff output
	exec OptReadInt 500, 'orddatediff', 0, @orddatediff output
	exec OptReadStr 500, 'BillSrcFilter', '', @BillSrcFilter output
    exec OptReadInt 0, 'AVLINVAVGMETHOD', 0, @AVLINVAVGMETHOD output


  exec PPS_ALCPOOL_CLEAR_FROM_ZLORD 1, @vErrMsg output

  if @AVLINVAVGMETHOD = 1
  begin
    delete alcpool  from alcpool , clearalcpooltemp
    where alcpool.storegid = clearalcpooltemp.storegid
    and alcpool.gdgid = clearalcpooltemp.gdgid

    update alcpoolgenbills set flag = 3 where flag = 2/*2003.11.20 by zyb*/
  end
  else
  begin
    if @GenAlcLimit = 0
    begin
      --定货单
	  delete alcpool from alcpool, ord, orddtl
	  where alcpool.gdgid = orddtl.gdgid and alcpool.storegid = ord.receiver
	  and orddtl.num = ord.num and orddtl.flag = 0
	  and ord.num in (select num from alcpoolgenbills where flag = 2 and billname = '定货单')
	  and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
		or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
		or (srcgrp = 3))

      --配出单
	  if rtrim(@BillSrcFilter) = '非推荐报货'
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))
		and rtrim(alcpool.srcbill) <> '推荐报货'
  --ShenMin
	  else if rtrim(@BillSrcFilter) = '采购分货'
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))
		and rtrim(alcpool.srcbill) like '采配%'

	  else if rtrim(@BillSrcFilter) <> '' and rtrim(@BillSrcFilter) <> '（全部）'
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))
		and rtrim(alcpool.srcbill) = rtrim(@BillSrcFilter)
	  else
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))

      --批发单
	  delete alcpool from alcpool, stkout, stkoutdtl
	  where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
	  and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '批发'
	  and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '批发单')
	  and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
		or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
		or (srcgrp = 3))

      --配货通知单
	  delete alcpool from alcpool, DistNotify, DistNotifydtl
	  where alcpool.gdgid = DistNotifydtl.gdgid and alcpool.storegid = DistNotify.DistStore
	  and DistNotify.num = DistNotifydtl.num
	  and DistNotify.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货通知单')
	  and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
		or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
		or (srcgrp = 3))
    end
    else begin
      --定货单
	  delete alcpool from alcpool, ord, orddtl
	  where alcpool.gdgid = orddtl.gdgid and alcpool.storegid = ord.receiver
	  and orddtl.num = ord.num and orddtl.flag = 0 and alcpool.Aparter is not null and alcpool.Alcer is not null
	  and ord.num in (select num from alcpoolgenbills where flag = 2 and billname = '定货单')
	  and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
		or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
		or (srcgrp = 3))

      --配出单
	  if rtrim(@BillSrcFilter) = '非推荐报货'
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and alcpool.Aparter is not null and alcpool.Alcer is not null
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))
		and rtrim(alcpool.srcbill) <> '推荐报货'
  --ShenMin
	  else if rtrim(@BillSrcFilter) = '采购分货'
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))
		and rtrim(alcpool.srcbill) like '采配%'

	  else if rtrim(@BillSrcFilter) <> '' and rtrim(@BillSrcFilter) <> '（全部）'
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and alcpool.Aparter is not null and alcpool.Alcer is not null
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))
		and rtrim(alcpool.srcbill) = rtrim(@BillSrcFilter)
	  else
		delete alcpool from alcpool, stkout, stkoutdtl
		where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
		and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '配货'
		and alcpool.Aparter is not null and alcpool.Alcer is not null
		and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货出货单')
		and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
			or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
			or (srcgrp = 3))

      --批发单
	  delete alcpool from alcpool, stkout, stkoutdtl
	  where alcpool.gdgid = stkoutdtl.gdgid and alcpool.storegid = stkout.client
	  and stkoutdtl.num = stkout.num and stkoutdtl.cls = stkout.cls and stkout.cls = '批发'
	  and alcpool.Aparter is not null and alcpool.Alcer is not null
	  and stkout.num in (select num from alcpoolgenbills where flag = 2 and billname = '批发单')
	  and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
		or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
		or (srcgrp = 3))

      --配货通知单
	  delete alcpool from alcpool, DistNotify, DistNotifydtl
	  where alcpool.gdgid = DistNotifydtl.gdgid and alcpool.storegid = DistNotify.DistStore
	  and DistNotify.num = DistNotifydtl.num and alcpool.Aparter is not null and alcpool.Alcer is not null
	  and DistNotify.num in (select num from alcpoolgenbills where flag = 2 and billname = '配货通知单')
	  and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
		or (srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
		or (srcgrp = 3))
    end

	update alcpoolgenbills set flag = 3 where flag = 2/*2003.11.20 by zyb*/
  end

  return (0)
end
GO
