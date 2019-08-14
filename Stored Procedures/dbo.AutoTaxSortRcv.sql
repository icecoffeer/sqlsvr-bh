SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoTaxSortRcv]
 @SRC int,
 @RCV int,
 @ErrMsg varchar(200) output
as
begin
 declare @result int
 exec @result = PS3_TAXSORT_RCV @SRC, @RCV, @ErrMsg output
 return @result
end
GO
