SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PayRateprmEnd]
with Encryption
as
begin
  declare
    @OPER VARCHAR(30),
    @msg varchar(255),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '联销率促销单自动终止' )
  set @OPER = '1'

  declare
    @num char(14)
  declare c_num cursor for
    select MST.NUM from PAYRATEPRM MST,PAYRATEPRMDTL DTL
      where MST.STAT = 800 AND DTL.NUM = MST.NUM
      GROUP BY MST.NUM
      HAVING MAX(DTL.AFINISH) < Getdate()
  open c_num
  fetch next from c_num into @num
  while @@fetch_status = 0
  begin
    begin transaction
    execute @return_status = PAYRATEPRMEND  @Num, @Oper, @Msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PAYRATEPRMEND', 202, @num + ' - ' + @msg)
    end
    fetch next from c_num into @num
  end
  close c_num
  deallocate c_num
  return(0)
end
GO
