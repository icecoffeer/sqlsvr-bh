SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PCRM_CARDTYPESUBJECTINV_CHECKACTOINUPDINV]
(
  @piUserGid int,                               ---门店
  @piAction varchar(20),                        ---动作
  @piCardType varchar(20),                      ---卡类型
  @piUpdTime datetime,                          ---更新时间
  @piOperTime datetime,                         ---操作时间
  @poErrMsg varchar(255) output                 ---返回出错信息
)
as
begin
  declare @vLstUpdTime  datetime  ---最后更新时间
  declare @vQty int               ---数量
  declare @vResult int            ---中间结果
  declare @vCount int             ---计数
  declare @vNote  varchar(255)    ---备注
  
  ---取最后更新时间
  select @vLstUpdTime = LstUpdTime from CRMCardTypeInvActionUpd(nolock) where Action = @piAction and CardType = @piCardType
  if @@RowCount = 0 
  begin
    select @vLstUpdTime = '2000.01.01'
    begin transaction                  
    insert into CRMCardTypeInvActionUpd(Action, CardType, LstUpdTime) values(@piAction, @piCardType, @vLstUpdTime)
    commit
  end
    
  if @piUpdTime <= @vLstUpdTime   
    return(0)
    
  select @vQty = count(1) from CRMCardCheckLog(nolock)
  where CardType = @piCardType and LstUpdTime >= @vLstUpdTime and LstUpdTime < @piUpdTime
  select @vNote = Ltrim(Rtrim(@piAction)) + '。开始时间：' + convert(varchar(25), @vLstUpdTime, 121) + '，结束时间：' + convert(varchar(25), @piUpdTime, 121)
 
  if @vQty > 0 
  begin 
    begin transaction                                     
    exec @vResult = PCRM_CARDTYPESUBJECTINV_UPDINV @piUserGid, @piCardType, -1, @vQty, 500, 600, '系统', @vNote, @poErrMsg output
    if @vResult = 0  ---更新库存成功
    begin
      ---记录更新
      select @vNote = SubString('数量：' + convert(varchar, @vQty, 10) + '。执行时间范围：' + convert(varchar(25), @vLstUpdTime, 121) + '---' + convert(varchar(25), @piUpdTime, 121), 1, 254)
      insert into CRMCardTypeInvActionUpdList(UUID, Action, CardType, OperNote, OperTime, Note)
      values(replace(newid(), '-', ''), @piAction, @piCardType, '成功', @piOperTime, @vNote)
  
      --记录日志
      insert into CRMCardTypeInvActionUpdLog(UUID, Action, OperTime, CardNum, CardType, Carrier)
      select replace(newid(), '-', ''), Action, @piOperTime, CardNum, CardType, Carrier from CRMCardHst(nolock)
      where Action = @piAction and CardType = @piCardType and LstUpdTime >= @vLstUpdTime and LstUpdTime < @piUpdTime
  
      ---更新最后更新时间
      select @vNote = '上次执行时间范围：' + convert(varchar(25), @vLstUpdTime, 121) + '---' + convert(varchar(25), @piUpdTime, 121)
      update CRMCardTypeInvActionUpd set LstUpdTime = @piUpdTime, Note = @vNote 
      where Action = @piAction and CardType = @piCardType
      commit  
      return(0)          
    end
    else begin---更新失败 
      rollback         
      select @vNote = SubString('数量：' + convert(varchar, @vQty, 10) + '。执行时间范围：' + convert(varchar(25), @vLstUpdTime, 121) + '---' + convert(varchar(25), @piUpdTime, 121) + '。错误：' + @poErrMsg, 1, 254)
      begin transaction                         
      insert into CRMCardTypeInvActionUpdList(UUID, Action, Cardtype, OperNote, OperTime, Note)
      values(replace(newid(), '-', ''), @piAction, @piCardType, '失败', @piOperTime, @vNote)
      commit
      return(1)
    end
  end
end
GO
