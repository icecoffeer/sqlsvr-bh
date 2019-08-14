SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_WEBSERVERADDR_SEND]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vSendTime datetime, 
    @vAddr varchar(100),     
    @vCount int,
    @vExchangeTime datetime, 
    @vSendCount int, 
    @vSysUUID varchar(20)    
    
  set @vSendCount = 0
  set @vSendTime = getdate()
    
  select @vSysUUID = OptionValue from HDOption(nolock) where ModuleNo = 0 and OptionCaption = 'CRM_SYSUUID'
  
  if @@rowCount = 0
    set @vSysUUID = '-'
    
  select @vExchangeTime = FSendTime from CRMDataExgSendList(nolock) where Upper(FCls) = 'CRMWEBSERVERADDR' and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg
  if @@rowCount = 0 
    set @vExchangeTime = '1900.01.01'
    
  declare c_WebServerAddr cursor for
    select Addr from CRMWebServerAddr(nolock) 
    where LstUpdTime >= @vExchangeTime
  
  begin transaction  
  open c_WebServerAddr
  fetch next from c_WebServerAddr into @vAddr
  while @@fetch_status = 0
  begin
    insert into CRMDataExgWebServerAddr(Addr, Memo, Src, SndTime, CreateTime, 
      Creator, LstUpdTime, LstUpdOper, Flag, SysUUID, 
      FSendTime, FSrcOrg, FDestOrg) 
    select Addr, Memo, Src, @vSendTime, CreateTime, 
      Creator, LstUpdTime, LstUpdOper, Flag, @vSysUUID, 
      @vSendTime, @piSrcOrg, @piDestOrg 
    from CRMWebServerAddr(nolock) where Addr = @vAddr
    
    insert into CRMDataExgSendLog(FSendTime, FCls, FUUID, FSrcUUID, FAction, FSrcOrg, FDestOrg)
    values(@vSendTime, 'CRMWEBSERVERADDR', Substring(@vAddr, 1, 50), '', '成功', @piSrcOrg, @piDestOrg)
    set @vSendCount = @vSendCount + 1
    fetch next from c_WebServerAddr into @vAddr
  end
  close c_WebServerAddr
  deallocate c_WebServerAddr
  
  if @vSendCount > 0
  begin
    set @vSendTime = DateAdd(second, 1, @vSendTime)
    select @vCount = Count(1) from CRMDataExgSendList(nolock) where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMWEBSERVERADDR'
    if @vCount > 0
      update CRMDataExgSendList set FSendTime = @vSendTime where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMWEBSERVERADDR'
    else
      insert into CRMDataExgSendList(FSendTime, FCls, FSrcOrg, FDestOrg) values(@vSendTime, 'CRMWEBSERVERADDR', @piSrcOrg, @piDestOrg)       
  end
  commit transaction  
  return (0)  
end
GO
