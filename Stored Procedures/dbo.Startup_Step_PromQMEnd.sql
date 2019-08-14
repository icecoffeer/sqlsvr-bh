SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PromQMEnd]
with Encryption
as
begin
  declare
    @Oper int,
    @msg varchar(255),
    @Cls VARCHAR(10),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '总量(额)促销单自动终止' )
  set @Oper = 1

  declare
    @num char(14)
  declare c_num cursor for
    select NUM,CLS from PROM 
    where STAT = 800 and cls in ('总量','总额')
    GROUP BY NUM,CLS
    HAVING MAX(AFINISH) <= Getdate()
  open c_num
  fetch next from c_num into @num,@Cls
  while @@fetch_status = 0
  begin
    begin transaction
    execute @return_status = PROMDLT_OCR  @Cls, @Num, @Oper, 1400, @Msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PROMDLT_OCR', 202, @num + ' - ' + @msg)
    end
    fetch next from c_num into @num,@Cls
  end
  close c_num
  deallocate c_num
  return(0)
end
GO
