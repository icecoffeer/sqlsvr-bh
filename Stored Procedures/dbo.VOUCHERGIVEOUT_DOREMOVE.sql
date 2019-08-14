SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[VOUCHERGIVEOUT_DOREMOVE]
(
  @Num varchar(14),         --单号
  @Msg varchar(255) output  --错误信息
) as
begin
  delete from VOUCHERGIVE where NUM = @Num
  delete from VOUCHERGIVEDTL where NUM = @Num
  delete from VOUCHERGIVEVCDTL where NUM = @Num
  delete from VOUCHERGIVEGOODS where NUM = @Num
  delete from VOUCHERDIVRECORD where GIVENUM = @Num

  set @Msg = ''
  return(0)
end
GO
