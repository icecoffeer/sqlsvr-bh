SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSortRcv]
(
  @SRC int,
  @ID int,
  @ErrMsg varchar(200) output
)
as
begin
  declare @Result int
  exec @Result = PS3_SORT_RCV @SRC, @ID, @ErrMsg output
  return @Result
end
GO
