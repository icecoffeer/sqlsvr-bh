SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_CTGDDISRULE_ON_DELETE] (
  @piUUID varchar(32), 
  @piOper varchar(30),
  @poErrMsg varchar(255) output       --出错信息
)as
begin
  declare
    @vCardType varchar(20),
    @vGDGid integer,
    @vGDQpc integer,
    @vDisCount decimal(24, 2),
    @vExDis integer,
    @vBeginDate datetime,
    @vEndDate datetime
 
  --读取准备删除消费规则信息
  select @vCardType = CardType, @vGDGid = GDGid, @vGDQpc = GDQpc, @vBeginDate =  BeginDate, @vDisCount = DisCount, @vExDis = ExDis 
  from PSCTGDDisRule(nolock)  
  where UUID = @piUUID

  ---记录日志
  insert into PSCTGDDisRuleLog(CardType, GDGid, GDQpc, Note, Oper, Opertime)
  values(@vCardType, @vGDGid, @vGDQpc, SubString('删除折扣率为: ' + convert(varchar(10), @vDisCount) + ' 折扣规则。开始日期：' + convert(varchar(10), @vBeginDate, 102), 1, 255),  @piOper,  getdate())

  ---更新结束日期  
  if convert(varchar(10), @vBeginDate, 102) < convert(varchar(10), getDate(), 102)
  begin
    update PSCTGDDisRule set EndDate = convert(varchar(10), getDate() - 1, 102) where UUID = @piUUID
  end else --当天的数据可以删除
  begin
    delete from PSCTGDDisRule where UUID = @piUUID
  end 	 	 
  return(0)    
end
GO
