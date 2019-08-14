SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_DATAEXCHANGE_WEBEMP_SEND]    
(
  @piSrcOrg varchar(10),    
  @piDestOrg varchar(10)
) as
begin
  declare
    @vSendTime datetime, 
    @vGid int, 
    @vCount int,
    @vExchangeTime datetime, 
    @vSendCount int, 
    @vSysUUID varchar(20)    
  
  set @vSendCount = 0  
  set @vSendTime = getdate()
    
  select @vSysUUID = OptionValue from HDOption(nolock) where ModuleNo = 0 and OptionCaption = 'CRM_SYSUUID'
  if @@RowCount = 0
    set @vSysUUID = '-'
    
  select @vExchangeTime = FSendTime from CRMDataExgSendList(nolock) where Upper(FCls) = 'CRMWEBEMP' and FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg
  if @@RowCount = 0 
    set @vExchangeTime = '1900.01.01'
    
  declare c_WebEmp cursor for
    select Gid 
    from CRMWebEmp(nolock) 
    where LstUpdTime >= @vExchangeTime
  
  begin transaction  
  open c_WebEmp
  fetch next from c_WebEmp into @vGid
  while @@fetch_status = 0
  begin
    insert into CRMDataExgWebEmp(Gid, IsWebUser, WebPwd, StartDate, EndDate, 
      Ineffect, Store, Memo, Src, SndTime, 
      CreateTime, Creator, LstUpdTime, LstUpdOper, SysUUID, 
      FSendTime, FSrcOrg, FDestOrg)
    select Gid, IsWebUser, WebPwd, StartDate, EndDate, 
      Ineffect, Store, Memo, Src, @vSendTime, 
      CreateTime, Creator, LstUpdTime, LstUpdOper, @vSysUUID, 
      @vSendTime, @piSrcOrg, @piDestOrg 
    from CRMWebEmp(nolock) where Gid = @vGid
    
    insert into CRMDataExgSendLog(FSendTime, FCls, FUUID, FSrcUUID, FAction, FSrcOrg, FDestOrg)
    values(@vSendTime, 'CRMWEBEMP', Convert(varchar, @vGid), '', '成功', @piSrcOrg, @piDestOrg)
    set @vSendCount = @vSendCount + 1
    fetch next from c_WebEmp into @vGid
  end
  close c_WebEmp
  deallocate c_WebEmp
  
  if @vSendCount > 0
  begin
    set @vSendTime = DateAdd(second, 1, @vSendTime)
    select @vCount = Count(1) from CRMDataExgSendList(nolock) where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMWEBEMP'
    if @vCount > 0
      update CRMDataExgSendList set FSendTime = @vSendTime where FSrcOrg = @piSrcOrg and FDestOrg = @piDestOrg and Upper(FCls) = 'CRMWEBEMP'
    else
      insert into CRMDataExgSendList(FSendTime, FCls, FSrcOrg, FDestOrg) values(@vSendTime, 'CRMWEBEMP', @piSrcOrg, @piDestOrg) 
  end
  
  commit transaction
  return (0)  
end
GO
