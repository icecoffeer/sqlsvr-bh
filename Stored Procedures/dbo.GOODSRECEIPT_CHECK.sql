SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRECEIPT_CHECK]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
 declare @vRet int, @opt int
 if @ToStat = 100
 begin
   exec @vRet = GOODSRECEIPT_CHKTO100 @Num, @Oper, @Msg output
   return(@vRet)
 end
  else  if @ToStat = 300
  begin
    exec @vRet = GOODSRECEIPT_CHKTO300 @Num, @Oper, @Msg output
    return(@vRet)
  end
  else begin
    Set @Msg = '未知状态！'
    return(1)
 end
 return(0)
end
GO
