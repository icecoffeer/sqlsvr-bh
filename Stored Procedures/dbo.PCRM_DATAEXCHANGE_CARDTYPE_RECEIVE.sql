SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_CARDTYPE_RECEIVE]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vRecvTime datetime, 
    @vCode varchar(10),     
    @vSendTime datetime
    
  set @vRecvTime = getdate()
  
  declare c_CardType cursor for
    select Code, FSendTime from CRMDataExgCardType(nolock) where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg 
    order by FSendTime
 
  open c_CardType
  fetch next from c_CardType into @vCode, @vSendTime
  while @@fetch_status = 0
  begin
    begin transaction  
    delete from CRMCardType where Code = @vCode
    
    insert into CRMCardType(Code, Name, CardType, Parvalue, DisCount, 
      CardCost, CardUsage, Medium, MsPrc, MpPrc, 
      McPrc, ValidPrd, AbortPrc, ResumePrc, BackPrc, 
      Tranrate, Creator, CreateTime, LstUpdOper, LstUpdTime, 
      SndTime, SysUUID, MbrGenMode)
    select Code, Name, CardType, Parvalue, DisCount, 
      CardCost, CardUsage, Medium, MsPrc, MpPrc, 
      McPrc, ValidPrd, AbortPrc, ResumePrc, BackPrc, 
      Tranrate, Creator, CreateTime, LstUpdOper, LstUpdTime, 
      SndTime, SysUUID, MbrGenMode
    from CRMDataExgCardType(nolock) 
    where Code = @vCode and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    
    insert into CRMDataExgRecvLog(FRecvTime, FCls, FUUID, FSrcUUID, FAction, FSendTime, FSrcOrg, FDestOrg)
    values(@vRecvTime, 'CRMCARDTYPE', @vCode, '', '成功', @vSendTime, @piSrcOrg, @piDestOrg)
    
    delete from CRMDataExgCardType where Code = @vCode and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and FSendTime = @vSendTime
    
    commit transaction  
    fetch next from c_CardType into @vCode, @vSendTime
  end
  close c_CardType
  deallocate c_CardType    
  return (0)  
end
GO
