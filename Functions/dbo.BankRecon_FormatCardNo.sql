SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[BankRecon_FormatCardNo](
  @piCardNo varchar(50)
)
returns varchar(50)
as
begin
  declare
    @vCardNo varchar(50),
    @vLength int
  set @vLength = len(@piCardNo)
  if @vLength <= 10 return @piCardNo
  set @vCardNo = ''
  set @vCardNo = substring(@piCardNo, 1, 6) + replicate('*', @vLength - 10) + substring(@piCardNo, @vLength - 3, 4)
  return @vCardNo
end
GO
