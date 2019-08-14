SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GenShouldExchgData](
    @StartDate   datetime,
    @FinishDate  datetime
)  as
begin
  declare
    @buscls	varchar(30),
    @cls varchar(30),
    @shouldsp	varchar(30),
    @sqlstring	varchar(255),
    @usergid	int,
    @zbgid	int,
    @curdate datetime
 
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  set @startdate = convert(varchar(10), @startdate, 102) + ' 00:00:00'
  set @finishdate = convert(varchar(10), @finishdate, 102) + ' 23:59:59'
  
  delete from ShouldExchgdata
  where senddate >= @StartDate 
    and senddate <= @FinishDate 
    and src = @usergid
  delete from ShouldExchgdataDtl
  where senddate >= @StartDate 
    and senddate <=@FinishDate 
    and src = @usergid
	
  set @curdate = @startdate
  while @curdate <= @FinishDate 
  begin
    if @usergid = @zbgid
      --如果是总部，则要向所有门店发一张应收清单
      insert into ShouldExchgData(SendDate,src,tgt,reccnt)
      select @curdate, @usergid, gid, 0 from store where gid <> @usergid
      	else
      --如果是一般，则要向总部发一张应收清单
      insert into ShouldExchgData(SendDate,src,tgt,reccnt)
      values(@curdate, @usergid, @zbgid, 0)
      
    select @curdate = dateadd(day, 1, @curdate)
  end

  declare c_dataexchg cursor for
  select buscls, cls, recalshouldsp
  from dataexchgsetting where used = 1
  order by buscls
  open c_dataexchg
  fetch next from c_dataexchg into @buscls, @cls, @shouldsp
  while @@fetch_status = 0
  begin
  	if isnull(@shouldsp, '') <> ''
  	begin
  		select @sqlstring = 'exec ' + @shouldsp + ' ' 
  			+ '''' + @cls + '''' + ', '
  			+ '''' + convert(varchar(10), @startdate, 102) + ' 00:00:00' + '''' + ', '
  			+ '''' + convert(varchar(10), @finishdate, 102) + ' 23:59:59' + ''''
    	exec(@sqlstring)
  	end
  	fetch next from c_dataexchg into @buscls, @cls, @shouldsp
  end
  close c_dataexchg
  deallocate c_dataexchg
          
  --生成汇总数据
  update ShouldExchgData 
    set Reccnt = (select count(*)
      from ShouldExchgDatadtl dtl 
      where  dtl.SendDate = ShouldExchgData.senddate
        and  dtl.src = ShouldExchgData.src and  dtl.tgt = ShouldExchgData.tgt)
  where ShouldExchgData.senddate >= @StartDate 
    and ShouldExchgData.SendDate <= @FinishDate and ShouldExchgData.src = @usergid
  
  return 0
end
GO
