SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_CARDTYPE_SEND]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vSendTime datetime, 
    @vCode varchar(10), 
    @vCount int,
    @vExchangeTime datetime, 
    @vSendCount int, 
    @vSysUUID varchar(20)
    
  set @vSendCount = 0
  set @vSendTime = getdate()
   
  select @vSysUUID = OptionValue from HDOption(nolock) where ModuleNo = 0 and OptionCaption = 'CRM_SYSUUID'
  
  if @@RowCount = 0
    set @vSysUUID = '-'
    
  select @vExchangeTime = FSendTime from CRMDataExgSendList(nolock) where Upper(FCls) = 'CRMCARDTYPE' and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg
  
  if @@rowCount = 0 
    set @vExchangeTime = '1900.01.01'
    
  declare c_CardType cursor for
    select Code from CRMCardType(nolock) 
    where LstUpdTime >= @vExchangeTime
    
  begin transaction
  open c_CardType
  fetch next from c_CardType into @vCode 
  while @@fetch_status = 0
  begin
    insert into CRMDataExgCardType(Code, Name, CardType, Parvalue, DisCount, CardCost, CardUsage, Medium,
      MsPrc, MpPrc, McPrc, ValidPrd, AbortPrc, ResumePrc, BackPrc, Tranrate,
      Creator, CreateTime, LstUpdOper, LstUpdTime, SndTime, SysUUID, MbrGenMode, FSendTime, 
      FSrcOrg, FDestOrg) 
    select Code, Name, CardType, Parvalue, DisCount, CardCost, CardUsage, Medium,
      MsPrc, MpPrc, McPrc, ValidPrd, AbortPrc, ResumePrc, BackPrc, Tranrate,
      Creator, CreateTime, LstUpdOper, LstUpdTime, @vSendTime, @vSysUUID, MbrGenMode, @vSendTime,
      @piSrcOrg, @piDestOrg 
    from CRMCardType(nolock) where Code = @vCode
    
    insert into CRMDataExgSendLog(FSendTime, FCls, FUUID, FSrcUUID, FAction, FSrcOrg, FDestOrg)
    values(@vSendTime, 'CRMCARDTYPE', @vCode, '', '成功', @piSrcOrg, @piDestOrg)
    
    set @vSendCount = @vSendCount + 1
    
    fetch next from c_CardType into @vCode
  end
  close c_CardType
  deallocate c_CardType
  
  if @vSendCount > 0 
  begin
    set @vSendTime = DateAdd(second, 1, @vSendTime)
    select @vCount = count(1) from CRMDataExgSendList(nolock) where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMCARDTYPE'
    if @vCount > 0
      update CRMDataExgSendList set FSendTime = @vSendTime where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMCARDTYPE'
    else
      insert into CRMDataExgSendList(FSendTime, FCls, FSrcOrg, FDestOrg) values(@vSendTime, 'CRMCARDTYPE', @piSrcOrg, @piDestOrg)  
  end
  commit transaction
    
  return (0)  
end
GO
