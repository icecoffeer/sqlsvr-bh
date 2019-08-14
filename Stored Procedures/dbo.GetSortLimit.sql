SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetSortLimit] (
	@sort varchar(13),	
	@intret smallint output,
	@strMsg varchar(100) output
) as
begin
	declare @sortlimit int,
		@alen int,
		@blen int,
		@clen int,
        @dlen int,
		@limitcount int,
		@nowcount int,
		@ctrlsort varchar(13),
		@sortname varchar(36)
		
	set @intret = 0
	exec OPTREADINT 0, 'SortLimit', 0, @sortlimit output
	if @sortlimit = 0 return

	select @alen = ALEN, @blen = BLEN, @clen = CLEN, @dlen = DLEN from SYSTEM (nolock)

	-- if @sortlimit in (1, 4, 5, 7) and len(@sort) >= @alen
    IF (@sortlimit & 1 = 1) AND (LEN(@sort) >= @alen)
	begin
		set @ctrlsort = left(@sort, @alen)
		select @limitcount = GDCOUNT, @sortname = NAME from SORT where CODE = @ctrlsort
		if @limitcount is null
		begin
			set @intret = 1
			set @strMsg = '不存在大类' + @ctrlsort
			return
		end else if @limitcount = -1
		begin
			set @intret = 0
		end else begin
			select @nowcount = count(*) from GOODS (nolock) where SORT like @ctrlsort + '%' and isnull(ISLTD, 0) & 2 <> 2 and isnull(ISLTD, 0) & 8 <> 8
			if @nowcount > @limitcount
			begin
				set @intret = 1
				set @strMsg = '大类' + @ctrlsort + '[' + rtrim(@sortname) + '] 限制品种数: ' + ltrim(str(@limitcount))
					+ ', 当前非限制定货/非清场品种数: ' + ltrim(str(@nowcount))
				return
			end else begin
				set @intret = 0
			end
		end			
	end
	
	-- if @sortlimit in (2, 4, 6, 7) and len(@sort) >= @alen + @blen
    IF (@sortlimit & 2 = 2) AND (LEN(@sort) >= @alen + @blen)
	begin
		set @ctrlsort = left(@sort, @alen + @blen)
		select @limitcount = GDCOUNT, @sortname = NAME from SORT where CODE = @ctrlsort
		if @limitcount is null
		begin
			set @intret = 1
			set @strMsg = '不存在中类' + @ctrlsort
			return
		end else if @limitcount = -1
		begin
			set @intret = 0
		end else begin
			select @nowcount = count(*) from GOODS (nolock) where SORT like @ctrlsort + '%' and isnull(ISLTD, 0) & 2 <> 2 and isnull(ISLTD, 0) & 8 <> 8
			if @nowcount > @limitcount
			begin
				set @intret = 1
				set @strMsg = '中类' + @ctrlsort + '[' + rtrim(@sortname) + '] 限制品种数: ' + ltrim(str(@limitcount))
					+ ', 当前非限制定货/非清场品种数: ' + ltrim(str(@nowcount))
				return
			end else begin
				set @intret = 0
			end
		end			
	end

	-- if @sortlimit in (3, 5, 6, 7) and len(@sort) >= @alen + @blen + @clen
    IF (@sortlimit & 4 = 4) AND (LEN(@sort) >= @alen + @blen + @clen)
	begin
		set @ctrlsort = left(@sort, @alen + @blen + @clen)
		select @limitcount = GDCOUNT, @sortname = NAME from SORT where CODE = @ctrlsort
		if @limitcount is null
		begin
			set @intret = 1
			set @strMsg = '不存在小类' + @ctrlsort
			return
		end else if @limitcount = -1
		begin
			set @intret = 0
		end else begin
			select @nowcount = count(*) from GOODS (nolock) where SORT like @ctrlsort + '%' and isnull(ISLTD, 0) & 2 <> 2 and isnull(ISLTD, 0) & 8 <> 8
			if @nowcount > @limitcount
			begin
				set @intret = 1
				set @strMsg = '小类' + @ctrlsort + '[' + @sortname + '] 限制品种数: ' + ltrim(str(@limitcount))
					+ ', 当前非限制定货/非清场品种数: ' + ltrim(str(@nowcount))
				return
			end else begin
				set @intret = 0
			end
		end			
	end

    IF (@sortlimit & 8 = 8) AND (LEN(@sort) >= @alen + @blen + @clen + @dlen)
	begin
		set @ctrlsort = left(@sort, @alen + @blen + @clen + @dlen)
		select @limitcount = GDCOUNT, @sortname = NAME from SORT where CODE = @ctrlsort
		if @limitcount is null
		begin
			set @intret = 1
			set @strMsg = '不存在细类' + @ctrlsort
			return
		end else if @limitcount = -1
		begin
			set @intret = 0
		end else begin
			select @nowcount = count(*) from GOODS (nolock) where SORT like @ctrlsort + '%' and isnull(ISLTD, 0) & 2 <> 2 and isnull(ISLTD, 0) & 8 <> 8
			if @nowcount > @limitcount
			begin
				set @intret = 1
				set @strMsg = '细类' + @ctrlsort + '[' + @sortname + '] 限制品种数: ' + ltrim(str(@limitcount))
					+ ', 当前非限制定货/非清场品种数: ' + ltrim(str(@nowcount))
				return
			end else begin
				set @intret = 0
			end
		end			
	end
end
GO
