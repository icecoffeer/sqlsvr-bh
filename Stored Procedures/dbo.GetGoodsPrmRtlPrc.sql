SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsPrmRtlPrc]
  @store int, 
  @gdgid int, 
  @curtime datetime,
  @qty money,
  @prmrtlprc money output 
as begin
  declare @return_status int,  @storegid int,
          @prm int,            @rtlprc money,
          @start datetime,     @finish datetime,    @cycle datetime,
          @cstart datetime,    @cfinish datetime,   @mod float,
          @qtylo money,        @qtyhi money

  select @return_status = 0
  select @storegid = usergid from system

  if @store = @storegid
     select @prm = Promote, @rtlprc=Rtlprc from Goods where gid = @gdgid
  else
     select @prm = Promote, @rtlprc=Rtlprc from GdStore where storegid = @store and gdgid = @gdgid

  if @prm is null or @prm < 0
  begin
     select @return_status = 1
     return(@return_status)
  end
  
  select @prmrtlprc = @rtlprc

  declare c_prm cursor for
    select start, finish, cycle, cstart, cfinish, qtylo, qtyhi, price
     from price
     where gdgid = @gdgid and storegid = @store
  open c_prm
  fetch next from c_prm into @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi, @rtlprc
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
        select @prmrtlprc = @rtlprc
        close c_prm
        deallocate c_prm
        select @return_status = 0
        return(@return_status)
     end

nextline:
     fetch next from c_prm into @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi, @rtlprc
  end
  close c_prm
  deallocate c_prm

  select @return_status = 1
  return(@return_status)
end
GO
