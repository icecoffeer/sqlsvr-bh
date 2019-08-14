SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_CARDBLKLST_RECEIVE]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vRecvTime datetime, 
    @vCardNum varchar(20),     
    @vSendTime datetime
    
  set @vRecvTime = getdate()
  declare c_CardBlkLst cursor for
    select CardNum, FSendTime
    from CRMDataExgCardBlkLst(nolock) 
    where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg 
    order by FSendTime
    
  open c_CardBlkLst
  fetch next from c_CardBlkLst into @vCardNum, @vSendTime
  while @@fetch_status = 0
  begin
    begin transaction
    delete from CRMCardBlkLst where CardNum = @vCardNum
    
    insert into CRMCardBlkLst(CardNum, Grade, SndTime, LstUpdTime, SysUUID)
    select CardNum, Grade, SndTime, LstUpdTime, SysUUID 
    from CRMDataExgCardBlkLst(nolock)
    where CardNum = @vCardNum and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    insert into CRMDataExgRecvLog(FRecvTime, FCls, FUUID, FSrcUUID, FAction, FSendTime, FSrcOrg, FDestOrg)
    values(@vRecvTime, 'CRMCARDBLKLST', @vCardNum, '', '成功', @vSendTime, @piSrcOrg, @piDestOrg)
  
    delete from CRMDataExgCardBlkLst where CardNum = @vCardNum and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    commit transaction
    fetch next from c_CardBlkLst into @vCardNum, @vSendTime
  end
  close c_CardBlkLst
  deallocate c_CardBlkLst  
  
  return (0)  
end
GO
