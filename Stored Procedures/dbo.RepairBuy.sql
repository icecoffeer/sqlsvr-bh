SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RepairBuy](
	@p_database varchar(30),
	@p_posno varchar(10)
) as 
begin
	declare @posno char(10), @flowno char(12), @tag int, @rtlproc smallint
	
	select @rtlproc = RTLPROC from WORKSTATION where NO = @p_posno
	update WORKSTATION set RTLPROC = 0 where NO = @p_posno
	
	-- 处理机号不符合的交易
	exec('declare c cursor for select POSNO, FLOWNO from '
		+ @p_database + '..BUY1_' + @p_posno 
		+ ' where POSNO <> ''' + @p_posno + ''' for update')
	open c
	fetch next from c into @posno, @flowno
	while @@fetch_status = 0
	begin
		exec rb_delete @p_database, @p_posno, @posno, @flowno, '机号不符合。'
		fetch next from c into @posno, @flowno
	end
	close c
	deallocate c
	
	-- 逐交易进行处理
	exec('declare c cursor for select FLOWNO, TAG from '
		+ @p_database + '..BUY1_' + @p_posno
		+ ' where TAG <> 0 for update')
	open c
	fetch next from c into @flowno, @tag
	while @@fetch_status = 0
	begin
		exec ('insert into rb_BUY1'
			+ ' select * from ' + @p_database + '..BUY1_' + @p_posno
			+ ' where FLOWNO = ''' + @flowno + '''')
		exec ('insert into rb_BUY11'
			+ ' select * from ' + @p_database + '..BUY11_' + @p_posno
			+ ' where FLOWNO = ''' + @flowno + '''')
		exec ('insert into rb_BUY2'
			+ ' select * from ' + @p_database + '..BUY2_' + @p_posno
			+ ' where FLOWNO = ''' + @flowno + '''')
		exec ('insert into rb_BUY21'
			+ ' select * from ' + @p_database + '..BUY21_' + @p_posno
			+ ' where FLOWNO = ''' + @flowno + '''')
			
		if @tag = 11
		begin
			if (select FILDATE from rb_BUY1 where POSNO = @p_posno and FLOWNO = @flowno)
				= (select FILDATE from BUY1 where POSNO = @p_posno and FLOWNO = @flowno)
				exec rb_delete @p_database, @p_posno, @p_posno, @flowno, '交易已经加工。'
			else
				exec rb_UpdFlowno @p_database, @p_posno, @flowno, @tag
		end
		else if @tag = 15
			exec rb_Fix15 @p_database, @p_posno, @flowno, @tag
		else if @tag = 16
			exec rb_Fix16 @p_database, @p_posno, @flowno, @tag
		else if @tag = 17
			exec rb_Fix17 @p_database, @p_posno, @flowno, @tag
		else if @tag = 18
			exec rb_Fix18 @p_database, @p_posno, @flowno, @tag
			
		exec ('delete from rb_BUY1 where POSNO = ''' 
			+ @p_posno + ''' and FLOWNO = ''' + @flowno + '''')
		exec ('delete from rb_BUY11 where POSNO = ''' 
			+ @p_posno + ''' and FLOWNO = ''' + @flowno + '''')
		exec ('delete from rb_BUY2 where POSNO = ''' 
			+ @p_posno + ''' and FLOWNO = ''' + @flowno + '''')
		exec ('delete from rb_BUY21 where POSNO = ''' 
			+ @p_posno + ''' and FLOWNO = ''' + @flowno + '''')
		fetch next from c into @flowno, @tag
	end
	close c
	deallocate c

	update WORKSTATION set RTLPROC = @rtlproc where NO = @p_posno
	
end
GO
