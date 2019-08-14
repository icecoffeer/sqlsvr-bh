SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_LmtprmClear]
--with encryption
as
begin
  declare
    @return_status int,
    @OptionValue smallint

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values(getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '自动清除过期限量促销记录')
  execute @return_status = LMTPRMCLEAR
  if @return_status <> 0
  begin
    waitfor delay '0:0:0.010'
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values(getdate(), 'STARTUP', 'HDSVC', 'LMTPRMCLEAR', 202, '')
  end
  --2002.10.25
  waitfor delay '0:0:0.010'
  exec OPTREADINT 0, 'NewGoodsAutoFinish', 0, @OptionValue output
  if @optionValue = 1
  begin
        update GOODS set KEEPTYPE = KEEPTYPE - 1 where KEEPTYPE & 1 = 1 and NENDTIME < getdate()
        waitfor delay '0:0:0.010'
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
          values(getdate(), 'STARTUP', 'HDSVC', 'NewGoodsAutoFinish', 101, '')
  end
  waitfor delay '0:0:0.010'
  exec OPTREADINT 0, 'SeasonGoodsCancelOrd', 0, @OptionValue output
  if @optionValue = 1
  begin
        update GOODS set ISLTD = ISLTD + 2 where isnull(ISLTD, 0) & 2 <> 2 and SSEND < getdate()
        update GDSTORE set ISLTD = ISLTD + 2 where isnull(ISLTD, 0) & 2 <> 2
           and gdgid in (select gid from goods where SSEND < getdate())
        waitfor delay '0:0:0.010'
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
          values(getdate(), 'STARTUP', 'HDSVC', 'SeasonGoodsCancelOrd', 101, '')
  end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_LmtprmClear', 0, ''   --合并日结
  return(0)
end

GO
