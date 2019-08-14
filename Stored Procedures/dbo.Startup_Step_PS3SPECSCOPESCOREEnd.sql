SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PS3SPECSCOPESCOREEnd]
with Encryption
as
begin
  declare
    @Oper int,
    @msg varchar(255),
    @Cls varchar(10),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '特殊范围积分规则设置单自动终止' )
  set @Oper = 1
  set @Cls = '积分'

  declare
    @num char(14)
  declare c_num cursor for
    select srcnum from PS3SPECSCOPESCOREINV
    where srccls = @Cls
    group by srcnum
    having max(enddate) < getdate()
  open c_num
  fetch next from c_num into @num
  while @@fetch_status = 0
  begin
    begin transaction
    execute @return_status = PS3SPECSCOPESCORE_END  @Num, @Cls, @Oper, 1500, @Msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PS3SPECSCOPESCORE_END', 202, @num + ' - ' + @msg)
    end
    fetch next from c_num into @num
  end
  close c_num
  deallocate c_num
  return(0)
end
GO
