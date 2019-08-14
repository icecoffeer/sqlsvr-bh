SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_CTDISEFFECT_ON_DELETE] (
  @piUUID varchar(32), 
  @piOper varchar(30),
  @poErrMsg varchar(255) output       --出错信息
)as
begin
  declare
    @vCardType varchar(20),
    @vBeginDate datetime,
    @vEndDate datetime
 
  --读取准备删除消费规则信息
  select @vCardType = CardType, @vBeginDate = BeginDate, @vEndDate = EndDate
  from PSCTDisEffect(nolock)  
  where UUID = @piUUID

  ---记录日志
  insert into PSCTDisEffectLog(CardType, BeginDate, EndDate, Note, Oper, Opertime)
  values(@vCardType, @vBeginDate, @vEndDate, '删除', @piOper,  getdate())

  ---更新结束日期  
  if convert(varchar(10), @vBeginDate, 102) < convert(varchar(10), getDate(), 102)
  begin
    update PSCTGDDisRule set EndDate = convert(varchar(10), getDate() - 1, 102) where UUID = @piUUID
  end else --开始日期大于当天的数据可以删除
  begin
    delete from PSCTDisEffect where UUID = @piUUID
  end 	 	 
  return(0)    
end

GO
