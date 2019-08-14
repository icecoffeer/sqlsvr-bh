SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[rb_delete](
	@p_database varchar(30),
	@pt_posno varchar(10),
	@p_posno varchar(10),
	@p_flowno varchar(12),
	@err_msg varchar(200)
) as
begin
	begin transaction
	exec ('delete from ' + @p_database + '..BUY1_' + @pt_posno 
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	exec ('delete from ' + @p_database + '..BUY11_' + @pt_posno 
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	exec ('delete from ' + @p_database + '..BUY2_' + @pt_posno 
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	exec ('delete from ' + @p_database + '..BUY21_' + @pt_posno 
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + '''')
	commit transaction

	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
		TYPE, CONTENT)
		values (getdate(), 'REPAIRBUY', '',	'REPAIRBUY', 101, 
		'删除来自' + @pt_posno + '号机的交易(PosNo=' + @p_posno + ',FlowNo=' + @p_flowno
		+ ')，原因：' + @err_msg)
	waitfor delay '0:0:1'
end
GO
