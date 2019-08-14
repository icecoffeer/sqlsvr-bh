SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[rb_Fix15](
	@p_database varchar(30),
	@p_posno varchar(10),
	@p_flowno varchar(12),
	@tag int
) as
begin
	declare
		@d_prevamt money, @d_change money,
		@m_prevamt money, @m_change money,
		@itemno smallint, @sql varchar(255)
	
	select @d_prevamt = isnull(sum(AMOUNT), 0) from rb_BUY11
		where POSNO = @p_posno and FLOWNO = @p_flowno and CURRENCY <> -1
	if @d_prevamt = 0 return (0)
	select @d_change = isnull(AMOUNT, 0) from rb_BUY11
		where POSNO = @p_posno and FLOWNO = @p_flowno and CURRENCY = -1
	select @m_change = PREVAMT - REALAMT, @m_prevamt = PREVAMT
		from rb_BUY1
		where POSNO = @p_posno and FLOWNO = @p_flowno
		
	if @d_change <> @m_change
	begin
		begin transaction
		exec ('update ' + @p_database + '..BUY1_' + @p_posno
			+ ' set TAG = 0'
			+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
		select @sql = 'update ' + @p_database + '..BUY11_' + @p_posno
			+ ' set AMOUNT = ' + convert(varchar, @m_change, 2)
			+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + ''''
			+ ' and CURRENCY = -1'
		exec (@sql)
		commit transaction
	end
	
	if @d_prevamt <> @m_prevamt
	begin
		select @itemno = ITEMNO from rb_BUY11 
			where POSNO = @p_posno and FLOWNO = @p_flowno and CURRENCY <> -1
		if @@rowcount <> 0
		begin
			begin transaction
			exec ('update ' + @p_database + '..BUY1_' + @p_posno
				+ ' set TAG = 0'
				+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
			select @sql = 'update ' + @p_database + '..BUY11_' + @p_posno
				+ ' set AMOUNT = AMOUNT + ' + convert(varchar, @m_prevamt - @d_prevamt, 2)
				+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + ''''
				+ ' and ITEMNO = ' + convert(varchar, @itemno)
			exec (@sql)
			commit transaction
		end
	end
	
	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
		TYPE, CONTENT)
		values (getdate(), 'REPAIRBUY', '',	'REPAIRBUY', 101, 
		'修复' + @p_posno + '号机的交易(FlowNo=' + @p_flowno
		+ '，原因：' + convert(char(2), @tag))
	waitfor delay '0:0:1'
end
GO
