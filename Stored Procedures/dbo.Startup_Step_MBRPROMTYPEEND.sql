SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_MBRPROMTYPEEND]
with Encryption
as
begin
  declare
    @Oper int,
    @msg varchar(255),
    @Cls varchar(10),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '会员促销类型登记单自动结束' )
  set @Oper = 1

  declare
    @num char(14)
  declare c_num cursor for
    select num from CRMMBRPROMTYPEBILL 
    where SUBJCODE not in (select code from PS3CRMPROMSUBJECT)
    and stat = 100
  open c_num
  fetch next from c_num into @num
  while @@fetch_status = 0
  begin
    begin transaction
    execute @return_status = Pcrm_Mbrpromtype_Stat_To_1500  @Num, @Oper, @Msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'MBRPROMTYPE_END', 202, @num + ' - ' + @msg)
    end
    fetch next from c_num into @num
  end
  close c_num
  deallocate c_num
  return(0)
end
GO
