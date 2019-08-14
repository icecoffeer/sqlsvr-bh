SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_ON_SETTLEDAY]
(
  @piDate datetime                 --日结日期
) as
begin
  declare @vCntrNum varchar(14)
  declare @vCntrVersion integer
  declare @vMsg varchar(255)
  declare @vRet integer
  declare @vSettleNo integer
  
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  if object_id('c_Cntr') is not null deallocate c_Cntr
  declare c_Cntr cursor for
    select NUM, VERSION from CTCNTR where STAT = 500 and TAG = 1 and ENDDATE <= @piDate
  open c_Cntr
  fetch next from c_Cntr into @vCntrNum, @vCntrVersion
  while @@fetch_status = 0
  begin
    begin transaction
    exec @vRet = PCT_CNTR_ON_MODIFY @vCntrNum, @vCntrVersion, 1400, 1, @vMsg output
    if @vRet <> 0
    begin
      rollback transaction
      set @vMsg = substring('终止合约 ' + @vCntrNum + '(' + rtrim(convert(varchar, @vCntrVersion)) + ') 失败。' 
        + char(10) + @vMsg, 1, 255)
      insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values(getdate(), @vSettleNo, '日结程序', '日结程序', 'DB SERVER', '日结程序', 304, @vMsg);
    end else
    begin
      commit transaction
      set @vMsg = '终止合约 ' + @vCntrNum + '(' + rtrim(convert(varchar, @vCntrVersion)) + ') 成功。' 
      insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values(getdate(), @vSettleNo, '日结程序', '日结程序', 'DB SERVER', '日结程序', 301, @vMsg);
    end
    waitfor delay '0:0:0.010'

    fetch next from c_Cntr into @vCntrNum, @vCntrVersion
  end
  close c_Cntr
  deallocate c_Cntr
end
GO
