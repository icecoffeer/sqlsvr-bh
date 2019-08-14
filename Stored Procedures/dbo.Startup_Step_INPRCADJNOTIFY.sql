SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_INPRCADJNOTIFY]
--with encryption
as
begin
  declare
    @ret int, @MSG varchar(255)

  set @ret = 0
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '生效成本调整通知单' )

  exec @ret = INPRCADJNOTIFY_AUTOCHECK @MSG output
  if @ret <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'STARTUP', 'HDSVC', 'INPRCADJNOTIFY_AUTOCHECK', 202, @MSG )
  end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_INPRCADJNOTIFY', 0, ''   --合并日结
  return(0)
end

GO
