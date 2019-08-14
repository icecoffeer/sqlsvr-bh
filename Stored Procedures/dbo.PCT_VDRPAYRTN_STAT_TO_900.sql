SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_VDRPAYRTN_STAT_TO_900] (
  @piNum varchar(14),
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vVdrPayNum varchar(14)
  declare @vVdrPayTotal decimal(24, 2)
  declare @vRtnTotal decimal(24, 2)
  declare @vRet int
  declare @Src int
  declare @vOper varchar(50)

  select @vVdrPayNum = VDRPAYNUM, @Src = SRC from CTVDRPAYRTN where NUM = @piNum
  select @vVdrPayTotal = PAYTOTAL from VDRPAY where NUM = @vVdrPayNum
  select @vRtnTotal = isnull(sum(TOTAL), 0) from CTVDRPAYRTN where VDRPAYNUM = @vVdrPayNum
  if @vRtnTotal > isnull(@vVdrPayTotal, 0)
  begin
    set @poErrMsg = '退款金额不能超过交款金额。'
    return(1)
  end

  update CTVDRPAYRTN set 
    STAT = 900
  where NUM = @piNum
  
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  if @src = (select usergid from FaSystem(nolock)) 
  begin
    exec @vRet = VDRPAYRTNSEND null, @piNum, @vOper, 0, @poErrMsg output
    if @vRet > 0 return @vRet
  end

  return(0)
end
GO
