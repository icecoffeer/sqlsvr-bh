SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_CARDBLKLST_SEND]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vSendTime datetime, 
    @vCardNum varchar(20), 
    @vExchangeTime datetime, 
    @vSendCount int, 
    @vSysUUID varchar(20),
    @vCount int    
    
  set @vSendCount = 0
  set @vSendTime = getdate()
  
  select @vSysUUID = OptionValue from HDOption(nolock) where ModuleNo = 0 and OptionCaption = 'CRM_SYSUUID'
  if @@RowCount = 0
    set @vSysUUID = '-'
    
  select @vExchangeTime = FSendTime from CRMDataExgSendList(nolock) where Upper(FCls) = 'CRMCARDBLKLST' and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg
  if @@RowCount = 0 
    set @vExchangeTime = '1900.01.01'
    
  declare c_CardBlkLst cursor for
    select CardNum 
    from CRMCardBlkLst(nolock) 
    where LstUpdTime >= @vExchangeTime
  
  begin transaction  
  open c_CardBlkLst
  fetch next from c_CardBlkLst into @vCardNum
  while @@fetch_status = 0
  begin
    insert into CRMDataExgCardBlkLst(CardNum, Grade, SndTime, LstUpdTime, SysUUID, 
      FSendTime, FSrcOrg, FDestOrg)
    select CardNum, Grade, @vSendTime, LstUpdTime, @vSysUUID, 
      @vSendTime, @piSrcOrg, @piDestOrg 
    from CRMCardBlkLst(nolock) 
    where CardNum = @vCardNum
    
    insert into CRMDataExgSendLog(FSendTime, FCls, FUUID, FSrcUUID, FAction, FSrcOrg, FDestOrg)
    values(@vSendTime, 'CRMCARDBLKLST', @vCardNum, '', '成功', @piSrcOrg, @piDestOrg)
      set @vSendCount = @vSendCount + 1
    
    fetch next from c_CardBlkLst into @vCardNum
  end
  close c_CardBlkLst
  deallocate c_CardBlkLst
  
  if @vSendCount > 0
  begin
    set @vSendTime = DateAdd(second, 1, @vSendTime)
    select @vCount = Count(1) from CRMDataExgSendList(nolock) where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMCARDBLKLST'
    if @vCount > 0
      update CRMDataExgSendList set FSendTime = @vSendTime where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMCARDBLKLST'
    else
      insert into CRMDataExgSendList(FSendTime, FCls, FSrcOrg, FDestOrg) values(@vSendTime, 'CRMCARDBLKLST', @piSrcOrg, @piDestOrg) 
  end
  
  commit transaction
  return (0)  
end
GO
