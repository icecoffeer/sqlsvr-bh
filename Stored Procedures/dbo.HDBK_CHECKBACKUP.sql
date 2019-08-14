SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[HDBK_CHECKBACKUP]
	@ActSrv		varchar(25),
	@ActDB		varchar(25),
	@SettleNo	int
AS
BEGIN
	declare @masterno int,
		@collateno int,
		@tablename varchar(25),
		@style char(2),
		@anum	int,
		@bnum	int,
		@msg	varchar(25),
		@act	varchar(50),
		@b	datetime,
		@e	datetime,
		@begindate varchar(12),
		@enddate varchar(12),
		@sn	varchar(5),
		@p2	varchar(255),
		@strSQL	varchar(255),
		@I	int,
		@mastername varchar(25)
	set @act = @Actsrv + '.' + @ActDB + '.dbo.'
	set @sn = ltrim(str(@settleno))
	
	set nocount on
	if not exists (select 1 from master..sysservers where srvname=@actsrv)
	begin
		exec sp_addlinkedserver @server=@actsrv, @srvproduct='', @provider='SQLOLEDB', @datasrc=@actsrv, @catalog=@actdb
		exec sp_addlinkedsrvlogin @actsrv, 'false', null, 'App', '1The2quick3brown4fox5jumps6ove'
	end
	
	select @b=begindate, @e=enddate from monthsettle where no=@settleno
	if @b is null or @e is null
	begin
		print 'Invalid date, please check MONTHSETTLE'
		return
	end
	set @begindate = '''' + rtrim(convert(varchar(12), @b,102)) + ''''
	set @enddate = '''' + rtrim(convert(varchar(12), @e,102)) + ''''
	
	if object_id('#check') is not null drop table #check
	create table #check(num int)
	if object_id('c') is not null deallocate c
	declare c cursor for
	select master, tableName, style, no from [collate] where style in ('O', 'S', 'B', 'D', 'M', 'Y')
	open c
	fetch next from c into @masterno, @tablename, @style, @collateno
	while @@fetch_status = 0
	begin
		if @tablename = 'COLLATE' or @masterno = 301 or @tablename = 'LOG'
			or @tablename = 'CKLOG'
		begin
			print @tablename + '不检查'
		end
		else if @style = 'O' or @style = 'S'
		begin
			if @tablename = 'cashieroperate'
			begin
				delete from #check
				exec('insert into #check select count(*) from '
				+ @tablename + ' (nolock) where MONTHSETTLENO=' + @sn)
				select @anum = num from #check
				delete from #check
				exec('insert into #check select count(*) from '
				+ @act + @tablename + ' where MONTHSETTLENO=' + @sn)
				select @bnum = num from #check
				if @anum <> @bnum
					set @msg = '●'
				else
					set @msg = '　'
				print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
			end else begin
				delete from #check
				exec('insert into #check select count(*) from ' + @tablename + ' (nolock)')
				select @anum = num from #check
				delete from #check
				exec('insert into #check select count(*) from ' + @act + @tablename)
				select @bnum = num from #check
				if @anum <> @bnum
					set @msg = '●'
				else
					set @msg = '　'
				print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
			end
		end else if @style = 'B'
		begin
			select @mastername = tablename from [collate] where no=@masterno
			
			set @p2 = null
			set @strSQL = ''
			exec GetIndex @mastername, @p2 output
			if @p2 <> ''
			begin
				set @p2 = lower(@p2)     
				set @p2 = substring(@p2, 1, charindex(';', @p2)-1)
				set @I = charindex(' ', @p2 )
				while @I <> 0 
				begin
					set @strSQL = @strSQL + ' D.' + substring(@p2, 1, @I-1) + ' = M.'
						+ substring(@p2, 1, @I-1) + ' and '
					set @p2 = substring(@p2, @I+1, len(@p2)- @I)
					set @I = charindex(' ', @p2)
					set @p2 = substring(@p2, @I+1, len(@p2)- @I)
					set @I = charindex(' ', @p2)
			    	continue
				end
			end
			set @strSQL = @strSQL + ' 1 = 1 '
			
			if exists(select 1 from collateitem where fieldname='FILDATE' and collateno=@masterno)
			begin
				if @collateno <> @masterno
				begin
					delete from #check
					exec('insert into #check select count(*) from '
					+ @tablename + ' D (nolock), ' + @mastername + ' M (nolock) '
					+ ' where ' + @strSQL
					+ ' and M.Fildate between ' + @begindate + ' and ' + @enddate)
					select @anum = num from #check
					delete from #check
					exec('insert into #check select count(*) from '
					+ @act + @tablename + ' D, ' + @act + @mastername + ' M '
					+ ' where ' + @strSQL
					+ ' and M.Fildate between ' + @begindate + ' and ' + @enddate)
					select @bnum = num from #check
					if @anum <> @bnum
						set @msg = '●'
					else
						set @msg = '　'
					print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
				end else begin
					delete from #check
					exec('insert into #check select count(*) from '
					+ @tablename + ' (nolock) where Fildate between ' + @begindate + ' and ' + @enddate)
					select @anum = num from #check
					delete from #check
					exec('insert into #check select count(*) from '
					+ @act + @tablename + ' where Fildate between ' + @begindate + ' and ' + @enddate)
					select @bnum = num from #check
					if @anum <> @bnum
						set @msg = '●'
					else
						set @msg = '　'
					print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
				end
			end else if exists(select 1 from collateitem where fieldname='SETTLENO' and collateno=@masterno)
			begin
				if @collateno <> @masterno
				begin
					delete from #check
					exec('insert into #check select count(*) from '
					+ @tablename + ' D (nolock), ' + @mastername + ' M (nolock) '
					+ ' where ' + @strSQL
					+ ' and M.settleno=' + @sn)
					select @anum = num from #check
					delete from #check
					exec('insert into #check select count(*) from '
					+ @act + @tablename + ' D, ' + @act + @mastername + ' M '
					+ ' where ' + @strSQL
					+ ' and M.settleno=' + @sn)
					select @bnum = num from #check
					if @anum <> @bnum
						set @msg = '●'
					else
						set @msg = '　'
					print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
				end else begin
					delete from #check
					exec('insert into #check select count(*) from '
					+ @tablename + ' (nolock) where settleno=' + @sn)
					select @anum = num from #check
					delete from #check
					exec('insert into #check select count(*) from '
					+ @act + @tablename + ' where settleno=' + @sn)
					select @bnum = num from #check
					if @anum <> @bnum
						set @msg = '●'
					else
						set @msg = '　'
					print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
				end
			end else begin
				delete from #check
				exec('insert into #check select count(*) from ' + @tablename + ' (nolock)')
				select @anum = num from #check
				delete from #check
				exec('insert into #check select count(*) from ' + @act + @tablename)
				select @bnum = num from #check
				if @anum <> @bnum
					set @msg = '●'
				else
					set @msg = '　'
				print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
			end
		end else if @style = 'D'
		begin
			delete from #check
			exec('insert into #check select count(*) from '
			+ @tablename + ' (nolock) where adate between ' + @begindate + ' and ' + @enddate)
			select @anum = num from #check
			delete from #check
			exec('insert into #check select count(*) from '
			+ @act + @tablename + ' where adate between ' + @begindate + ' and ' + @enddate)
			select @bnum = num from #check
			if @anum <> @bnum
				set @msg = '●'
			else
				set @msg = '　'
			print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
		end else if @style = 'M' or @style = 'Y'
		begin
			delete from #check
			exec('insert into #check select count(*) from '
			+ @tablename + ' (nolock) where asettleno=' + @sn)
			select @anum = num from #check
			delete from #check
			exec('insert into #check select count(*) from '
			+ @act + @tablename + ' where asettleno=' + @sn)
			select @bnum = num from #check
			if @anum <> @bnum
				set @msg = '●'
			else
				set @msg = '　'
			print @msg + '[' + @tablename + '] CURRENT: '+ ltrim(str(@anum)) + ', REAL: ' + ltrim(str(@bnum))
		end
		fetch next from c into @masterno, @tablename, @style, @collateno
	end
	close c
	deallocate c
	drop table #check

	exec sp_droplinkedsrvlogin @actsrv, null
	exec sp_dropserver @server=@actsrv
END
GO
