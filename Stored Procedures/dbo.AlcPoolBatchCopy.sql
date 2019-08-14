SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolBatchCopy](
	@srcstore int,
	@deststore int,
	@goodscond varchar(255),
	@dmddate varchar(20),
	@srcgrps smallint,
	@options smallint
)
as
begin
	declare @sqlstr varchar(2048), @srcgrp varchar(10), @tempstr varchar(255)
	if (@srcgrps & 1 <> 1) and (@srcgrps & 2 <> 2) and (@srcgrps & 4 <> 4) return (0)
	set @srcgrp = ''
	if @srcgrps & 1 = 1
		set @srcgrp = @srcgrp + '1,'
	if @srcgrps & 2 = 2
		set @srcgrp = @srcgrp + '2,'
	if @srcgrps & 4 = 4
		set @srcgrp = @srcgrp + '3,'
	set @srcgrp = left(@srcgrp, len(@srcgrp) - 1)

	--覆盖目标门店的配货信息
	if @options & 1 = 1
	begin
		set @tempstr = ''
		if @dmddate is not null and @dmddate <> ''
			set @tempstr = @tempstr + ' and dmddate = ' + '''' + @dmddate + ''''
		if @goodscond is not null and @goodscond <> ''
			set @tempstr = @tempstr + ' and gdgid in (select gid from goods where ' + @goodscond + ')'

		if @srcgrps & 1 = 1
		begin
			set @sqlstr = 'if exists(select 1 from alcpool where storegid = '
				+ rtrim(convert(varchar(20), @srcstore))
				+ ' and srcgrp = 1'
			if @tempstr <> ''
				set @sqlstr = @sqlstr + @tempstr
			set @sqlstr = @sqlstr + ') '
				+ 'delete from alcpool where storegid = '
				+ rtrim(convert(varchar(20), @deststore))
				+ ' and srcgrp = 1 '
			if @tempstr <> ''
				set @sqlstr = @sqlstr + @tempstr
			exec(@sqlstr)
		end

		if @srcgrps & 2 = 2
		begin
			set @sqlstr = 'if exists(select 1 from alcpool where storegid = '
				+ rtrim(convert(varchar(20), @srcstore))
				+ ' and srcgrp = 2'
			if @tempstr <> ''
				set @sqlstr = @sqlstr + @tempstr
			set @sqlstr = @sqlstr + ') '
				+ 'delete from alcpool where storegid = '
				+ rtrim(convert(varchar(20), @deststore))
				+ ' and srcgrp = 2 '
			if @tempstr <> ''
				set @sqlstr = @sqlstr + @tempstr
			exec(@sqlstr)
		end

		if @srcgrps & 4 = 4
		begin
			set @sqlstr = 'if exists(select 1 from alcpool where storegid = '
				+ rtrim(convert(varchar(20), @srcstore))
				+ ' and srcgrp = 3'
			if @tempstr <> ''
				set @sqlstr = @sqlstr + @tempstr
			set @sqlstr = @sqlstr + ') '
				+ 'delete from alcpool where storegid = '
				+ rtrim(convert(varchar(20), @deststore))
				+ ' and srcgrp = 3 '
			if @tempstr <> ''
				set @sqlstr = @sqlstr + @tempstr
			exec(@sqlstr)
		end
	end

	--复制源门店配货信息到目标门店
	set @sqlstr = 'declare @gdgid int, @srcgrp smallint, @baseline int '
		+ ' if object_id(' + '''' + 'c_alcpool' + '''' + ') is not null '
		+ ' deallocate c_alcpool '
		+ ' declare c_alcpool cursor for'
		+ ' select distinct gdgid, srcgrp from alcpool'
		+ ' where storegid = ' + rtrim(convert(varchar(20), @srcstore))
	if @goodscond is not null and @goodscond <> ''
		set @sqlstr = @sqlstr + ' and gdgid in (select gid from goods where ' + @goodscond + ')'
	if @dmddate is not null and @dmddate <> ''
		set @sqlstr = @sqlstr + ' and dmddate = ' + '''' + @dmddate + ''''
	set @sqlstr = @sqlstr + ' and srcgrp in (' + @srcgrp + ')'
		+ ' open c_alcpool '
		+ ' fetch next from c_alcpool into @gdgid, @srcgrp '
		+ ' while @@fetch_status = 0 '
		+ ' begin '
			+ ' if not exists(select 1 from alcpool(nolock) where storegid = '
			+ rtrim(convert(varchar(20), @deststore))
			+ ' and gdgid = @gdgid and srcgrp = @srcgrp)'
			+ ' begin'
				+ ' select @baseline = max(line) from alcpool(nolock) where storegid = '
				+ rtrim(convert(varchar(20), @deststore))
				+ ' and gdgid = @gdgid'
				+ ' if @baseline is null set @baseline = 0'
				+ ' insert into alcpool(storegid, gdgid, line, qty, dmddate, srcgrp, srcbill, ordtime) '
				+ ' select ' + rtrim(convert(varchar(20), @deststore))
				+ ', @gdgid, @baseline + line, qty, dmddate, srcgrp, srcbill, getdate()'
				+ ' from alcpool(nolock) where storegid = '
				+ rtrim(convert(varchar(20), @srcstore))
				+ ' and gdgid = @gdgid and srcgrp = @srcgrp'
			+ ' end'
		+ '   fetch next from c_alcpool into @gdgid, @srcgrp '
		+ ' end '
		+ ' close c_alcpool '
		+ ' deallocate c_alcpool '

	exec(@sqlstr)

	return (0)
end
GO
