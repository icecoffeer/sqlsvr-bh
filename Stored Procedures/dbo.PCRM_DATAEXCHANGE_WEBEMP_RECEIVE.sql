SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_WEBEMP_RECEIVE]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vRecvTime datetime, 
    @vGid int, 
    @vSendTime datetime
    
  set @vRecvTime = getdate()
  
  declare c_WebEmp cursor for
    select Gid, FSendTime
    from CRMDataExgWebEmp(nolock) 
    where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg
    order by FSendTime 
    
  open c_WebEmp
  fetch next from c_WebEmp into @vGid, @vSendTime
  while @@fetch_status = 0
  begin
    begin transaction   
    delete from CRMWebEmp where Gid = @vGid
    
    insert into CRMWebEmp(Gid, IsWebUser, WebPwd, StartDate, EndDate, 
      Ineffect, Store, Memo, Src, SndTime, 
      CreateTime, Creator, LstUpdTime, LstUpdOper, SysUUID)
    select Gid, IsWebUser, WebPwd, StartDate, EndDate, 
      Ineffect, Store, Memo, Src, SndTime, 
      CreateTime, Creator, LstUpdTime, LstUpdOper, SysUUID 
    from CRMDataExgWebEmp(nolock)
    where Gid = @vGid and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    
    insert into CRMDataExgRecvLog(FRecvTime, FCls, FUUID, FSrcUUID, FAction, FSendTime, FSrcOrg, FDestOrg)
     values(@vRecvTime, 'CRMWEBEMP', Convert(varchar, @vGid), '', '成功', @vSendTime, @piSrcOrg, @piDestOrg)
     
    delete from CRMDataExgWebEmp where Gid = @vGid and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    commit transaction   
    fetch next from c_WebEmp into @vGid, @vSendTime
  end
  close c_WebEmp
  deallocate c_WebEmp   

  return (0)  
end
GO
