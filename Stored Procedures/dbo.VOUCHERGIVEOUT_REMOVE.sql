SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[VOUCHERGIVEOUT_REMOVE]
(
  @Num varchar(14),         --单号
  @Oper varchar(30),        --操作人
  @Msg varchar(255) output  --错误信息
)
as
begin
  declare
    @Stat int,
    @Ret  int
  select @Stat = STAT from VOUCHERGIVE(nolock) where NUM = @Num
  if @Stat <> 0
  begin
    set @Msg = '购物券服务台发放单(' + @Num + ')不是未审核状态，不允许删除!'
    return(1)
  end

  exec @Ret = VOUCHERGIVEOUT_DOREMOVE @Num, @Msg output
  if @Ret <> 0 return(@Ret)
  Delete From VOUCHERGIVELOG Where NUM = @Num

  return(0)
end
GO
