SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_Ltdadj]
--with encryption
as
begin
  declare
    @ltdadj_num char(14),
    @ltdadj_settleno int,
    @ltdadj_fildate datetime,
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '限制业务调整单生效' )

  declare c_ltdadj2 cursor for
  select NUM from LTDADJ where STAT = 100 and LAUNCH <= GETDATE() order by FILDATE
  open c_ltdadj2
  fetch next from c_ltdadj2 into @ltdadj_num
  while @@fetch_status = 0
  begin
    execute @return_status = LTDADJOCR @ltdadj_num
    if @return_status <> 0
    begin
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'LTDADJOCR', 202, @ltdadj_num )
    end
    fetch next from c_ltdadj2 into @ltdadj_num
  end
  close c_ltdadj2
  deallocate c_ltdadj2

 --2005.10.27 Edited by ShenMin, Q5199, 限制业务调整单增加生效时间控制
  DECLARE @OptRd VARCHAR(100)
  EXEC OPTREADSTR 0, '限制业务调整途径', '1111', @OptRd OUTPUT
  IF @OPTRD = '0001'
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '限制业务调整单失效')
      exec LTDADJUNOCR
    end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_Ltdadj', 0, ''   --合并日结
  return(0)
end

GO
