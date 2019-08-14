SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDSALE_STAT_TO_300] (
  @piNum char(14),                    --单号
  @piOperGid int,                     --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vOper varchar(50)
  declare @vStat int
  declare @vRet int
  declare @vDebtPay decimal(24, 2)

  set @vRet = 1
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vStat = Stat, @vDebtPay = DebtPay from CRMCardSale where Num = @piNum
  if @vDebtPay <> 0
  begin
    set @poErrMsg = '账款未付清，不能完成。'  
    return(1)
  end
  if @vStat = 0 
  begin
    exec @vRet = PCRM_CARDSALE_STAT_TO_100 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 
    begin
      set @poErrMsg = '完成单据发生错误'  
      return(1)
    end
  end
  
  
  update CRMCARDSALE set 
    STAT = 300,
    MODIFIER = @vOper,
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_CARDSALE_ADD_LOG @piNum, 100, 300, @piOperGid
  return(0)
end
GO
