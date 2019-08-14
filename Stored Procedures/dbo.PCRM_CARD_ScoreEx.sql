SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create  procedure [dbo].[PCRM_CARD_ScoreEx]
(
  @piAction varchar(10),         --动作
  @piCardNum varchar(20),        --卡号
  @piScoreSort varchar(20),      --积分类别
  @piScoreSubject varchar(10),   --积分科目
  @piScore money,                --积分
  @piOldScore money,             --原积分
  @piOperGid int,                --操作员
  @poHstNum varchar(26) output,   --记录号
  @poErrMsg varchar(255) output  --出错信息
) as
begin
  declare @vStore int
  declare @vCarrier int
  declare @vOper varchar(30)
  declare @nResult int
  declare @vHstNum varchar(26)

  select @vStore = UserGid from FASystem(noLock)
  select @vCarrier = Carrier  from CRMCard(noLock)
  where CardNum = @piCardNum
  select @vOper = SubString(Ltrim(Rtrim(Name)) + '[' + LTrim(Rtrim(Code)) + ']', 1, 30) from Employee(noLock)
  where Gid = @piOperGid
  
  exec @nResult = PCRM_CARD_GenHstNum @vHstNum output 
                                                                         
  insert into CRMCardScoHst(Num, CardNum, Carrier, Score, ScoreSubject, ScoreSort, OldScore)
  values(@vHstNum, @piCardNum, @vCarrier, @piScore, @piScoreSubject, @piScoreSort, @piOldScore)
  
  insert into CRMCardHst(Action, Store, CardNum, 
                         Oper, Carrier, Src, Num)
  values(@piAction, @vStore, @piCardNum, 
         @vOper, @vCarrier, @vStore, @vHstNum)
         
  select @poHstNum = @vHstNum       
  return(0)   
end
GO
