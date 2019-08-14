SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETAGMDTLOCR]
(
  @num  varchar(14),
  @storegid int,
  @intCoverAll int  --是否整体覆盖
) as
begin
  declare @bdate datetime,@edate datetime,@gdgid int,@diffprc money,@topqty money,@topamt money,
    @rbdate datetime,@redate datetime,@line int,@old_diffprc money,
    @dBdate datetime, --明细开始日期
    @dEdate datetime  --明细结束日期
  select @bdate = begindate,@edate = enddate from PRMOFFSETAGM where num = @num

  declare c_prmagmdtl  cursor for
    select GDGID,LINE,DIFFPRC,TOPQTY,TOPAMT, ASTART, AFINISH
    from PRMOFFSETAGMDTL
    where num = @num
  open c_prmagmdtl
  fetch next from c_prmagmdtl into @gdgid,@line,@diffprc,@topqty,@topamt, @dBdate, @dEdate
  while @@fetch_status = 0
  begin
    --如果是整体覆盖，则要覆盖PRMOFFSETAGMLAC表中该商品对应的所有行，而非仅本单据设置的日期段
    if @intCoverAll = 1
      delete from PRMOFFSETAGMLAC where gdgid = @gdgid and store = @storegid;

    if @dBdate is null
      select @dBdate = @bdate;
    if @dEdate is null
      select @dEdate = @edate;

    select @rbdate = @dBdate
    while @rbdate <= @dEdate
    begin
      if exists (select 1 from PRMOFFSETAGMLAC where gdgid = @gdgid and store = @storegid and rbdate = @rbdate)
      begin--修改补差协议当前值
        --修改应结表的重算标记
        if exists(select 1 from PRMOFFSETDEBIT(nolock) where  gdgid = @gdgid and store = @storegid and date = @rbdate)
      begin
        --如果补差价格不一致时，需修改重算标记
        select @old_diffprc = DIFFPRC from PRMOFFSETAGMLAC where gdgid = @gdgid and store = @storegid and rbdate = @rbdate
        if @diffprc <> @old_diffprc
        begin
          update PRMOFFSETDEBIT set RECAL = 1 where gdgid = @gdgid and store = @storegid and date = @rbdate
        end
      end
      --更新补差协议当前值
        update PRMOFFSETAGMLAC
        set num = @num,line = @line,bdate = @bdate,edate= @edate,rbdate = @rbdate,redate= @rbdate,
          diffprc = @diffprc,topqty = isnull(@topqty,0),topamt = isnull(@topamt,0)
        where gdgid = @gdgid and store = @storegid and rbdate = @rbdate
      end
      else--新增补差协议当前值
      begin
        insert into PRMOFFSETAGMLAC(gdgid,store,num,line,bdate,edate,rbdate,redate,diffprc,topqty,topamt)
        values(@gdgid,@storegid,@num,@line,@dBdate,@dEdate,@rbdate,@rbdate,@diffprc,@topqty,@topamt)
      end
      select @rbdate = dateadd(day,1,@rbdate)
    end
    fetch next from c_prmagmdtl into @gdgid,@line,@diffprc,@topqty,@topamt, @dBdate, @dEdate
  end
  close c_prmagmdtl
  deallocate c_prmagmdtl
  return(0)
end
GO
