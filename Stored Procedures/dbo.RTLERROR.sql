SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLERROR](
  @buypool varchar(30),
  @posno varchar(10),
  @flowno char(12),
  @errcode smallint,
  @errmsg varchar(100)
) with encryption as
begin
  declare @txterrcode varchar(10)
  select @txterrcode = rtrim(convert(char,@errcode))
  begin transaction
  execute (
    ' update ' + @buypool + '..BUY1_' + @posno + ' set TAG = ' + @txterrcode +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''')
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'RTLPROC', 'HDSVC',
    '零售处理', 202, @posno + '-' + @flowno + @errmsg )
  update WORKSTATION set
    ERRCNT = ERRCNT + 1
    where NO = @posno
  commit transaction
end
GO
