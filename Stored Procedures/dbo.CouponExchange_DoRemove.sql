SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CouponExchange_DoRemove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  delete from COUPONEXCHANGE where NUM = @Num
  delete from COUPONEXCHANGERECEIPTDTL where NUM = @Num
  delete from COUPONEXCHANGECOUPONDTL where NUM = @Num
  delete from COUPONEXCHANGEPRINTDTL where NUM = @Num
  delete from COUPONEXCHANGETRANDTL where NUM = @Num
  return 0
end
GO
