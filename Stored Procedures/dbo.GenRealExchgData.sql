SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GenRealExchgData](
    @StartDate   datetime,
    @FinishDate  datetime
)  as
begin
  declare 
    @curdate  datetime,
    @usergid int,
    @zbgid int,
    @realsp varchar(30),
    @buscls varchar(30),
    @cls varchar(30),
    @sqlstring varchar(255)

  select @usergid = usergid, @zbgid = zbgid from system
  set @startdate = convert(varchar(10), @startdate, 102) + ' 00:00:00'
  set @finishdate = convert(varchar(10), @finishdate, 102) + ' 23:59:59'

  delete from RealExchgdata
    where RecvDate between @StartDate and @FinishDate and tgt = @usergid
  delete from RealExchgdataDtl
    where RecvDate between @StartDate and @FinishDate and tgt = @usergid
	
  set @curdate = @startdate
  while @curdate<=@FinishDate 
  begin
    if @usergid = @zbgid
      insert into RealExchgData(RecvDate,src,tgt,reccnt)
	  select @curdate,gid,@usergid,0 from store where gid <> @usergid
	else
	  --如果是门店，则只要向总部发一张实收清单
	  insert into RealExchgData(RecvDate,src,tgt,reccnt)
	  values(@curdate, @zbgid, @usergid, 0)
    select @curdate = dateadd(day,1,@curdate)
  end   		

  declare c_dataexchg cursor for
  select buscls, cls, recalrealsp
  from dataexchgsetting where used = 1
  order by buscls
  open c_dataexchg
  fetch next from c_dataexchg into @buscls, @cls, @realsp
  while @@fetch_status = 0
  begin
  	if isnull(@realsp, '') <> ''
  	begin
  		select @sqlstring = 'exec ' + @realsp + ' ' 
  			+ '''' + @cls + '''' + ', '
  			+ '''' + convert(varchar(10), @startdate, 102) + ' 00:00:00' + '''' + ', '
  			+ '''' + convert(varchar(10), @finishdate, 102) + ' 23:59:59' + ''''
    	exec(@sqlstring)
  	end
  	fetch next from c_dataexchg into @buscls, @cls, @realsp
  end
  close c_dataexchg
  deallocate c_dataexchg

  --生成汇总数据
  update RealExchgData 
  set Reccnt = (select count(*)
    from RealExchgDatadtl dtl where  dtl.RecvDate = realexchgdata.Recvdate
      and  dtl.src = realexchgdata.src and  dtl.tgt = realexchgdata.tgt)
	where realexchgdata.RecvDate >= @Startdate and
	  RealExchgData.RecvDate <= @finishDate and realexchgdata.tgt = @usergid
  return 0
end
GO
