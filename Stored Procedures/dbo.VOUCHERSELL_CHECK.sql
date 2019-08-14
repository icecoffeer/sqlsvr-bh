SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERSELL_CHECK]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
 declare @vRet int
  if @ToStat = 100
  begin
    exec @vRet = VOUCHERSELL_CHKTO100 @Num, @Oper,  100, @Msg output
    return(@vRet)
  end
  else
  begin
     Set @Msg = '未知状态！'
     return(1)
  end
  return(0)
end
GO
