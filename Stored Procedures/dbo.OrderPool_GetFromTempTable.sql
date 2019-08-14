SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_GetFromTempTable](
  @Oper char(30),
  @Msg varchar(255) output
)
as
begin
  declare
    @GdCode char(13),
    @VdrCode char(10),
    @WrhCode char(10),
    @CombineType char(10),
    @SendDate varchar(255),
    @Qty varchar(255),
    @Price varchar(255),
    @OrderType char(10),
    @OrderDate varchar(255),
    @SplitDays varchar(255),
    @Note varchar(255),
    @RoundType char(10),
    @StoreOrdApplyType int,
    @StoreOrdApplyStat int
  declare
    @return_status int,
    @VdrGid int,
    @WrhGid int,
    @GdGid int,
    @mQty money,
    @mPrice money,
    @dOrderDate datetime,
    @dSendDate datetime,
    @nSplitDays int,
    @RightNow datetime,
    @UUID varchar(38)
  set @return_status = 0
  set @RightNow = GetDate()
  if object_id('c_TempXlsOrderPool') is not null
    deallocate c_TempXlsOrderPool
  declare c_TempXlsOrderPool cursor for
    select GDCODE, VDRCODE, WRHCODE, COMBINETYPE, SENDDATE,
      QTY, PRICE, ORDERTYPE, ORDERDATE, SPLITDAYS, NOTE,
      ROUNDTYPE, STOREORDAPPLYTYPE, STOREORDAPPLYSTAT
      from TEMPXLSORDERPOOL(nolock)
      where SPID = @@spid
  open c_TempXlsOrderPool
  fetch next from c_TempXlsOrderPool into
    @GdCode, @VdrCode, @WrhCode, @CombineType, @SendDate,
    @Qty, @Price, @OrderType, @OrderDate, @SplitDays, @Note,
    @RoundType, @StoreOrdApplyType, @StoreOrdApplyStat
  while @@fetch_status = 0
  begin
    if IsNull(@GdCode, '') = ''
    begin
      set @Msg = '存在商品代码为空的记录。'
      set @return_status = 1
      break
    end
    select @GdGid = GID from GOODS(nolock)
      where CODE = @GdCode
    if @@rowcount = 0
    begin
      set @Msg = '商品代码 ' + @GdCode + ' 无效。'
      set @return_status = 1
      break
    end

    if IsNull(@VdrCode, '') = ''
    begin
      set @Msg = '存在供应商代码为空的记录。'
      set @return_status = 1
      break
    end
    select @VdrGid = GID from VENDOR(nolock)
      where CODE = @VdrCode
    if @@rowcount = 0
    begin
      set @Msg = '供应商代码 ' + @VdrCode + ' 无效。'
      set @return_status = 1
      break
    end

    if IsNull(@WrhCode, '') = ''
    begin
      set @Msg = '存在仓位代码为空的记录。'
      set @return_status = 1
      break
    end
    select @WrhGid = GID from WAREHOUSE(nolock)
      where CODE = @WrhCode
    if @@rowcount = 0
    begin
      set @Msg = '仓位代码 ' + @WrhCode + ' 无效。'
      set @return_status = 1
      break
    end
    if rtrim(@RoundType) not in ('去尾', '进一', '不变', '四舍五入')
    begin
      set @Msg = '取整方式' + rtrim(@RoundType) + '无效。'
      set @return_status = 1
      break
    end

    set @mQty = Convert(money, @Qty)
    if IsNull(@Price, '') = ''
      set @mPrice = null
    else
      set @mPrice = Convert(money, @Price)

    set @dOrderDate = Floor(Convert(float, Convert(datetime, @OrderDate)))
    if isnull(@dOrderDate, 0) = 0
      set @dOrderDate = GetDate()

    set @dSendDate = Floor(Convert(float, Convert(datetime, @SendDate)))
    set @nSplitDays = Convert(int, @SplitDays)

    if rtrim(@CombineType) = '' or @CombineType is null
      set @CombineType = 'A'
    select @CombineType=
      case when goods.memo like '%W%' then 'W'
         when goods.memo like '%S%' then 'S'
         when goods.memo like '%D%' then 'D'
         else 'A' end
    from GOODS(nolock) where GID = @GdGid

    exec HD_CREATEUUID @UUID output

    insert into ORDERPOOL(UUID, GDGID, VDRGID, WRH, COMBINETYPE, SENDDATE,
      QTY, PRICE, ORDERTYPE, IMPTIME, IMPORTER, ORDERDATE, SPLITDAYS, NOTE,
      ROUNDTYPE, STOREORDAPPLYTYPE, STOREORDAPPLYSTAT)
      values(@UUID, @GdGid, @VdrGid, @WrhGid, @CombineType, @dSendDate,
        @mQty, @mPrice, @OrderType, @RightNow, @Oper, @dOrderDate, @nSplitDays, @Note,
        @RoundType, @StoreOrdApplyType, @StoreOrdApplyStat)
    if @@error <> 0
    begin
      set @Msg = '从临时表转移到正式表时发生异常。错误代码：' + Convert(varchar(255), @@error)
      set @return_status = 1
      break
    end

    fetch next from c_TempXlsOrderPool into
      @GdCode, @VdrCode, @WrhCode, @CombineType, @SendDate,
      @Qty, @Price, @OrderType, @OrderDate, @SplitDays, @Note,
      @RoundType, @StoreOrdApplyType, @StoreOrdApplyStat
  end
  close c_TempXlsOrderPool
  deallocate c_TempXlsOrderPool
  return @return_status
end
GO
