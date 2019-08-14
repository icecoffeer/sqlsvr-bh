SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VoucherActBck_RemoveEx](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  delete from VOUCHERACTBCK where NUM = @Num
  delete from VOUCHERACTBCKTRANSGDDTL where NUM = @Num
  delete from VOUCHERACTBCKVOUGETDTL where NUM = @Num
  delete from VOUCHERACTBCKVOUACTDTL where NUM = @Num
  delete from VOUCHERACTBCKVOUACTGETDTL where NUM = @Num
  delete from VOUCHERACTBCKVOUUSEDTL where NUM = @Num
  delete from VOUCHERACTBCKVOUGIVEDTL where NUM = @Num
  delete from VOUCHERACTBCKVOUSELLDTL where NUM = @Num
  delete from VOUCHERACTBCKBINDTRANSDTL where NUM = @Num
  return(0)
end
GO
