SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMAddIn_Card_SendNCRMCardBlkLst] (
  @piRcv int,
  @poMsg varchar(255) output
) 
--with encryption
as
begin
  declare
    @vSrc int, 
    @vID int, 
    @nCorrCount int, 
    @CardNum varchar(20),
    @vSysUUID varchar(20)
    
  ---非总部不能发送黑名单     
  select @vSrc = UserGid from FASystem(nolock) where UserGid = ZBGid
  if @@ROWCOUNT = 0 
  begin
    set @poMsg = '不是总部，不能发送黑名单'
    return(1)
  end
  
  --读取SysUUID系统选项
 -- select @vSysUUID = OptionValue from HDOption(nolock) where OptionCaption = 'CRM_SYSUUID' and ModuleNo = 0  
 -- if @@ROWCOUNT = 0
 -- begin
 --   set @poMsg = '请配置系统选项 CRM_SYSUUID'
 --   return(1)
 -- end 

  set @nCorrCount = 0
  
  declare curBlkLst cursor for 
    select CardNum from CRMCardBlkLst(nolock)
  open curBlkLst
  fetch next from curBlkLst into @CardNum
  while @@fetch_status = 0 
  begin 
    --判断缓冲区中是否有相同的记录，有则先删除
    select @vID = max(ID) from NCRMCardBlkLst where CardNum = @CardNum and Rcv = @piRcv and NType = 0
    delete from NCRMCardBlkLst where CardNum = @CardNum and Rcv = @piRcv   
    ---取得ID号
    exec @vID = SeqNextvalue 'NCRMCARDBLKLST'
    ---插入黑名单数据
    insert into NCRMCardBlkLst(
                CardNum, Grade, Src, ID, SndTime,
                Rcv, Rcvtime, FrcChk, NType, NStat,
                NNote, SysUUID)
    select CardNum, Grade, @vSrc, @vID, GetDate(), 
      @piRcv, null, 1, 0, 0, 
      '', SysUUID
    from CRMCardBlkLst(nolock) 
    where CardNum = @CardNum
    
    update CRMCardBlkLst set SndTime = GetDate() where CardNum = @CardNum
    set @nCorrCount = @nCorrCount + 1
    fetch next from curBlkLst into @CardNum  
  end
  close curBlkLst
  deallocate curBlkLst
  set @poMsg = '发送成功: ' + Cast(@nCorrCount as varchar(10)) + '条' 
  return(0)
end
GO
