SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_AlcAdj]
--with encryption
as
begin
  declare
    @num char(14),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '配货方式调整单生效' )

  declare c_alcadj cursor for
  select NUM from ALCADJ(NOLOCK) where STAT = 100 and LAUNCH <= GETDATE() order by FILDATE
  open c_alcadj
  fetch next from c_alcadj into @num
  while @@fetch_status = 0
  begin
    execute @return_status = ALCADJ_CHECK_OCR @NUM, 'STARTUP', NULL, 0, NULL
    if @return_status <> 0
    begin
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'ALCADJ_CHECK_OCR', 202, @num )
    end
    fetch next from c_alcadj into @num
  end
  close c_alcadj
  deallocate c_alcadj
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_AlcAdj', 0, ''   --合并日结
  return(0)
end

GO
