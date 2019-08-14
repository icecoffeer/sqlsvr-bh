SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GenPrmGDList]
  @store int, 
  @curtime datetime
as 
begin
	declare @qty int, @gdgid int
  declare @return_status int,  @storegid int,
          @prm int,            @rtlprc money,
          @start datetime,     @finish datetime,    @cycle datetime,
          @cstart datetime,    @cfinish datetime,   @mod float,
          @qtylo money,        @qtyhi money
  set @qty = 1
  select @return_status = 0
  select @storegid = usergid from system

  --清除历史数据
  delete from SteelYardPrmGD where finish < getdate()-3
  
  declare c_prm cursor for
    select distinct(p.gdgid) from price p, gdinput gdi(nolock)
     where storegid = @store and start < @curtime and finish > @curtime
       and gdi.gid = p.gdgid and gdi.codetype <> 0 
       --and 不在发送列表。
  open c_prm
  fetch next from c_prm into @gdgid
  
  while @@fetch_status = 0
  begin
		  if @store = @storegid
		     select @prm = Promote, @rtlprc=Rtlprc from Goods where gid = @gdgid
		  else
		     select @prm = Promote, @rtlprc=Rtlprc from GdStore where storegid = @store and gdgid = @gdgid
		
		  if @prm is null or @prm < 0
		  begin
		     goto nextlineout
		  end
		  
		  declare c_prmdtl cursor for
		    select start, finish, cycle, cstart, cfinish, qtylo, qtyhi, price
		     from price
		     where gdgid = @gdgid and storegid = @store
		     
		  open c_prmdtl
		  fetch next from c_prmdtl into @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi, @rtlprc
		  while @@fetch_status = 0
		  begin
		     if (@prm & 1) = 1
		     begin
		        if @curtime < @start goto nextline
		        if @curtime > @finish goto nextline 

		        if (@prm & 2) = 2
		        begin
		           if convert(float,@cycle)+2 <= 0 goto nextline
		           select @mod = convert(float,@curtime) - convert(float,@start)
		           select @mod = @mod - (floor(@mod / (convert(float,@cycle)+2))) * (convert(float,@cycle)+2)
		           if (@mod < (convert(float,@cstart)+2)) and (@mod < (convert(float,@cfinish)+2)) goto nextline
		           if (@mod > (convert(float,@cstart)+2)) and (@mod > (convert(float,@cfinish)+2)) goto nextline
		        end
		     end
		
		     if (@prm & 4) = 4
		     begin
		        if @qty < @qtylo goto nextline
		        if @qty > @qtyhi goto nextline 
		     end
		     if @rtlprc is not null
		     begin
		     	  if not exists(select 1 from SteelYardPrmGD where gdgid = @gdgid and storegid = @store
		     	    and start = @start and finish = @finish and cycle = @cycle 
		     	    and cstart = @cstart and cfinish = @cfinish and qtylo = @qtylo and qtyhi = @qtyhi
		     	  )
			     	  insert into SteelYardPrmGD(gdgid, storegid, sendflag, curtime, price,
			     	    start, finish, cycle, cstart, cfinish, qtylo, qtyhi) 
			     	  values(@gdgid, @store, 0, @curtime, @rtlprc,
			     	    @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi)
            break 
		     end
		     nextline:
		     fetch next from c_prmdtl into @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi, @rtlprc
		  end
		  close c_prmdtl
		  deallocate c_prmdtl
		 nextlineout: 
     fetch next from c_prm into @gdgid
  end
  close c_prm
  deallocate c_prm

  select @return_status = 0
  return(@return_status)
end
GO
