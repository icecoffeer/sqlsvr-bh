SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[NextNaNo] (
  @pi_nano int,
  @po_nano int output
) as
begin
  declare @y int, @m int
  select @y = @pi_nano / 100
  select @m = @pi_nano % 100
  if(@m = 12)
    set @po_nano = (@y + 1) * 100 + 1
  else
    set @po_nano = @y * 100 + @m + 1
end
GO
