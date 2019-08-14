SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashDel] (
  @num char(14)
)
as
begin
  declare @stat int
  select @stat = stat from cntrpaycash where num = @num
  if @@rowcount = 0
    raiserror('付款单%s不存在', 16, 1, @num)
  else begin
  	if @stat not in (0, 2100 , 2200, 2300)
  	  raiserror('付款单%s不是未审核单据', 16, 1, @num)
  	else begin
  	  delete from cntrpaycash where num = @num
  	  delete from cntrpaycashdtl where num = @num
  	  delete from cntrpaycashvatdtl where num = @num
  	  delete from cntrcheque where cls = '付款单' and num = @num
  	end
  end
end
GO
