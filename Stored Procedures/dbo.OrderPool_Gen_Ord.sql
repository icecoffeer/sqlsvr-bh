SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Gen_Ord](
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vSetQtyMax int,
    @vOrderQtyMax varchar(255),
    @vQtyMax decimal(24,4),
    @vExpType int,
    @vExpDays int,
    @vExpDate datetime,
    @vUserGid int,
    @vGdGid int,
    @vVdrGid int,
    @vWrh int,
    @vCombineType char(10),
    @vSendDate datetime,
    @vQty decimal(24,4),
    @vPrice decimal(24,4),
    @vSplitDays int,
    @vQtyPerDay decimal(24,4),
    @vQtyLeft decimal(24,4),
    @vIndex int,
    @vSplitSendDate datetime,
    @vSendEndDate datetime,
    @vSplitNum char(10),
    @vRoundType char(10)
  exec OptReadInt 114, 'TransitDays', 0, @vExpType output
  exec OptReadInt 114, 'SetQtyMax', 0, @vSetQtyMax output
  exec OptReadStr 114, 'OrderQtyMax', '0', @vOrderQtyMax output
  if @vSetQtyMax = 1
    set @vQtyMax = convert(decimal(24,4), @vOrderQtyMax)
  select @vUserGid = USERGID from SYSTEM(nolock)

  if object_id('c_OrderPoolTemp') is not null deallocate c_OrderPoolTemp
  declare c_OrderPoolTemp cursor for
    select VDRGID, WRH, COMBINETYPE, SENDDATE, GDGID, QTY, PRICE, SPLITDAYS,
      ROUNDTYPE
    from ORDERPOOLTEMP(nolock)
    where SPID = @@spid
    order by VDRGID, WRH, COMBINETYPE, SENDDATE, GDGID
  open c_OrderPoolTemp
  fetch next from c_OrderPoolTemp
    into @vVdrGid, @vWrh, @vCombineType, @vSendDate, @vGdGid, @vQty, @vPrice, @vSplitDays,
      @vRoundType
  while @@fetch_status = 0
  begin
    if @vExpType = 1  --取供应商送货时间
      select @vExpDays = DAYS from VENDOR(nolock) where GID = @vVdrGid
    else
      exec OptReadInt 114, '有效期', 1, @vExpDays output
    if @vExpDays is null or @vExpDays <= 0
      set @vExpDays = 1

    if @vQty <= 0
      goto NextLoop

    set @vQtyLeft = @vQty
    set @vIndex = 0 --0代表@vSendDate指定的那天
    while @vIndex <= @vSplitDays
    begin
      if @vQtyLeft <= 0
        break
      if @vSetQtyMax = 1
      begin
        if @vQtyLeft < @vQtyMax
          set @vQtyPerDay = @vQtyLeft
        else
          set @vQtyPerDay = @vQtyMax
        if @vIndex = @vSplitDays --剩余数量都算到分拆天数的最后一天
          set @vQtyPerDay = @vQtyLeft
      end
      else begin --不设置数量上限
        set @vQtyPerDay = @vQtyLeft
      end

      set @vSplitSendDate = @vSendDate + @vIndex
      --找到符合条件的未完成单据
      select @vSplitNum = NUM from ORDERPOOLGENBILLS(nolock)
        where BILLNAME = '定货单' and FLAG = 0
          and VDRGID = @vVdrGid
          and WRH = @vWrh
          and COMBINETYPE = @vCombineType
          and SENDDATE = @vSplitSendDate
      if @@RowCount = 0
      begin
        --抢占单号
        select @vSplitNum = IsNull(max(NUM), replicate('0', 10)) from ORD(nolock)
        exec NEXTBN @vSplitNum, @vSplitNum output
        --送货截止时间
        set @vSendEndDate = convert(datetime, convert(varchar(10), @vSplitSendDate, 102) + ' 23:59:59')
        --到效日期
        set @vExpDate = convert(datetime, convert(varchar(10), GetDate() + @vExpDays, 102) + ' 23:59:59')
        if @vExpDate < @vSendEndDate
          set @vExpDate = @vSendEndDate
        insert into ORD(NUM, SETTLENO, WRH, VENDOR, NOTE, FILDATE,
          FILLER, STAT, RECCNT, SRC, RECEIVER, DLVBDATE, DLVEDATE, EXPDATE)
        values(@vSplitNum, -1, @vWrh, @vVdrGid, '由定货池生成。合单类型：' + rtrim(@vCombineType) + '。', getdate(),
          @piOperGid, 0, 0, @vUserGid, @vUserGid, null, null, @vExpDate)
        --在生成单据表中记录
        insert into ORDERPOOLGENBILLS(BILLNAME, NUM, DTLCNT, FLAG, VDRGID, WRH, COMBINETYPE, SENDDATE)
          values('定货单', @vSplitNum, 0, 0, @vVdrGid, @vWrh, @vCombineType, @vSplitSendDate)
      end
      exec OrderPool_Gen_OrdRecord @vSplitNum, @vGdGid, @vVdrGid, @vWrh,
        @vQtyPerDay, @vPrice, @piOperGid, @vRoundType, @poErrMsg output

      set @vQtyLeft = @vQtyLeft - @vQtyPerDay
      set @vIndex = @vIndex + 1
    end

NextLoop:
    fetch next from c_OrderPoolTemp
      into @vVdrGid, @vWrh, @vCombineType, @vSendDate, @vGdGid, @vQty, @vPrice, @vSplitDays,
        @vRoundType
  end
  close c_OrderPoolTemp
  deallocate c_OrderPoolTemp
  return 0
end
GO
