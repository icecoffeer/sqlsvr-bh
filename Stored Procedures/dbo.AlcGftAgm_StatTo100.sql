SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[AlcGftAgm_StatTo100]
(
  @piNum          char(14),
  @piToStat       int,
  @piOper         varchar(40),
  @poErrmsg       varchar(255) output  
)
with Encryption
as
begin
  declare 
    @line int, 
    @start datetime,
    @finish datetime,
    @alcgid int,
    @gdgid int,
    @gftgid int,
    @alcqty money,
    @gftqty money,
    @gftlmtqty money
  
  --数据检查  
  declare c_AlcGftAgm cursor for 
    select distinct line, start, finish from AlcGftAgmDtl where num = @piNum
  open c_AlcGftAgm
  fetch next from c_AlcGftAgm into @line, @start, @finish
  while @@fetch_status = 0
  begin  
    if @finish <= getdate() 
    begin
      set @poErrmsg = '第' + convert(varchar(5), @line) + '行' + '结束时间不能小于现在时间。'
      close c_AlcGftAgm
      deallocate c_AlcGftAgm
      return(11)
    end 
    if @start > @finish 
    begin
      set @poErrmsg = '第' + convert(varchar(5), @line) + '行' + '开始时间不能小于结束时间。'
      close c_AlcGftAgm
      deallocate c_AlcGftAgm
      return(12)
    end
    fetch next from c_AlcGftAgm into @line, @start, @finish
  end
  close c_AlcGftAgm
  deallocate c_AlcGftAgm
  
  set @start = null
  set @finish = null
  select @alcgid = alcgid from alcgftagm(nolock) where num = @piNum
  
  declare c_AlcGftAgm cursor for
    select line, gdgid, alcqty, start, finish, gftgid, gftqty, gftlmtqty 
    from AlcGftAgmDtl where num = @piNum
  open c_AlcGftAgm
  fetch next from c_AlcGftAgm into 
    @line, @gdgid, @alcqty, @start, @finish, @gftgid, @gftqty, @gftlmtqty
  while @@fetch_status = 0
  begin
    insert into AlcGft (alcgid, start, finish, gdgid, alcqty, gftgid, gftqty, gftlmtqty, srcnum, srcline)
    values (@alcgid, @start, @finish, @gdgid, @alcqty, @gftgid, @gftqty, @gftlmtqty, @piNum, @line)
    fetch next from c_AlcGftAgm into 
      @line, @gdgid, @alcqty, @start, @finish, @gftgid, @gftqty, @gftlmtqty
  end
  close c_AlcGftAgm
  deallocate c_AlcGftAgm
    
  update AlcGftAgm set Checker = @piOper, ChkDate = getdate(), Stat = @piToStat
  where num = @piNum
  return(0)
end
GO
