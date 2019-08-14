SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMAddIn_Card_RcvNCRMCardBlkLst] (
  @piSrc int,
  @piRcv int,
  @poMsg varchar(255) output
)
--with encryption 
as    
begin
  declare 
    @nCorrCount int, 
    @vZBGid int, 
    @CardNum varchar(20), 
    @Grade varchar(255),
    @Src int, 
    @ID int, 
    @SndTime datetime,
    @vSysUUID varchar(20)
    
  ---总部不能接收
  set @nCorrCount = 0
  
  ---控制总部不能接收黑名单
  select @vZBGid = ZBGid from FASystem(nolock) where ZBGid <> UserGid
  if @@rowcount = 0 
  begin
    set @poMsg = '总部不能接收黑名单'
    return(1)
  end
  
  declare curNCRMCardBlkLst cursor for
    select CardNum, Grade, Src, ID, SndTime, SysUUID
    from NCRMCardBlkLst(nolock) 
    where Src = @piSrc and Rcv = @piRcv and nType = 1
  open curNCRMCardBlkLst
  fetch next from curNCRMCardBlkLst into @CardNum, @Grade, @Src, @ID, @SndTime, @vSysUUID
  while @@fetch_status = 0 
  begin
	  delete from CRMCardBlkLst where CardNum = @CardNum 

    insert into CRMCardBlkLst(CardNum, Grade, SysUUID)
    values(@CardNum, @Grade, @vSysUUID)

    delete from NCRMCardBlkLst where Src = @Src and ID = @ID
    set @nCorrCount = @nCorrCount + 1
    fetch next from curNCRMCardBlkLst into @CardNum, @Grade, @Src, @ID, @SndTime, @vSysUUID       
  end
  close curNCRMCardBlkLst
  deallocate curNCRMCardBlkLst

  set @poMsg = '接收成功: ' + cast(@nCorrCount as varchar(10)) + '条' 
  return(0)
end
GO
