SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MemberWholeRcv]
as begin
	declare @src int,@id int

	declare cur_nmbr cursor for
		select src,id from NMember 
		where ntype = 1
	open cur_nmbr
	fetch next from cur_nmbr into @src,@id
	while @@Fetch_status = 0
	begin
		exec NMemberRcv @id,@src
		fetch next from cur_nmbr into @src,@id
	end
	close cur_nmbr
	deallocate cur_nmbr
	return 0
end
GO
