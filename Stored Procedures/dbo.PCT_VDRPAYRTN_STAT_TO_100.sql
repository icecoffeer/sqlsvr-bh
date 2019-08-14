SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_VDRPAYRTN_STAT_TO_100] (
  @piNum varchar(14),
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vVdrPayNum varchar(14)
  declare @vVdrPayTotal decimal(24, 2)
  declare @vRtnTotal decimal(24, 2)

  select @vVdrPayNum = VDRPAYNUM from CTVDRPAYRTN where NUM = @piNum
  select @vVdrPayTotal = PAYTOTAL from VDRPAY where NUM = @vVdrPayNum
  select @vRtnTotal = isnull(sum(TOTAL), 0) from CTVDRPAYRTN where VDRPAYNUM = @vVdrPayNum
  if @vRtnTotal > isnull(@vVdrPayTotal, 0)
  begin
    set @poErrMsg = '退款金额不能超过交款金额。'
    return(1)
  end
  
  update CTVDRPAYRTN set 
    STAT = 100,
    CHECKER = @piOperGid,
    CHKDATE = getdate()
  where NUM = @piNum
  
  update CTVDRPAYRTN set 
    SRC = (select usergid from fasystem(nolock))
  where NUM = @piNum and src is null
  
  return(0)
end
GO
