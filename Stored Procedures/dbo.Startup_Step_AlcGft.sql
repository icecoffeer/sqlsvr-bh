SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_AlcGft]
--with encryption
as
begin
  declare
    @ret int, @poErrmsg varchar(255)

  set @ret = 0
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '配货赠品协议' )

  exec @ret = AlcGftAgm_AutoCheck @poErrmsg output
  if @ret <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'STARTUP', 'HDSVC', 'AlcGftAgm_AutoCheck', 202, @poErrmsg )
  end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_AlcGft', 0, ''   --合并日结
  return(0)
end

GO
