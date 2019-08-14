SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_GEN_IN]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Ret int

  if exists(select * from SYSTEM(nolock) where USERGID = ZBGID)
  begin
    exec @Ret = GOODSRECEIPT_GEN_IN_STK @Num, @Oper, @Msg output
  end
  else begin
    --exec @Ret = GOODSRECEIPT_GEN_IN_DIR @Num, @Oper, @Msg output--TODO
    exec @Ret = GOODSRECEIPT_GEN_IN_STK @Num, @Oper, @Msg output
  end
  
  return @Ret
end
GO
