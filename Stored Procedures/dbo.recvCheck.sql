SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[recvCheck] 
   @strStore varchar(13)
as
begin
   declare @posno varchar(13),@gdgid int, @storegid int

   select @storeGid = gid from store where code = @strStore

   if not exists (select 1 from ckinv where wrh = @storeGid ) 
   begin
       exec GdDRptRcvAll @strstore
       exec mSnapInv @strStore 
   end

   declare c_cursor cursor for
      select posno,gdgid from mckpool
          where posno = @strStore
   open c_cursor
   fetch next from c_cursor into @posno,@gdgid
   while @@fetch_status = 0 
   begin 
      begin transaction
      exec mpcks  @posno,@gdgid
      if @@error <> 0
      begin
         rollback transaction
         fetch next from c_cursor into @posno,@gdgid
         continue
      end
      delete from mckpool where posno = @posno and gdgid = @gdgid
      commit transaction
      fetch next from c_cursor into @posno,@gdgid
   end 
   close c_cursor
   deallocate c_cursor
end

GO
