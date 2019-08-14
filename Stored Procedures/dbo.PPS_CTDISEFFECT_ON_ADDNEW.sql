SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_CTDISEFFECT_ON_ADDNEW] (
  @piUUID varchar(32), 
  @piOper varchar(30),
  @poErrMsg varchar(255) output       --出错信息
)as
begin
  declare
    @vCardType varchar(20),
    @vBeginDate datetime,
    @vEndDate datetime
  
  ---读取新增加卡类型规则信息
  select @vCardType = CardType, @vBeginDate =  BeginDate, @vEndDate = EndDate
  from PSCTDisEffect(nolock) where UUID = @piUUID

  ---记录日志
  insert into PSCTDisEffectLog(CardType, BeginDate, EndDate, Note, Oper, Opertime)
  values(@vCardType, @vBeginDate, @vEndDate, '增加',  @piOper,  getdate())

  return(0);  
end 
GO
