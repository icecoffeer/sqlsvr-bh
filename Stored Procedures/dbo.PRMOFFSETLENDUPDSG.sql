SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETLENDUPDSG]
(
  @gdgid int,
  @StoreGid int,
  @agmnum varchar(14),
  @agmline int,
  @start datetime,
  @finish datetime,
  @qty decimal(24, 4),
  @amt decimal(24, 4)
) as
begin
  declare
    @date DateTime,
    @sqty decimal(24, 4),
    @samt decimal(24, 4),
    @rqty decimal(24, 4),
    @ramt decimal(24, 4),
    @cal_qty decimal(24, 4),
    @cal_amt decimal(24, 4),
    @numl varchar(14),
    @sqty1 decimal(24, 4), --回写完毕后，应结表的应结数
    @rqty1 decimal(24, 4) --回写完毕后，已结表的已结数
  declare c_cal cursor for --应结的所有记录
    select b.SQTY, b.SAMT, ISNULL(l.RQTY, 0) RQTY, ISNULL(l.RAMT, 0) RAMT, b.Date, l.num from PRMOFFSETDEBIT b
      left join PRMOFFSETLEND l on l.GDGID = b.GDGID and l.STORE = b.STORE and l.DATE = b.DATE and l.NUM = b.NUM
      where b.GDGID = @gdgid and b.Store=@StoreGid and b.Date>=@start and b.Date<=@finish and b.NUM=@agmnum
      order by b.Date
  --在日期范围内，按日期早先结算（先进先结）
  open c_cal;
  fetch next from c_cal into @sqty, @samt, @rqty, @ramt, @date, @numl
  while @@fetch_status = 0
  begin
    set @cal_qty = @sqty - @rqty
    if (@cal_qty < 0) set @cal_qty = 0
    if (@cal_qty > @qty) set @cal_qty = @qty
    set @cal_amt = @samt - @ramt
    if (@cal_amt < 0) set @cal_amt = 0
    if (@cal_amt > @amt) set @cal_amt = @amt
    if ((@cal_qty > 0) or (@cal_amt > 0))
    begin
      if (@numl is not NULL)
        update PRMOFFSETLEND set RQTY = RQTY + @cal_qty, RAMT = RAMT + @cal_amt, RECAL = 1
          where GDGID = @gdgid and Store=@StoreGid and Date=@date and NUM=@agmnum
      else
        insert into PRMOFFSETLEND (GDGID, STORE, NUM, LINE, DATE, RAMT, RQTY, RECAL)
          values(@gdgid, @StoreGid, @agmnum, ISNULL(@agmline, 0), @date, @cal_amt, @cal_qty, 1)
      set @qty = @qty - @cal_qty
      set @amt = @amt - @cal_amt
    end
    fetch next from c_cal into @sqty, @samt, @rqty, @ramt, @date, @numl
  end
  --把剩下的全部放到最后一天结算
  if ((@qty >0 ) or (@amt > 0))
  begin
    if exists (select 1 from PRMOFFSETLEND where GDGID = @gdgid and Store=@StoreGid and Date=@finish and NUM=@agmnum)
      update PRMOFFSETLEND set RQTY = RQTY + @qty, RAMT = RAMT + @amt, RECAL = 1
        where GDGID = @gdgid and Store=@StoreGid and Date=@finish and NUM=@agmnum
    else
      insert into PRMOFFSETLEND (GDGID, STORE, NUM, LINE, DATE, RAMT, RQTY, RECAL)
        values(@gdgid, @StoreGid, @agmnum, ISNULL(@agmline, 0), @finish, @amt, @qty, 1)
    set @qty = 0
    set @amt = 0
  end
  close c_cal
  deallocate c_cal
  --回写PRMOFFSETAGMDTL.OFFSETED
  select @sqty1 = IsNull(Sum(SQty), 0) from Prmoffsetdebit(nolock)
  where GDGID = @gdgid and Store = @StoreGid and NUM = @agmnum and Line = @agmline
  select @rqty1 = IsNull(Sum(RQty), 0) from Prmoffsetlend(nolock)
  where GDGID = @gdgid and Store = @StoreGid and NUM = @agmnum and Line = @agmline
  if @sqty1 <= @rqty1
    update PrmOffsetAgmDtl set Offseted = 1 where Num = @agmnum and Line = @agmline
  else
    update PrmOffsetAgmDtl set Offseted = 0 where Num = @agmnum and line = @agmline
end
GO
