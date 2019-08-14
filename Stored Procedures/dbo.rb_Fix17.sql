SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[rb_Fix17](
	@p_database varchar(30),
	@p_posno varchar(10),
	@p_flowno varchar(12),
	@tag int
) as
begin
	declare @d_realamt money, @sql varchar(255)
	
	select @d_realamt = sum(REALAMT)
		from rb_BUY2
		where POSNO = @p_posno and FLOWNO = @p_flowno
	if @d_realamt is null return(0)
	
	begin transaction
	select @sql = 'update ' + @p_database + '..BUY1_' + @p_posno
		+ ' set REALAMT = ' + convert(varchar, @d_realamt, 2) + ', TAG = 0'
		+ ' where POSNO = ''' + @p_posno + ''' and FLOWNO = ''' + @p_flowno + ''''
	exec (@sql)
	commit transaction
	
	insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
		TYPE, CONTENT)
		values (getdate(), 'REPAIRBUY', '',	'REPAIRBUY', 101, 
		'修复' + @p_posno + '号机的交易(FlowNo=' + @p_flowno
		+ '，原因：' + convert(char(2), @tag))
	waitfor delay '0:0:1'
end
GO
