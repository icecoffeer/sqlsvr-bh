SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_LOGDEBUG] (
  @piCatalog varchar(50),
  @piMessage varchar(255)
) as
begin
  declare @vNow datetime
  select @vNow = getdate()
  if exists(select 1 from HDOPTION where MODULENO = 3004 and OPTIONCAPTION = '启用调试日志' and OPTIONVALUE = '是')
  begin
    begin transaction PCT_CHGBOOK_LOGDEBUG_TRAN
    insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values(getdate(), 1, '-', '-', '-', 'PCT_CHGBOOK.' + @piCatalog, 301, @piMessage)
    commit transaction PCT_CHGBOOK_LOGDEBUG_TRAN

    while @vNow = getdate() continue
  end
end
GO
