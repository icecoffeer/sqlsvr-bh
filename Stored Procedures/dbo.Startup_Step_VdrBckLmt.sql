SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Startup_Step_VdrBckLmt]  
as  
begin  
  declare  
    @opt_BckWrh int, @store int, @gid int,  
    @total money, @LastAmt money  
  
  exec OptReadInt 0, 'EXPCTRL_BCKWRHGID', 1, @opt_BckWrh output  
  select @store = usergid from system(nolock)  
  
  declare c_vendor cursor for  
    select gid from vendor(nolock) where isnull(BCKCYCLETYPE, 0) <> 0  
  open c_vendor  
    fetch next from c_vendor into @gid  
  
  while @@fetch_status = 0  
  begin  
    select @total = sum(total) from inv i(nolock), goods g(nolock) where i.store = @store  
      and i.wrh = @opt_BckWrh and g.BILLTO = @gid and g.gid = i.gdgid  
    if @total is null set @total = 0  
    select @LastAmt = sum(AMT - PYTOTAL) from PAY(nolock) where BILLTO = @gid and stat = 1  
    if @LastAmt is null set @LastAmt = 0  
    if @total > @LastAmt  
      update vendor set BCKLMT = 1 where gid = @gid  
  fetch next from c_vendor into @gid  
  end  
  close c_vendor  
  deallocate c_vendor
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_VdrBckLmt', 0, ''   --合并日结  
end  

GO
