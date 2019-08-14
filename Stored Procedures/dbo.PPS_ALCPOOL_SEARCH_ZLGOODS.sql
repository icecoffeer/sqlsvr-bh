SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_SEARCH_ZLGOODS]
(
  @piGoodsCond varchar(255),
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vSQLStr varchar(1024)
  declare @vPsrDateDiff int
  declare @vOrdDateDiff int
  declare @vPsrDate varchar(10)
  declare @vOrdDate varchar(10)
  declare @vOp_StoreGdAlcStrategy int
  declare @vOp_ClearPool int --打开情况下记录并根据标志ZLGENORD标志来判断。
  declare @vOp_AlcPoolDirOrderPolicy int
  declare @SameSrcgrpProcMethod int

  --读取选项
	exec OptReadInt 500, 'psrdatediff', 0, @vPsrDateDiff output
	exec OptReadInt 500, 'orddatediff', 0, @vOrdDateDiff output
	exec OptReadInt 0, 'StoreGdAlcStrategy', 0, @vOp_StoreGdAlcStrategy output
  exec OptReadInt 500, '直流商品清除配货池', 0, @vOp_ClearPool output
  exec OptReadInt 500, 'SameSrcgrpProcMethod', 0, @SameSrcgrpProcMethod output --azer
  set @vOp_ClearPool = 0
  exec OptReadInt 500, '直流商品策略', 0, @vOp_AlcPoolDirOrderPolicy output

  set @vPsrDate = convert(varchar(10), dateadd(day, @vPsrDateDiff, getdate()), 102)
  set @vOrdDate = convert(varchar(10), dateadd(day, @vOrdDateDiff, getdate()), 102)

  --商品写入AlcPoolTemp
  truncate table alcpooltemp
  if @vOp_StoreGdAlcStrategy = 1  --采用门店的配货方式
    set @vSQLStr = 'insert into alcpooltemp(storegid, gdgid, gdcode, alc, vendor, sort, name, wrh, psr, f1, f2)
      select distinct alcpool.storegid, alcpool.gdgid, goods.code, goods.alc, goods.billto, goods.sort, goods.name, goods.wrh, goods.psr, goods.f1, goods.f2
      from alcpool(nolock)
        left join goods(nolock) on alcpool.gdgid = goods.gid
        left join gdstore gdstore(nolock) on alcpool.storegid = gdstore.storegid and alcpool.gdgid = gdstore.gdgid
      where alcpool.storegid in (select storegid from tmpalcpoolstore(nolock))
        and ((alcpool.srcgrp = 1 and alcpool.dmddate <= ' + '''' + @vPsrDate + '''' + ')
          or (alcpool.srcgrp = 2 and alcpool.dmddate <= ' + '''' + @vOrdDate + '''' + ')
          or (alcpool.srcgrp = 3))
        and isnull(gdstore.alc, goods.alc) = ''直流'''
  else
    set @vSQLStr = 'insert into alcpooltemp(storegid, gdgid, gdcode, alc, vendor, sort, name, wrh, psr, f1, f2)
      select distinct alcpool.storegid, alcpool.gdgid, goods.code, goods.alc, goods.billto, goods.sort, goods.name, goods.wrh, goods.psr, goods.f1, goods.f2
      from alcpool(nolock)
        left join goods(nolock) on alcpool.gdgid = goods.gid
      where alcpool.storegid in (select storegid from tmpalcpoolstore(nolock))
        and ((alcpool.srcgrp = 1 and alcpool.dmddate <= ' + '''' + @vPsrDate + '''' + ')
          or (alcpool.srcgrp = 2 and alcpool.dmddate <= ' + '''' + @vOrdDate + '''' + ')
          or (alcpool.srcgrp = 3))
        and goods.alc = ''直流'''
  if @piGoodsCond is not null and @piGoodsCond <> ''
    set @vSQLStr = @vSQLStr + ' and ' + @piGoodsCond
  if @vOp_ClearPool = 0 and @vOp_AlcPoolDirOrderPolicy = 0  --不清除全部生成定单 筛选未处理的记录
    set @vSQLStr = @vSQLStr + ' and (alcpool.zlgenstat is null or alcpool.zlgenstat = 0) '
  if @vOp_ClearPool = 0 and @vOp_AlcPoolDirOrderPolicy = 1  --不清除全部生成配出 筛选已经生成定单的记录
    set @vSQLStr = @vSQLStr + ' and alcpool.zlgenstat = 1 '
  exec(@vSQLStr)

  --写入历史表
  truncate table alcpoolHtemp
  /*set @vSQLStr = 'insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls, srcnum, srcline, note, aparter, alcer, isused)
    select a.storegid, a.gdgid, a.line, a.qty, a.srcqty, a.dmddate, a.srcgrp, a.srcbill, a.srccls, a.srcnum, a.srcline, a.note, a.aparter, a.alcer, 0
    from alcpool a(nolock), alcpooltemp t(nolock)
    where a.storegid = t.storegid
      and a.gdgid = t.gdgid
      and ((a.srcgrp = 1 and a.dmddate <= ' + '''' + @vPsrDate + '''' + ')
        or (a.srcgrp = 2 and a.dmddate <= ' + '''' + @vOrdDate + '''' + ')
        or (a.srcgrp = 3))'*/
  if @vOp_StoreGdAlcStrategy = 1
 		set @vSQLStr =
		' insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill,
		    srccls, srcnum, srcline, note, aparter, alcer, isused)
			select alcpool.storegid, alcpool.gdgid, alcpool.line, alcpool.qty, alcpool.srcqty, alcpool.dmddate,
			  alcpool.srcgrp, alcpool.srcbill, alcpool.srccls,alcpool.srcnum, alcpool.srcline, alcpool.note,
			  aparter, alcer, 0
			from alcpool alcpool(nolock)
			     left join goods(nolock) on alcpool.gdgid = goods.gid
			     left join gdstore(nolock) on alcpool.storegid = gdstore.storegid and gdstore.gdgid = goods.gid
			where alcpool.storegid in (select storegid from tmpalcpoolstore(nolock))
        and ((alcpool.srcgrp = 1 and alcpool.dmddate <= ' + '''' + @vPsrDate + '''' + ')
          or (alcpool.srcgrp = 2 and alcpool.dmddate <= ' + '''' + @vOrdDate + '''' + ')
          or (alcpool.srcgrp = 3))
        and isnull(gdstore.alc, goods.alc) = ''直流'' '
	else
    set @vSQLStr =
    ' insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill,
        srccls, srcnum, srcline, note, aparter, alcer, isused)
      select a.storegid, a.gdgid, a.line, a.qty, a.srcqty, a.dmddate, a.srcgrp, a.srcbill,
        a.srccls, a.srcnum, a.srcline, a.note, a.aparter, a.alcer, 0
      from alcpool a(nolock), goods g(nolock)
      where a.gdgid = g.gid and a.storegid in (select storegid from tmpalcpoolstore(nolock))
        and ((a.srcgrp = 1 and a.dmddate <= ' + '''' + @vPsrDate + '''' + ')
          or (a.srcgrp = 2 and a.dmddate <= ' + '''' + @vOrdDate + '''' + ')
          or (a.srcgrp = 3))
        and g.alc = ''直流'' '
  exec(@vSQLStr)

  --计算数量
