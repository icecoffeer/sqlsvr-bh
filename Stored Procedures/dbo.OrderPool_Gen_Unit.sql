SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Gen_Unit](
  @piNum char(10),
  @piVdrGid int,
  @piGdGid int,
  @piQty decimal(24,4),
  @piRoundType char(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vApplyGftAgm int,
    @vRoundByOrderQty int,
    @vUserGid int,
    @vGdGid int,
    @vGftGid int,
    @vInQty decimal(24,4),
    @vGftQty decimal(24,4),
    @vOrderQty decimal(24,4),
    @vQpc decimal(24,4),
    @vCases decimal(24,4),
    @vOrderUnit decimal(24,4),
    @vQpcUnit decimal(24,4),
    @vQty decimal(24,4),
    @vQty2 decimal(24,4),
    @vIsGft smallint,
    @vHasGft smallint
  exec OptReadInt 8183, 'ApplyGftAgm', 0, @vApplyGftAgm output
  exec OptReadInt 8183, 'RoundByOrderQty', 0, @vRoundByOrderQty output
  select @vUserGid = USERGID from SYSTEM(nolock)

  delete from ORDERPOOLQTYTEMP where SPID = @@spid
  --插入主商品
  insert into ORDERPOOLQTYTEMP(SPID, GDGID, ISGFT, INQTY, GFTQTY, QTY)
    values(@@spid, @piGdGid, 0, 0, 0, @piQty)
  --插入赠品
  if @vApplyGftAgm = 1
  begin
    if object_id('c_gft') is not null deallocate c_gft
    declare c_gft cursor for
      select g.GID, f.INQTY, f.GFTQTY
      from GIFT f(nolock)
        left join GOODS g(nolock) on f.GFTGID = g.GID
        left join GOODS h(nolock) on f.GDGID = h.GID
      where f.LSTID in (
        select max(LSTID) from GIFT(nolock)
        where GDGID = @piGdGid
          and VENDOR = @piVdrGid
          and START < getdate()
          and FINISH > getdate()
          and STOREGID = @vUserGid
        group by GDGID, GFTGID
        )
      and f.STOREGID = @vUserGid
    open c_gft
    fetch next from c_gft into @vGftGid, @vInQty, @vGftQty
    while @@fetch_status = 0
    begin
      set @vQty = @piQty / @vInQty * @vGftQty --赠品数量
      insert into ORDERPOOLQTYTEMP(SPID, GDGID, ISGFT, INQTY, GFTQTY, QTY)
        values(@@spid, @vGftGid, 1, @vInQty, @vGftQty, @vQty)
      fetch next from c_gft into @vGftGid, @vInQty, @vGftQty
    end
    close c_gft
    deallocate c_gft
  end

  --取整每条记录--
  set @vHasGft = 0
  set @vQty2 = 0
  declare c_OrderPoolQtyTemp cursor for
    select GDGID, ISGFT, INQTY, GFTQTY, QTY
      from ORDERPOOLQTYTEMP where SPID = @@spid
    for update
  open c_OrderPoolQtyTemp
  fetch next from c_OrderPoolQtyTemp
    into @vGdGid, @vIsGft, @vInQty, @vGftQty, @vQty
  while @@fetch_status = 0
  begin
    select @vOrderQty = ORDERQTY, @vQpc = QPC
      from GOODS(nolock)
      where GID = @vGdGid
    --取整每个商品
    if @vIsGft = 0 --主商品
    begin
      if @vRoundByOrderQty = 1 and @vOrderQty > 0 --按定货单位取整
      begin
        set @vOrderUnit = @vQty / @vOrderQty
        if abs(@vOrderUnit - round(@vOrderUnit, 0, 1)) >= 1e-4
        begin
          if rtrim(@piRoundType) = '去尾'
            set @vOrderUnit = round(@vOrderUnit, 0, 1)
          else if rtrim(@piRoundType) = '进一'
            set @vOrderUnit = round(@vOrderUnit, 0, 1) + 1.0
          else if rtrim(@piRoundType) = '四舍五入'
            set @vOrderUnit = round(@vOrderUnit, 0)
          else if rtrim(@piRoundType) = '不变'
            set @vOrderUnit = @vOrderUnit
          else begin
            close c_OrderPoolQtyTemp
            deallocate c_OrderPoolQtyTemp
            set @poErrMsg = '不能识别的取整方式：' + rtrim(@piRoundType)
            return 1
          end
          set @vQty = @vOrderUnit * @vOrderQty
          update ORDERPOOLQTYTEMP set QTY = @vQty
            where current of c_OrderPoolQtyTemp
        end
      end
      else begin  --按包装规格QPC取整  by fujing 2011.10.24
        set @vOrderUnit = @vQty / @vqpc
        if abs(@vOrderUnit - round(@vOrderUnit, 0, 1)) >= 1e-4
        begin
          if rtrim(@piRoundType) = '去尾'
            set @vOrderUnit = round(@vOrderUnit, 0, 1)
          else if rtrim(@piRoundType) = '进一'
            set @vOrderUnit = round(@vOrderUnit, 0, 1) + 1.0
          else if rtrim(@piRoundType) = '四舍五入'
            set @vOrderUnit = round(@vOrderUnit, 0)
          else if rtrim(@piRoundType) = '不变'
            set @vOrderUnit = @vOrderUnit
          else begin
            close c_OrderPoolQtyTemp
            deallocate c_OrderPoolQtyTemp
            set @poErrMsg = '不能识别的取整方式：' + rtrim(@piRoundType)
            return 1
          end
          set @vQty = @vOrderUnit * @vqpc
          update ORDERPOOLQTYTEMP set QTY = @vQty
            where current of c_OrderPoolQtyTemp
        end
      end
    end
    else begin --赠品按包装规格取整
      if @vQpc > 0
      begin
        set @vQpcUnit = @vQty / @vQpc
        if abs(@vQpcUnit - round(@vQpcUnit, 0, 1)) >= 1e-4
        begin
          if @vQpcUnit < 1 --不足一进一
          begin
            set @vQpcUnit = 1
          end
          else --足一四舍五入
            set @vQpcUnit = round(@vQpcUnit, 0)
          set @vQty = @vQpcUnit * @vQpc
          update ORDERPOOLQTYTEMP set QTY = @vQty
            where current of c_OrderPoolQtyTemp
        end
        set @vHasGft = 1
        --根据赠品数量反算商品数量，这个过程中商品数量超出上限不处理
        set @vQty2 = round(@vQty / @vGftQty * @vInQty, 0)
      end
    end

    fetch next from c_OrderPoolQtyTemp
      into @vGdGid, @vIsGft, @vInQty, @vGftQty, @vQty
  end
  close c_OrderPoolQtyTemp
  deallocate c_OrderPoolQtyTemp

  --对于有赠品的商品，其数量按赠品数反算得到
  if @vHasGft = 1 and @vQty2 > 0
    update ORDERPOOLQTYTEMP set QTY = @vQty2
      where SPID = @@spid and GDGID = @piGdGid and ISGFT = 0
  return 0
end
GO
