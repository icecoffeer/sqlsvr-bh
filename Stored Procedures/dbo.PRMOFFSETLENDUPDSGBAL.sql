SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETLENDUPDSGBAL]
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
    @rqty1 decimal(24, 4), --回写完毕后，已结表的已结数
    @rqty2 decimal(24, 4) --最后一天的已结数量
  declare c_cal cursor for --应结的所有记录
    select b.SQTY, b.SAMT, ISNULL(l.RQTY, 0) RQTY, ISNULL(l.RAMT, 0) RAMT, b.Date, l.num from PRMOFFSETLEND l
      left join PRMOFFSETDEBIT b on l.GDGID = b.GDGID and l.STORE = b.STORE and l.DATE = b.DATE and l.NUM = b.NUM
      where b.GDGID = @gdgid and b.Store=@StoreGid and b.Date>=@start and b.Date<=@finish and b.NUM=@agmnum
      order by b.Date desc
  --在日期范围内，按日期晚先减少
  open c_cal;
  fetch next from c_cal into @sqty, @samt, @rqty, @ramt, @date, @numl
  while @@fetch_status = 0
  begin
    --取应结，已结和作废数量最少的一个作为要作废的数
    --set @cal_qty = @sqty; if @cal_qty > @rqty set @cal_qty = @rqty; if @cal_qty > @qty set @cal_qty = @qty;
    --set @cal_amt = @samt; if @cal_amt > @ramt set @cal_amt = @ramt; if @cal_amt > @amt set @cal_amt = @amt;
    --取已结和作废数量较少的一个作为要作废的数
    set @cal_qty = @rqty; if @cal_qty > @qty set @cal_qty = @qty;
    set @cal_amt = @ramt; if @cal_amt > @amt set @cal_amt = @amt;
    if ((@cal_qty > 0) or (@cal_amt > 0))
    begin
      --如果数量作废后为0，删除记录
      if ((@cal_qty = @rqty) and (@cal_amt = @ramt))
        delete from PRMOFFSETLEND where GDGID = @gdgid and Store=@StoreGid and Date=@date and NUM=@agmnum
      else
        update PRMOFFSETLEND set RQTY = RQTY - @cal_qty, RAMT = RAMT - @cal_amt, RECAL = 1
          where GDGID = @gdgid and Store=@StoreGid and Date=@date and NUM=@agmnum
      set @qty = @qty - @cal_qty
      set @amt = @amt - @cal_amt
    end
    fetch next from c_cal into @sqty, @samt, @rqty, @ramt, @date, @numl
  end
  --如果出现不能作废数
  if ((@qty > 0 ) or (@amt > 0))
  begin
    select @rqty2 = rqty from PRMOFFSETLEND where GDGID = @gdgid and Store=@StoreGid and Date=@finish and NUM=@agmnum
    if @rqty2 is not null
    begin
      if @qty >= @rqty2
        delete from PRMOFFSETLEND where GDGID = @gdgid and Store=@StoreGid and Date=@finish and NUM=@agmnum
      else
        update PRMOFFSETLEND set RQTY = RQTY - @qty, RAMT = RAMT - @amt, RECAL = 1
        where GDGID = @gdgid and Store=@StoreGid and Date=@finish and NUM=@agmnum
    end
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
    update PrmOffsetAgmDtl set Offseted = 0 where Num = @agmnum and Line = @agmline
end
GO
