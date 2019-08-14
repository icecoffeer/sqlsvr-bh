SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[StartUp_Step_RtlPrcadj]
--with Encryption
as
begin
  declare
    @msg varchar(255), @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '自动调价2' )
  declare
    @rtlprcadj_num char(14),
    @rtlprcadj_settleno int, @rtlprcadj_fildate datetime
  declare c_rtlprcadj2 cursor for
    select NUM, SETTLENO, fildate
    from rtlprcadj
    where STAT = 100 and LAUNCH <= GETDATE()
    order by fildate
  open c_rtlprcadj2
  fetch next from c_rtlprcadj2 into @rtlprcadj_num,
    @rtlprcadj_settleno, @rtlprcadj_fildate
  while @@fetch_status = 0 begin
    begin transaction
    execute @return_status = RtlPrcAdj_To800 @rtlprcadj_num,@msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'RtlPrcAdj_To800', 202, @rtlprcadj_num + ' - ' + @msg)
    end
    fetch next from c_rtlprcadj2 into @rtlprcadj_num,
    @rtlprcadj_settleno, @rtlprcadj_fildate
  end
  close c_rtlprcadj2
  deallocate c_rtlprcadj2
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'StartUp_Step_Rtlprcadj', 0, ''   --合并日结
  return(0)
end

GO
