SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PrcprmEnd]
with Encryption
as
begin
  declare
    @Oper int,
    @msg varchar(255),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '促销单自动终止' )
  set @Oper = 1

  declare
    @num char(10)
  declare c_num cursor for
    select MST.NUM from PRCPRM MST,PRCPRMDTLDTL DTL
      where MST.STAT = 5  AND DTL.NUM = MST.NUM
      GROUP BY MST.NUM
      HAVING MAX(DTL.FINISH) < Getdate()
  open c_num
  fetch next from c_num into @num
  while @@fetch_status = 0
  begin
    begin transaction
    execute @return_status = PRCPRM_END  @Num, @Oper, @Msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PRCPRMEND', 202, @num + ' - ' + @msg)
    end
    fetch next from c_num into @num
  end
  close c_num
  deallocate c_num
  return(0)
end
GO
