SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_WEBSERVERADDR_RECEIVE]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vRecvTime datetime, 
    @vAddr varchar(100), 
    @vSendTime datetime
    
  set @vRecvTime = getdate()
  declare c_WebServerAddr cursor for
    select Addr, FSendTime 
    from CRMDataExgWebServerAddr(nolock) 
    where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg 
    order by FSendTime
    
  open c_WebServerAddr
  fetch next from c_WebServerAddr into @vAddr, @vSendTime
  while @@fetch_status = 0
  begin    
  	begin transaction
    delete from CRMWebServerAddr where Addr = @vAddr
    
    insert into CRMWebServerAddr(Addr, Memo, Src, SndTime, CreateTime, 
      Creator, LstUpdTime, LstUpdOper, Flag, SysUUID)
    select Addr, Memo, Src, SndTime, CreateTime, 
      Creator, LstUpdTime, LstUpdOper, Flag, SysUUID 
    from CRMDataExgWebServerAddr(nolock)
    where Addr = @vAddr and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    insert into CRMDataExgRecvLog(FRecvTime, FCls, FUUID, FSrcUUID, FAction, FSendTime, FSrcOrg, FDestOrg)
    values(@vRecvTime, 'CRMWEBSERVERADDR', Substring(@vAddr, 1, 50), '', '成功', @vSendTime, @piSrcOrg, @piDestOrg)
  
    delete from CRMDataExgWebServerAddr where Addr = @vAddr and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    commit transaction
    fetch next from c_WebServerAddr into @vAddr, @vSendTime
  end
  close c_WebServerAddr
  deallocate c_WebServerAddr   
  
  return (0)  
end
GO
