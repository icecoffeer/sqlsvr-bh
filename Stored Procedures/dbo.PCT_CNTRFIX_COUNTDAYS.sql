SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTRFIX_COUNTDAYS]
(
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piGenDate datetime,                    --本次生成日期
  @poCountDays Integer output,            --统计天数
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vGenUnit varchar(4)
  declare @vCountUnit varchar(4)
  declare @vGenCycle integer
  declare @vGenDayOffset integer

  declare @vLstGenDate datetime
  declare @monthNextGenDate int

  Select @poCountDays = 1
  Select @poErrMsg = ''

  select
    @vGenUnit = f.GENUNIT,
    @vCountUnit = d.COUNTUNIT,
    @vGenCycle = d.GENCYCLE,
    @vGenDayOffset = d.GENDAYOFFSET
  from CTCNTRDTL d, CTCHGDEF f
  where d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine and d.CHGCODE = f.CODE
  if (@vGenUnit <> '月') or (@vCountUnit <> '日')
    Return 0

  Select @vGenCycle = - @vGenCycle
  Set @vLstGenDate = @piGenDate - day(@piGenDate) + 1
  Set @vLstGenDate = DateAdd(Month, @vGenCycle, @vLstGenDate)
  if @vGenDayOffset < 0
  begin
    Set @vLstGenDate = DateAdd(Month, 1, @vLstGenDate)
    if Month(@vLstGenDate) = 1
      Set @monthNextGenDate = 1
    Else
      Set @monthNextGenDate = Month(@vLstGenDate)
    if Month(@vLstGenDate + @vGenDayOffset) + 1 < @monthNextGenDate
    Begin
      Set @vLstGenDate = DateAdd(Month, -1, @vLstGenDate)
      If @vLstGenDate >= @piGenDate
        Set @vLstGenDate = DateAdd(Month, -1, @vLstGenDate)
    End Else
    Begin
      Set @vLstGenDate = @vLstGenDate + @vGenDayOffset
      If @vLstGenDate >= @piGenDate
        Set @vLstGenDate = DateAdd(Month, -1, @vLstGenDate - @vGenDayOffset) + @vGenDayOffset
    End
  end else If Month(@vLstGenDate + @vGenDayOffset - 1) > Month(@vLstGenDate)
    Set @vLstGenDate = DateAdd(Month, 1, @vLstGenDate) - 1
  Else
    Set @vLstGenDate = @vLstGenDate + @vGenDayOffset - 1

  --计算上次生成日期与本次生成日期之间的天数差
  Select @poCountDays = ABS(DATEDIFF(Day, @vLstGenDate, @piGenDate))

  return 0
end
GO
