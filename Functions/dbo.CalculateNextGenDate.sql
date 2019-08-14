SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Function [dbo].[CalculateNextGenDate](
  @piBaseDate DateTime,
  @piGenUnit Varchar(10),
  @piCycle int,
  @pioffSet int
)
Returns DateTime
As
Begin
  Declare
    @v_FstDay DateTime,
    @v_TmpDate DateTime,
    @v_CycleYear int,
    @v_Result DateTime

  If @piBaseDate = 0
  Begin
    Return 0
  End

  --基准日期当月的第一天
  Set @v_FstDay = DateAdd(dd, -day(@piBaseDate) + 1, @piBaseDate)
  If @piGenUnit = '日'
  Begin
    Set @v_Result = @piBaseDate + @piCycle
  End Else If @piGenUnit = '月'
  Begin
    --第一天基础上增加@picycle个月,得到那个日期
    Set @v_TmpDate = Convert(Datetime, Convert(date, DateAdd(Month, + @piCycle, @v_FstDay)))
    --如果这个日期加上@pioffset之后超过该月最大日期,则取该月最后一天,否则取这个日期+@pioffset
    If Month(@v_TmpDate + @pioffSet - 1) <> Month(@v_TmpDate)
      Set @v_Result = DateAdd(dd, -1, DateAdd(mm, DateDiff(m, 0, @v_TmpDate) + 1, 0))
    Else
      Set @v_Result = @v_TmpDate + @pioffSet - 1
  End Else If @piGenUnit = '年'
  Begin
    --第一天基础上增加@picycle年,得到那个日期
    Set @v_CycleYear = 12 * @piCycle
    Set @v_TmpDate = Convert(Datetime, Convert(date, DateAdd(Month, + @v_CycleYear, @v_FstDay)))
    --如果这个日期加上@pioffset之后超过该月最大日期,则取该月最后一天,否则取这个日期+@pioffset
    If Month(@v_TmpDate + @pioffSet - 1) <> Month(@v_TmpDate)
      Set @v_Result = DateAdd(dd, -1, DateAdd(mm, DateDiff(m, 0, @v_TmpDate) + 1, 0))
    Else
      Set @v_Result = @v_TmpDate + @pioffSet - 1
  End Else
    Set @v_Result = 0

  Return @v_Result
End
GO
