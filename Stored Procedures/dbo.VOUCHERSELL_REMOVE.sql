SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[VOUCHERSELL_REMOVE]
(
    @Num varchar(14),         --单号
    @Oper varchar(30),        --操作人
    @Msg varchar(255) output  --错误信息
  )
as
begin
  declare  @Stat int

  select @Stat = STAT from VOUCHERSELL(nolock) where NUM = @NUM
  if @Stat <> 0
  begin
    set @Msg = '购物券发售单(' + @Num + ')不是未审核状态，不允许删除!';
    return(1);
  end

  delete from VOUCHERSELL where NUM = @Num;
  delete from VOUCHERSELLDTL where NUM = @Num;
  delete from VOUCHERSELLDTL2 where NUM = @Num;
  delete from VOUCHERSELLSTOREDTL where NUM = @Num;
  delete from VOUCHERSELLLOG where NUM = @Num;

  return(0)
end
GO
