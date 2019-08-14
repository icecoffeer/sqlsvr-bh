SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_MscbNotify_AppendNotify] (
  @piSubjectClass varchar(128),   --订阅主题类名，等价于消息订阅单中订阅主题类名
  @piEvent varchar(32),           --订阅主题类名中指定的事件名称，等价于消息订阅单中的订阅主题类名
  @piDict varchar(2000),          --序列化的数据字典字符串，序列化方法可参照PFA_SerializeXml中SetString等接口方法
  @piPmptCtx varchar(2000),       --序列化的提醒上下文字符串,序列化方法可参照PFA_SerializeXml中SetString等接口方法
  @piOperTime DATETIME,           --消息动作触发的时间,如单据审核时间
  @piOperId int,                  --消息动作触发人的GID,如审核人,如果没有明确触发人的GID,用默认值1
  @piOperCode varchar(10),        --消息动作触发人的代码,如审核人,如果没有明确触发人的代码,用默认值-
  @piOperName varchar(20),        --消息动作触发人的名称,如审核人,如果没有明确触发人的名称,用默认值未知
  @poErrMsg varchar(255) output    --错误信息,返回参数
) as  
begin
  declare
    @Dict varchar(2100),
    @PmptCtx varchar(2000),
    @Guid varchar(64),
    @domainCode varchar(10)
    exec PFA_SERIALIZEXML_SERIALIZEMAP 'dict', @piDict, @Dict output
    exec PFA_SERIALIZEXML_SERIALIZEMAP 'promptContent', @piPmptCtx, @pmptCtx output
    select @Guid = NewID()    
    select @domainCode = rtrim(USERCODE) from FASYSTEM;            
    insert into FAMSCBNOTIFY (UUID, DOMAINCODE, SUBJECTCLASS, EVENT, DICT, PMPTCTX, OPERTIME, OPERID, OPERCODE, OPERNAME)
      values(@Guid, @domainCode, @piSubjectClass, @piEvent, @dict, @PmptCtx, @piOperTime, @piOperId, @piOperCode, @piOperName);        
    --触发“全部”
    select @Guid = NewID()
    insert into FAMSCBNOTIFY (UUID, DOMAINCODE, SUBJECTCLASS, EVENT, DICT, PMPTCTX, OPERTIME, OPERID, OPERCODE, OPERNAME)
      values(@Guid, @domainCode, @piSubjectClass, '全部', @dict, @PmptCtx, @piOperTime, @piOperId, @piOperCode, @piOperName);        
  return 0
end
GO
