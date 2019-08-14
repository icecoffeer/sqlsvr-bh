SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PrcPrm]  
as  
begin  
  declare  
    @prcprm_num char(10),  
    @prcprm_settleno int, @prcprm_fildate datetime,  
    @return_status int,  
  
    @PayRateprm_num char(14),  
    @PayRateprm_settleno int,  
    @PayRateprm_fildate datetime  
  
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '促销自动生效' )  
  declare c_prcprmchk cursor for  
    select NUM, SETTLENO, FILDATE  
    from PRCPRM  
    where STAT = 1 and LAUNCH <= GETDATE()-- and EON = 1  2001-5-9  
    order by FILDATE  
    --for update  
  open c_prcprmchk  
  fetch next from c_prcprmchk into @prcprm_num,  
    @prcprm_settleno, @prcprm_fildate  
  while @@fetch_status = 0  
  begin  
    begin transaction  
    execute @return_status = PRCPRMGO @prcprm_num  
    if @return_status = 0  
      commit transaction  
    else  
    begin  
      rollback  
      waitfor delay '0:0:0.010'  
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
      values (getdate(), 'STARTUP', 'HDSVC', 'PRCPRMGO', 202, @prcprm_num )  
    end  
    fetch next from c_prcprmchk into @prcprm_num,  
      @prcprm_settleno, @prcprm_fildate  
  end  
  close c_prcprmchk  
  deallocate c_prcprmchk  
  
 --联销率促销单自动生效 ShenMin, 2006.6.16  
  declare c_PayRateprmchk cursor for  
    select NUM, SETTLENO, FILDATE  
    from PAYRATEPRM  
    where STAT = 100 and LAUNCH <= GETDATE()  
    order by FILDATE  
    --for update  
  open c_PayRateprmchk  
  fetch next from c_PayRateprmchk into @PayRateprm_num,  
    @PayRateprm_settleno, @PayRateprm_fildate  
  while @@fetch_status = 0  
  begin  
    begin transaction  
    execute @return_status = PAYRATEPRMGO @PayRateprm_num, '日结'  
    if @return_status = 0  
      commit transaction  
    else  
    begin  
      rollback  
      waitfor delay '0:0:0.010'  
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
      values (getdate(), 'STARTUP', 'HDSVC', 'PAYRATEPRMGO', 202, @PayRateprm_num )  
    end  
    fetch next from c_PayRateprmchk into @PayRateprm_num,  
      @PayRateprm_settleno, @PayRateprm_fildate  
  end  
  close c_PayRateprmchk  
  deallocate c_PayRateprmchk  
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_PrcPrm', 0, ''   --合并日结  
  return(0)  
end  

GO
