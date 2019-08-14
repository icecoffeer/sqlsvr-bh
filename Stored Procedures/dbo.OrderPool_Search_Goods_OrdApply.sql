SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Search_Goods_OrdApply](
  @piGoodsCond varchar(1000),
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vSQLStr varchar(8000),
    @vSpanSQLStr varchar(8000),
    @vOrderDateFromDiff varchar(10),
    @vOrderDateToDiff varchar(10),
    @vSendDateFromDiff varchar(10),
    @vSendDateToDiff varchar(10),
    @vOrderDateFrom varchar(10),
    @vOrderDateTo varchar(10),
    @vSendDateFrom varchar(10),
    @vSendDateTo varchar(10),
    @vSrcBill varchar(100)
  exec OptReadStr 8183, 'OrderDateFromDiff', '', @vOrderDateFromDiff output
  exec OptReadStr 8183, 'OrderDateToDiff', '', @vOrderDateToDiff output
  exec OptReadStr 8183, 'SendDateFromDiff', '', @vSendDateFromDiff output
  exec OptReadStr 8183, 'SendDateToDiff', '', @vSendDateToDiff output
  exec OptReadStr 8183, 'SrcBill', '', @vSrcBill output

  /*定货日期和送货日期的区间条件SQL*/
  set @vSpanSQLStr = ''
  if @vOrderDateFromDiff <> ''
  begin
    set @vOrderDateFrom = convert(varchar(10), dateadd(day, convert(int, @vOrderDateFromDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.ORDERDATE >= ''' + @vOrderDateFrom + ''''
  end
  if @vOrderDateToDiff <> ''
  begin
    set @vOrderDateTo = convert(varchar(10), dateadd(day, convert(int, @vOrderDateToDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.ORDERDATE - 1 < ''' + @vOrderDateTo + ''''
  end
  if @vSendDateFromDiff <> ''
  begin
    set @vSendDateFrom = convert(varchar(10), dateadd(day, convert(int, @vSendDateFromDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.SENDDATE >= ''' + @vSendDateFrom + ''''
  end
  if @vSendDateToDiff <> ''
  begin
    set @vSendDateTo = convert(varchar(10), dateadd(day, convert(int, @vSendDateToDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.SENDDATE - 1 < ''' + @vSendDateTo + ''''
  end

  /*插入ORDERPOOLTEMP表*/
  truncate table ORDERPOOLTEMP
  set @vSQLStr = 'insert into ORDERPOOLTEMP(SPID, GDGID, VDRGID, WRH, COMBINETYPE, SENDDATE, QTY, PRICE, SPLITDAYS, ROUNDTYPE,STOREORDAPPLYTYPE,STOREORDAPPLYSTAT)
    select @@spid, ORDERPOOL.GDGID, ORDERPOOL.VDRGID, ORDERPOOL.WRH, ORDERPOOL.COMBINETYPE, ORDERPOOL.SENDDATE,
      sum(QTY), min(PRICE), max(SPLITDAYS), max(ROUNDTYPE),STOREORDAPPLYTYPE,STOREORDAPPLYSTAT
    from ORDERPOOL(nolock)
      inner join GOODS(nolock) on ORDERPOOL.GDGID = GOODS.GID
    where 1=1
    and ORDERTYPE like ''RF叫货申请'' '
  if @piGoodsCond is not null and @piGoodsCond <> ''
    set @vSQLStr = @vSQLStr + ' and ' + @piGoodsCond
  if @vSpanSQLStr is not null and @vSpanSQLStr <> ''
    set @vSQLStr = @vSQLStr + @vSpanSQLStr
  if @vSrcBill <> '' and @vSrcBill <> '（全部）'
    set @vSQLStr = @vSQLStr + ' and ORDERPOOL.ORDERTYPE = ''' + @vSrcBill + ''''
  set @vSQLStr = @vSQLStr
    + ' group by ORDERPOOL.GDGID, ORDERPOOL.VDRGID, ORDERPOOL.WRH, ORDERPOOL.COMBINETYPE, ORDERPOOL.SENDDATE,STOREORDAPPLYTYPE,STOREORDAPPLYSTAT'
  exec(@vSQLStr)

  /*插入ORDERPOOLHTEMP表*/
  truncate table ORDERPOOLHTEMP
  set @vSQLStr = 'insert into ORDERPOOLHTEMP(SPID, UUID, GDGID, VDRGID, WRH, COMBINETYPE, SENDDATE,
    QTY, PRICE, ORDERTYPE, IMPTIME, IMPORTER, ORDERDATE, SPLITDAYS, NOTE, ROUNDTYPE, STOREORDAPPLYTYPE, STOREORDAPPLYSTAT)
    select @@spid, ORDERPOOL.UUID, ORDERPOOL.GDGID, ORDERPOOL.VDRGID, ORDERPOOL.WRH, ORDERPOOL.COMBINETYPE, ORDERPOOL.SENDDATE,
      ORDERPOOL.QTY, ORDERPOOL.PRICE, ORDERPOOL.ORDERTYPE, ORDERPOOL.IMPTIME, ORDERPOOL.IMPORTER, ORDERPOOL.ORDERDATE, ORDERPOOL.SPLITDAYS,
      ORDERPOOL.NOTE, ORDERPOOL.ROUNDTYPE, STOREORDAPPLYTYPE, STOREORDAPPLYSTAT
    from ORDERPOOL(nolock)
      inner join GOODS(nolock) on ORDERPOOL.GDGID = GOODS.GID
    where 1=1
    and ORDERTYPE like ''RF叫货申请'' '
  if @piGoodsCond is not null and @piGoodsCond <> ''
    set @vSQLStr = @vSQLStr + ' and ' + @piGoodsCond
  if @vSpanSQLStr is not null and @vSpanSQLStr <> ''
    set @vSQLStr = @vSQLStr + @vSpanSQLStr
  if @vSrcBill <> '' and @vSrcBill <> '（全部）'
    set @vSQLStr = @vSQLStr + ' and ORDERPOOL.ORDERTYPE = ''' + @vSrcBill + ''''
  exec(@vSQLStr)

  return 0
end
GO