if @SameSrcgrpProcMethod = 1
 begin
    update alcpooltemp
    set psralcqty = (select isnull(max(a.qty), 0)
    from alcpool a
    where a.storegid = alcpooltemp.storegid
      and a.gdgid = alcpooltemp.gdgid
      and a.srcgrp = 1
      and a.dmddate <= @vPsrDate)
  update alcpooltemp
    set ordqty = (select isnull(max(a.qty), 0)
    from alcpool a
    where a.storegid = alcpooltemp.storegid
      and a.gdgid = alcpooltemp.gdgid
      and a.srcgrp = 2
      and a.dmddate <= @vOrdDate)
  update alcpooltemp
    set autoalcqty = (select isnull(max(a.qty), 0)
    from alcpool a
    where a.storegid = alcpooltemp.storegid
      and a.gdgid = alcpooltemp.gdgid
      and a.srcgrp = 3)
 end else
 begin
  update alcpooltemp
    set psralcqty = (select isnull(sum(a.qty), 0)
    from alcpool a
    where a.storegid = alcpooltemp.storegid
      and a.gdgid = alcpooltemp.gdgid
      and a.srcgrp = 1
      and a.dmddate <= @vPsrDate)
  update alcpooltemp
    set ordqty = (select isnull(sum(a.qty), 0)
    from alcpool a
    where a.storegid = alcpooltemp.storegid
      and a.gdgid = alcpooltemp.gdgid
      and a.srcgrp = 2
      and a.dmddate <= @vOrdDate)
  update alcpooltemp
    set autoalcqty = (select isnull(sum(a.qty), 0)
    from alcpool a
    where a.storegid = alcpooltemp.storegid
      and a.gdgid = alcpooltemp.gdgid
      and a.srcgrp = 3)
 end

  return(0);
end
GO
