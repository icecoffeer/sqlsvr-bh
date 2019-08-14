SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_Utils_ExtractCode] (
  @piNameCode varchar(100),
  @poCode varchar(20) output
) as
begin
  declare @vIndex1 int
  declare @vIndex2 int

  select @vIndex1 = charindex('[', @piNameCode)
  select @vIndex2 = charindex(']', @piNameCode)
  if @vIndex1 is not null and @vIndex2 is not null
    and @vIndex1 > 0 and @vIndex2 > 0
    select @poCode = substring(@piNameCode, @vIndex1 + 1, @vIndex2 - @vIndex1 - 1)
  else
    select @poCode = null

  return(0)
end
GO
