SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_SETTLEDAY] (
   @PIDATE DATETIME
  ) as
begin
  declare @ErrMsg VARCHAR(255)
  declare @MSettle INT
  declare @vRet int
  declare @vSettleDayTime varchar(10)
  declare @vDateStr varchar(10)
  declare @ProcName varchar(50)
  declare @vcmd   varchar(255)

  select @MSettle  = MAX(NO) from MONTHSETTLE(nolock)
  select @vDateStr = convert(varchar(10), getdate(), 102)
  select @vSettleDayTime = OPTIONVALUE from HDOPTION(nolock) where MODULENO = 0 and OPTIONCAPTION = '上一结转日'
  if (@@rowcount = 0) or (convert(datetime, @vSettleDayTime) < convert(datetime, @vDateStr))
  begin
  	  declare C_SettleDay cursor for
  	  	select PROCNAME from SETTLEDAYREG(nolock) order by ID
  	  open C_SettleDay
  	  fetch Next from C_SettleDay into @ProcName
  	  while @@fetch_status = 0
  	  begin
		select @vcmd = 'exec ' + @ProcName + ' ' + ''''+ convert(char(10), @PIDATE) + ''''
  	  	exec (@vcmd)
  	  	fetch Next from C_SettleDay into @ProcName
  	  end
  	  close C_SettleDay
      deallocate C_SettleDay

      --更新最新日结记录
      if exists(select 1 from HDOPTION(nolock) where MODULENO = 0 and OPTIONCAPTION = '上一结转日')
        update HDOPTION set OPTIONVALUE = @vDateStr where MODULENO = 0 and OPTIONCAPTION = '上一结转日'
      else
        insert into HDOPTION(MODULENO, OPTIONCAPTION, OPTIONVALUE, NOTE) values(0, '上一结转日', @vDateStr, null)
      insert into LOG(TIME, MONTHSETTLENO, employeecode, employeename, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), @msettle, '-', '日结程序', 'db server', '日结程序', 304, substring('PS3_日结成功。', 1, 255))
  end
  return(0);
end
GO
