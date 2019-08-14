SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_GftAgmClear]
--with encryption
as
begin
  declare
    @return_status int
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '自动清除过期赠品记录')
  execute @return_status = GFTAGMCLEAR
  if @return_status <> 0
  begin
    waitfor delay '0:0:0.010'
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'STARTUP', 'HDSVC', 'GFTAGMCLEAR', 202, '')
  end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday,'Startup_Step_GftAgmClear', 0, ''   --合并日结
  return(0)
end

GO
