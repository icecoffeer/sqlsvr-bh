SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetStoreOutPrc](
	@storegid	int,
	@gdgid	int,
	@wrh	int,
	@outprc	money	output
)
with encryption as
begin
	declare
		@prcstr varchar(100),
		@prmprc	money,
		@invprc	money,
		@outprcmode smallint,
		@v2 smallint,
		@sqlstr	varchar(1024),
		@i	smallint,
		@novar	smallint,
		@fieldname	varchar(32),
		@curdate	datetime

	select @prcstr = outprc from store(nolock) where gid = @storegid
	if @prcstr is null or @prcstr = ''
	begin
		set @outprc = 0
		return 0
	end

	if charindex('prmprc', @prcstr) > 0
	begin
		select @curdate = getdate()
		exec GetGoodsPrmPrc @storegid, @gdgid, @curdate, 1, @prmprc output
		select @prcstr = replace(@prcstr, 'prmprc', convert(varchar(20), @prmprc))
	end else if charindex('invprc', @prcstr) > 0
	begin
		exec OptReadInt 0, 'AvgInvPrc_V2', 0, @v2 output
		if @v2 <> 0
		begin
			exec GetGoodsInvPrc @gdgid, @wrh, @invprc output
			select @prcstr = replace(@prcstr, 'invprc', convert(varchar(20), @invprc))
		end
	end

	set @novar = 1
	set @i = 1
	while @i <= len(@prcstr)
	begin
		if substring(@prcstr, @i, 1) not in ('0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', '+', '-', '*', '/', '.')
		begin
			set @novar = 0
			break
		end
		set @i = @i + 1
	end
	if @novar = 1
		set @sqlstr = 'declare c_prc cursor for select ' + @prcstr
	else begin
		select @outprcmode = outprcmode from system(nolock)
		if exists(select 1 from gdstore(nolock)
			where storegid = @storegid
				and gdgid = @gdgid)
			and (@outprcmode = 0)
		begin
			if object_id('c_syscolumns') is not null deallocate c_syscolumns
			declare c_syscolumns cursor for
			select name from syscolumns(nolock)
			where id = object_id('gdstore')
			open c_syscolumns
			fetch next from c_syscolumns into @fieldname
			while @@fetch_status = 0
			begin
				set @i = charindex(@fieldname, @prcstr)
				if @i > 1
					if not substring(@prcstr, @i - 1, 1) in (' ','(','-','+','/','*')
						set @i = 0
				if @i > 0 and @i + len(@fieldname) - 1 <> len(@prcstr)
					if not substring(@prcstr, @i + len(@fieldname), 1) in (' ',')','-','+','/','*')
						set @i = 0
				if @i > 0
					select @prcstr = substring(@prcstr, 1, @i - 1)
						+ 'gdstore.' + @fieldname
						+ substring(@prcstr, @i + len(@fieldname), len(@prcstr))
				fetch next from c_syscolumns into @fieldname
			end
			close c_syscolumns
			deallocate c_syscolumns

			set @sqlstr = 'declare c_prc cursor for '
				+ ' select ' + @prcstr + ' from goodsh, gdstore(nolock) '
				+ ' where goodsh.gid = ' + str(@gdgid)
				+ ' and gdstore.storegid = ' + str(@storegid)
				+ ' and goodsh.gid = gdstore.gdgid'
		end else begin
			set @sqlstr = 'declare c_prc cursor for '
				+ ' select ' + @prcstr + ' from goodsh(nolock) '
				+ ' where gid = ' + str(@gdgid)
		end
	end

	exec(@sqlstr)
	open c_prc
	fetch next from c_prc into @outprc
	close c_prc
	deallocate c_prc
	if @outprc is null
		set @outprc = 0

	return (0)
end
GO
