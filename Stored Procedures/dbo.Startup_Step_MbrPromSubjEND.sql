SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_MbrPromSubjEND]
with Encryption
as
begin
  declare
    @Oper int,
    @msg varchar(255),
    @Cls varchar(10),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '会员促销主题积分折扣单自动终止' )
  set @Oper = 1

  declare
    @num char(14)
  declare c_num cursor for
    select NUM, CLS from PS3MBRPROMSUBJ 
    where STAT = 100 and EndDate < Getdate() 
  open c_num
  fetch next from c_num into @num, @Cls
  while @@fetch_status = 0
  begin
    begin transaction
    execute @return_status = PS3MbrPromSubj_END  @Num, @Cls, @Oper, 1500, @Msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PS3MbrPromSubj_END', 202, @num + ' - ' + @msg + ',类型:' + @Cls)
    end
    fetch next from c_num into @num, @Cls
  end
  close c_num
  deallocate c_num
  return(0)
end
GO
