SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create  procedure [dbo].[PCRM_CARD_DEPOSIT]
(
  @piAction varchar(10),         --动作
  @piCardNum varchar(20),        --卡号
  @piBalance money,              --余额
  @piAdjust money,               --调整金额
  @piOper varchar(70),           --操作员
  @piStore int,                  --门店
  @poErrMsg varchar(255) output  --出错信息
) as
begin
  declare @vCarrier int
  declare @nResult int
  declare @vStore varchar(70)
  declare @vHstNum varchar(26)

  select @vStore = UserGid from FASystem(nolock)
  select @vCarrier = Carrier  from CRMCard(noLock) where CardNum = @piCardNum
  
  exec @nResult = PCRM_CARD_GenHstNum @vHstNum output 
  
  insert into CRMCardDesHst(Num, CardNum, Carrier, OldBal, Occur)
  values(@vHstNum, @piCardNum, @vCarrier, @piBalance, @piAdjust)
  
  insert into CRMCardHst(Action, Store, CardNum, 
                         Oper, Carrier, Src, Num)
  values(@piAction, @piStore, @piCardNum, 
         @piOper, @vCarrier, @vStore, @vHstNum)
         
  return(0)   
end
GO
