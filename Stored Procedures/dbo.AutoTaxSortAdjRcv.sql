SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoTaxSortAdjRcv]
 @SRC int,
 @ID int,
 @ErrMsg varchar(200) output
as
begin
 declare @result int
 exec @result = TaxSortAdj_Rcv @SRC, @ID,'1',@ErrMsg output
 return @result
end
GO
