SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_ON_SETTLEDAY] (
  @piDate datetime
) as
begin
  declare @vRet integer
  declare @vCntrNum varchar(14)
  declare @vCntrVersion integer
  declare @vCntrLine integer
  declare @vMsg varchar(255)
  declare @vSettleNo integer
  declare @vMessage varchar(255)

  set @vMessage = convert(varchar(10), @piDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'On_SettleDay', @vMessage

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  if object_id('c_Line') is not null deallocate c_Line
  declare c_Line cursor for
    select d.NUM, d.VERSION, d.LINE from CTCNTR m, CTCNTRDTL d, CTCHGDEF c
    where m.NUM = d.NUM and m.VERSION = d.VERSION and m.TAG = 1 and m.STAT in (500, 1400)
      and d.CHGCODE = c.CODE and c.AUTOCALC = 1 and c.WHENGEN = '指定时间'
      and (d.NEXTGENDATE is not null and d.NEXTGENDATE <= @piDate)

  open c_Line
  fetch next from c_Line into @vCntrNum, @vCntrVersion, @vCntrLine
  while @@fetch_status = 0
  begin
    begin transaction
    exec @vRet = PCT_CHGBOOK_BATCH_GEN_ONE @vCntrNum, @vCntrVersion, @vCntrLine, 1, 1, @vMsg output
    if @vRet <> 0
    begin
      rollback transaction
      begin transaction
      set @vMsg = substring('合约 ' + @vCntrNum + '(' + rtrim(convert(varchar, @vCntrVersion)) + ') 的行 '
        + rtrim(convert(varchar, @vCntrLine)) + ' 日结生成费用单失败。'
        + char(10) + @vMsg, 1, 255)
      insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values(getdate(), @vSettleNo, '日结程序', '日结程序', 'DB SERVER', '日结程序', 304, @vMsg);
      commit transaction
    end else
      commit transaction

    fetch next from c_Line into @vCntrNum, @vCntrVersion, @vCntrLine
  end
  close c_Line
  deallocate c_Line
end
GO
