SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PreSaleProc_ErrLog](
  @buypool varchar(30),
  @posno varchar(10),
  @flowno varchar(12),
  @errcode smallint, /*0-正确；其他值-错误*/
  @errmsg varchar(255)
) as
begin
  /*传入参数处理*/
  set @buypool = isnull(@buypool, '')
  set @posno = isnull(@posno, '')
  set @flowno = isnull(@flowno, '')
  set @errcode = isnull(@errcode, -1)
  set @errmsg = isnull(@errmsg, '')

  set @buypool = ltrim(rtrim(@buypool))
  set @posno = ltrim(rtrim(@posno))
  set @flowno = ltrim(rtrim(@flowno))

  /*错误代码*/
  declare @txterrcode varchar(10)
  select @txterrcode = rtrim(convert(varchar, @errcode))

  /*记录日志*/
  begin transaction
  execute (
    ' update ' + @buypool + '..ASBUY1_' + @posno + ' set TAG = ' + @txterrcode +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''')
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'PreSale', 'HDSVC', '预售处理', 202, @posno + '-' + @flowno + @errmsg)
  update WORKSTATION set
    ERRCNT = ERRCNT + 1
    where NO = @posno
  commit transaction
end
GO
