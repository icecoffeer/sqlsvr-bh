SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_CHKTO100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Ret int,
    @Stat int,
    @optGenIn int

  select @Stat = STAT from GOODSRECEIPT(nolock) where NUM = @Num
  if (@Stat <> 0) and (@Stat <> 1600)
  begin
    set @Msg = '不是未审核或已预审的单据，不能进行审核操作.'
    return(1)
  end

  update GOODSRECEIPT
    set STAT = 100, CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
    where NUM = @num

  --记录审核日志
  exec GOODSRECEIPT_ADD_LOG @Num, 100, '审核', @Oper
  
  --根据选项生成进货单
  exec OptReadInt 8067, 'GenIn', 0, @optGenIn output
  if @optGenIn = 1
  begin
    exec @Ret = GOODSRECEIPT_GEN_IN @Num, @Oper, @Msg output
    if @Ret <> 0
      return @Ret
  end

  --删除RFEMPLOCKORD表中的相关数据
  delete RFEMPLOCKORD from GOODSRECEIPT
    where RFEMPLOCKORD.ORDNUM = GOODSRECEIPT.SRCORDNUM
    and GOODSRECEIPT.NUM = @Num

  return(0)
end
GO
