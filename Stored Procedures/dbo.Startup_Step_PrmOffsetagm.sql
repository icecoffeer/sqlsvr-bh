SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PrmOffsetagm]
as
begin
  declare @Num varchar(14),@ret int, @poErrmsg varchar(255)
  set @ret = 0
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '促销补差协议' )
  declare C cursor for select Num from prmoffsetagm
  where LAUNCH <= getdate() and stat = 100 order by fildate
  open C
  fetch next from C into @Num
  while @@fetch_status = 0
  begin
    exec @ret = PRMOFFSETAGMGO @Num, 'STARTUP', 100,1, @poErrmsg output
    if @ret <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PRMOFFSETAGMGO', 202, @poErrmsg )
    end
    fetch next from C into @Num
  end
  close C
  deallocate C
  return(0)
end
GO
