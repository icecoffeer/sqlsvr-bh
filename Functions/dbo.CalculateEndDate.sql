SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Function [dbo].[CalculateEndDate](
  @piBaseDate DateTime,
  @piGenUnit Varchar(10),
  @piCycle int,
  @piOffSet int
)
Returns DateTime
As
Begin
  Declare
    @v_DayOffSet int,
    @v_FstDay DateTime,
    @v_TmpDate DateTime,
    @v_CycleYear int,
    @v_Result DateTime

  If @piBaseDate = 0
  Begin
    Return 0
  End
  --Offset需要减一
  Set @v_DayOffSet = @piOffSet - 1

  --基准日期当月的第一天
  Set @v_FstDay = DateAdd(dd, -day(@piBaseDate) + 1, @piBaseDate)
  If @piGenUnit = '日'
  Begin
    Set @v_Result = @piBaseDate + @piCycle - 1
  End Else If @piGenUnit = '月'
  Begin
    If (@v_DayOffSet >= 0) And (Day(@piBaseDate) <= @v_DayOffSet)
      --第一天基础上增加@picycle-1个月,得到那个日期
      Set @v_TmpDate = Convert(Datetime, Convert(date, DateAdd(Month, + @piCycle-1, @v_FstDay)))
    Else
      --第一天基础上增加@picycle个月,得到那个日期
      Set @v_TmpDate = Convert(Datetime, Convert(date, DateAdd(Month, + @piCycle, @v_FstDay)))
    --计算日期
    if @v_DayOffSet >= 0
    Begin
      If @v_DayOffSet = 0
        Set @v_Result = @v_TmpDate - 1
      Else
      --如果这个日期加上@v_DayOffSet之后超过该月最大日期,则取该月最后一天,否则取这个日期+@v_DayOffSet
      If Month(@v_TmpDate + @v_DayOffSet - 1) <> Month(@v_TmpDate)
        Set @v_Result = DateAdd(dd, -1, DateAdd(mm, DateDiff(m, 0, @v_TmpDate) + 1, 0))
      Else
        Set @v_Result = @v_TmpDate + @v_DayOffSet - 1
    End Else
    Begin
      If @piBaseDate >= @v_TmpDate + @v_DayOffSet + 1
      Begin
        If Month(Convert(Datetime, Convert(date, DateAdd(Month, + 1, @v_TmpDate))) + @v_DayOffSet + 1)
          <> Month(@v_TmpDate)
          Set @v_Result = @v_TmpDate - 1
        Else
          Set @v_Result = Convert(Datetime, Convert(date, DateAdd(Month, + 1, @v_TmpDate))) + @v_DayOffSet
      End Else
        Set @v_Result = @v_TmpDate + @v_DayOffSet
    End
  End Else If @piGenUnit = '年'
  Begin
    Set @v_CycleYear = 12 * @piCycle
    If Day(@piBaseDate) <= @v_DayOffSet
      --第一天基础上增加@picycle-1年,得到那个日期
      Set @v_TmpDate = Convert(Datetime, Convert(date, DateAdd(Month, + @v_CycleYear-1, @v_FstDay)))
    Else
      --第一天基础上增加@picycle个月,得到那个日期
      Set @v_TmpDate = Convert(Datetime, Convert(date, DateAdd(Month, + @v_CycleYear, @v_FstDay)))

    If @v_DayOffSet = 0
      Set @v_Result = @v_TmpDate - 1
    Else If Month(@v_TmpDate) <> Month(@v_TmpDate + @v_DayOffSet - 1)
      --该日期当月最后一天
      Set @v_Result = DateAdd(dd, -1, DateAdd(mm, DateDiff(m, 0, @v_TmpDate) + 1, 0))
    Else
      Set @v_Result = @v_TmpDate + @v_DayOffSet - 1
  End Else
    Set @v_Result = 0

  Return @v_Result
End
GO
