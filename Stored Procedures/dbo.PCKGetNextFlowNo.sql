SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKGetNextFlowNo](
  @poNextFlowNo char(10) output
)
as
begin
  declare
    @vLongDatePart char(8),
    @vShortDatePart char(6),
    @vFlowNo varchar(10)
  set @vLongDatePart = convert(char(8), GetDate(), 112) --yyyymmdd
  set @vShortDatePart = substring(@vLongDatePart, 3, len(@vLongDatePart)) --yymmdd
  select @vFlowNo = IsNull(max(NUM), @vShortDatePart + replicate('0', 4))
    from PCK(nolock)
    where NUM like @vShortDatePart + '%'
  exec INCREASEASCIISTRING @vFlowNo output
  set @poNextFlowNo = @vFlowNo
  return 0
end
GO
