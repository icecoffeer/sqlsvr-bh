SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsPrmMbrPrc]
  @store int,
  @gdgid int,
  @curtime datetime,
  @qty money,
  @prmmbrprc money output,
  @QpcStr varchar(20) = '1*1'
as begin
  declare @return_status int,  @storegid int,
          @prm int,            @rtlprc money,       @mbrprc money,
          @start datetime,     @finish datetime,    @cycle datetime,
          @cstart datetime,    @cfinish datetime,   @mod float,
          @qtylo money,        @qtyhi money,        @price money

  select @return_status = 0
  select @storegid = usergid from system

  if @store = @storegid
     select @prm = QPCPROMOTE, @rtlprc=QPCRTLPRC, @mbrprc=QPCMBRPRC from V_QPCGOODS(nolock)
     where gid = @gdgid and QPCQPCSTR = @QpcStr
  else
     select @prm = QPCPROMOTE, @rtlprc=QPCRTLPRC, @mbrprc=QPCMBRPRC from V_QPCGDSTORE(nolock)
     where storegid = @store and gdgid = @gdgid and QPCQPCSTR = @QpcStr

  if @mbrprc is null select @mbrprc = @rtlprc

  if @prm is null or @prm < 0
  begin
     select @return_status = 1
     return(@return_status)
  end

  select @prmmbrprc = @mbrprc

  declare c_prm cursor for
    select start, finish, cycle, cstart, cfinish, qtylo, qtyhi, price, mbrprc
     from price
     where gdgid = @gdgid and storegid = @store and QPCSTR = @QpcStr
  open c_prm
  fetch next from c_prm into @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi, @price, @mbrprc
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

     if @mbrprc is not null
     begin
        select @prmmbrprc = @mbrprc
        close c_prm
        deallocate c_prm
        select @return_status = 0
        return(@return_status)
     end
     else if @price is not null
     	begin
        select @prmmbrprc = @price
        close c_prm
        deallocate c_prm
        select @return_status = 0
        return(@return_status)
     	end;

nextline:
     fetch next from c_prm into @start, @finish, @cycle, @cstart, @cfinish, @qtylo, @qtyhi, @price, @mbrprc
  end
  close c_prm
  deallocate c_prm

  select @return_status = 1
  return(@return_status)
end
GO
