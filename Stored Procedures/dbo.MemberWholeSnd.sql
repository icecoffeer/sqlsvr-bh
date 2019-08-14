SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MemberWholeSnd]
  @StartTime datetime,
  @EndTime datetime,
  @Rcv int
as begin
	declare @gid int,@usergid int,@store int,@zbgid int
    select @usergid=usergid,@zbgid=zbgid from system(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
    if @rcv=0 
    begin
        declare cur_store cursor STATIC for
		select gid from store(nolock) where code like '01%' order by code
	    open cur_store
    end

	if @usergid = @zbgid 
      declare cur_mbrwhole cursor for
		select gid from Member 
		 where lstupdtime >= isnull(sndtime,'2000.01.01')
    else
      declare cur_mbrwhole cursor for
		select gid from Member 
		 where lstupdtime >= isnull(sndtime,'2000.01.01') and src=@usergid
	open cur_mbrwhole
	fetch next from cur_mbrwhole into @gid
	while @@Fetch_status = 0
	begin
		if @rcv=0
        begin
            fetch first from cur_store into @store
            while @@Fetch_status = 0
	        begin
                exec sendonembr @gid,@store,1
                fetch next from cur_store into @store
            end 
        end else        
          exec sendonembr @gid,@rcv,1

		fetch next from cur_mbrwhole into @gid
	end
	close cur_mbrwhole
	deallocate cur_mbrwhole

    if @rcv=0 
    begin
	    close cur_store
	    deallocate cur_store
    end
	return 0
end
GO
