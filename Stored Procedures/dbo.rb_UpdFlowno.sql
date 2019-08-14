SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[rb_UpdFlowno](
	@p_database varchar(30),
	@p_posno varchar(10),
	@p_flowno varchar(12),
	@tag int
) as
begin
	declare @n_flowno varchar(12)
	
	select @n_flowno = substring(@p_flowno, 1, 8) + '5' + substring(@p_flowno, 10, 3)
	
	begin transaction
	exec ('update ' + @p_database + '..BUY1_' + @p_posno
		+ ' set FLOWNO = ''' + @n_flowno + ''', TAG = 0'
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	exec ('update ' + @p_database + '..BUY11_' + @p_posno
		+ ' set FLOWNO = ''' + @n_flowno + ''''
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	exec ('update ' + @p_database + '..BUY2_' + @p_posno
		+ ' set FLOWNO = ''' + @n_flowno + ''''
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	exec ('update ' + @p_database + '..BUY21_' + @p_posno
		+ ' set FLOWNO = ''' + @n_flowno + ''''
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	commit transaction

	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
		TYPE, CONTENT)
		values (getdate(), 'REPAIRBUY', '',	'REPAIRBUY', 101, 
		'修改' + @p_posno + '号机的交易流水号:' + @p_flowno + '->' + @n_flowno
		+ '，原因：' + convert(char(2), @tag))
	waitfor delay '0:0:1'
end
GO
