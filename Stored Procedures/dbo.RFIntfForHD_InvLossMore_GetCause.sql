SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvLossMore_GetCause](
  @piTypeName varchar(20),
  @poCause varchar(1000) output,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @CauseCount int,
    @i int,
    @OptionCaption varchar(50),
    @OptionValue varchar(255)

  set @poCause = ''

  --读取报损原因。

  if rtrim(@piTypeName) = '损耗'
  begin
    exec OptReadInt 12, 'CauseCount', 0, @CauseCount output
    if @CauseCount > 0
    begin
      set @i = 1
      while @i <= @CauseCount
      begin
        set @OptionCaption = 'Cause' + convert(varchar, @i)
        exec OptReadStr 12, @OptionCaption, '', @OptionValue output
        set @poCause = @poCause + rtrim(@OptionValue) + '#'
        set @i = @i + 1
      end
      if @poCause <> '' and substring(@poCause, len(@poCause), 1) = '#'
        set @poCause = substring(@poCause, 1, len(@poCause) - 1)
    end
  end

  return 0
end
GO
