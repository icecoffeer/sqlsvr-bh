SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[rb_Fix18](
	@p_database varchar(30),
	@p_posno varchar(10),
	@p_flowno varchar(12),
	@tag int
) as
begin
	declare @itemno smallint, @m_favamt money, @d_favamt money,
		@d_amt money,
		@sql varchar(255)
	
	begin transaction
	
	declare c18 cursor for 
		select m.ITEMNO, m.FAVAMT, sum(d.FAVAMT)
		from rb_BUY2 m, rb_BUY21 d
		where m.POSNO = d.POSNO and m.FLOWNO = d.FLOWNO 
		and m.ITEMNO = d.ITEMNO
		group by m.POSNO, m.FLOWNO, m.ITEMNO, m.FAVAMT
		having m.FAVAMT <> sum(d.FAVAMT)
		for read only
	open c18
	fetch next from c18 into @itemno, @m_favamt, @d_favamt
	while @@fetch_status = 0
	begin
		select @d_amt = 0
		select @d_amt = FAVAMT from rb_BUY21
			where POSNO = @p_posno and FLOWNO = @p_flowno 
			and ITEMNO = @itemno and FAVTYPE = '13'
--		if @@rowcount <> 0
		if exists (select 1 from rb_BUY21
			where POSNO = @p_posno and FLOWNO = @p_flowno 
			and ITEMNO = @itemno and FAVTYPE = '13')
			select @sql = 'update ' + @p_database + '..BUY21_' + @p_posno
				+ ' set FAVAMT = ' + convert(varchar, @d_amt + (@m_favamt - @d_favamt), 2)
				+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + ''''
				+ ' and ITEMNO = ' + convert(varchar, @itemno)
				+ ' and FAVTYPE = ''13'''
		else
			select @sql = 'insert into ' + @p_database + '..BUY21_' + @p_posno
				+ ' (POSNO, FLOWNO, ITEMNO, FAVTYPE, FAVAMT, TAG)'
				+ ' values (''' + @p_posno + ''', ''' + @p_flowno + ''','
				+ ' ' + convert(varchar, @itemno) + ', ''13'','
				+ ' ' + convert(varchar, @d_amt + (@m_favamt - @d_favamt), 2) + ','
				+ ' ' + '0)'
		exec (@sql)
		fetch next from c18 into @itemno, @m_favamt, @d_favamt
	end
	close c18
	deallocate c18
	
	exec ('update ' + @p_database + '..BUY1_' + @p_posno
		+ ' set TAG = 0'
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	
	commit transaction
	
	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
		TYPE, CONTENT)
		values (getdate(), 'REPAIRBUY', '',	'REPAIRBUY', 101, 
		'修复' + @p_posno + '号机的交易(FlowNo=' + @p_flowno
		+ '，原因：' + convert(char(2), @tag))
	waitfor delay '0:0:1'
end
GO
