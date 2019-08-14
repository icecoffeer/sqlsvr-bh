SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STARTUP](
  @maindb varchar(30),
  @buypool varchar(30)
)
--with encryption
as
begin
  execute(
  'dump transaction ' + @maindb + ' with truncate_only' )
  execute(
  'dump transaction ' + @buypool + ' with truncate_only' )

  declare
    @settleno int,        @date datetime,
    @return_status int,   @old_date datetime,
    @msg char(50),
    --3114
    @oldft money,         @newct money,
    @count int,           @ReDoSettleDayForTimesAfterFail int
  exec optreadint 0,'日结失败后自动重试',0,@ReDoSettleDayForTimesAfterFail output

  select @oldft = 0, @newct = 0
  select @old_date = max(ADATE) from INVDRPT
  select @settleno = max(NO) from MONTHSETTLE
  select @date = convert(datetime, convert(char, getdate(), 102))

  -- 基本元素
  truncate table ZJ
  truncate table PJ
  truncate table ZPJ
  truncate table XS
  truncate table PC
  truncate table KC
  truncate table DB
  truncate table ZK

  -- 日结转
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC',
  'SETTLEDAY', 101, '日结转' )
  --3114
  --select @old_date = max(ADATE) from INVDRPT -- move to before
  execute @return_status = SETTLEDAY @settleno, @old_date, @settleno, @date
  if @ReDoSettleDayForTimesAfterFail = 1
  begin
    select @oldft = sum(ft) from invdrpt(nolock) where adate = @old_date
    select @newct = sum(isnull(ct,0)) from invdrpt(nolock) where adate = @date
  end
  if (@ReDoSettleDayForTimesAfterFail = 1) and (@newct <> @oldft)
  begin
    set @count = 1
    while (@count <= 10)
    begin
        execute @return_status = SETTLEDAY @settleno, @old_date, @settleno, @date
      if @return_status = 0 or @return_status = 1
        break
        select @count = @count + 1
    end
  end
  if @return_status <> 0 begin
    /* 2000-06-07 */
    waitfor delay '0:0:0.010'
    if @return_status = 1
      set @msg = '本日已经做过日结转'
    else
      set @msg = ''
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'STARTUP', 'HDSVC',
    'SETTLEDAY', 202, '日结转失败,原因['+ convert(varchar, @return_status) + ']' + @msg )    
        
    /* 99-6-16 */
    if @return_status <> 1
    begin
      select @msg = '日结转失败,原因'+ convert(varchar, @return_status)
      raiserror(@msg, 16, 1)
    end
  end

  -- 零售处理统计值
  /* 2000-06-07 */
  waitfor delay '0:0:0.010'
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC',
  'SETTLEDAY', 101, '零售处理统计值' )
  update WORKSTATION set
    NPCNT = 0,
    NPOPCNT = 0,
    CNT = 0,
    OPCNT = 0,
    AMT = 0,
    ERRCNT = 0
  if @old_date <> @date
    update WORKSTATION set TODAYCNT = 0, TODAYAMT = 0
  update SYSTEM set RTL = 0

  execute(
  'dump transaction ' + @maindb + ' with truncate_only' )
  execute(
  'dump transaction ' + @buypool + ' with truncate_only' )
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'STARTUP', 0, ''   --合并日结
end

GO
