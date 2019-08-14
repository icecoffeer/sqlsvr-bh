SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoPPS_BRAND_RCV]
  @SRC int,
  @ID int,
  @ErrMsg varchar(200) output
as
begin
  declare @result int
  exec @result = PPS_BRAND_RCV @SRC, @ID, @ErrMsg output
  return @result
end
GO
