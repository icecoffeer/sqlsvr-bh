SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMADDIN_WEBEMP_SENDNCRMWEBEMP]
(
  @piGid int,    
  @piRcv int,    
  @poMsg varchar(255) output      
)
--with encryption
as    
begin
  declare  
    @nID int,
    @nSrc int,
    @vZBGid int
      
  ---非总部不能发送Web员工
  select @vZBGid = ZBGid, @nSrc = UserGid  from FASystem(nolock) where ZBGid = UserGid   
  if @@ROWCOUNT = 0
  begin
    set @poMsg = '非总部不能发Web员工'
    return(1)
  end  
  
  --读取SysUUID系统选项
  --select @vSysUUID = OptionValue from HDOption(nolock) where OptionCaption = 'CRM_SYSUUID' and ModuleNo = 0  
  --if @@ROWCOUNT = 0
  --begin
  --  set @poMsg = '请配置系统选项 CRM_SYSUUID'
  --  return(1)
  --end   
  
  
  delete from NCRMWebEmp where Gid = @piGid and Rcv = @piRcv
  
  EXEC @nID = SEQNEXTVALUE 'NCRMWEBEMP'
  
  insert into NCRMWEBEMP(Src, ID, Rcv, FrcChk, Ntype, NStat, 
    Gid, IsWebUser, WebPwd, StartDate, EndDate, Ineffect, Store,
    Memo, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper, SysUUID)
  select @nSrc, @nID, @piRcv, 1, 0, 0,
    Gid, IsWebUser, WebPwd, StartDate, EndDate, Ineffect, Store,
    Memo, getdate(), CreateTime, Creator, LstUpdTime, LstUpdOper, SysUUID
  from CRMWEBEMP (nolock)
  where Gid = @piGid
  update CRMWEBEMP set SndTime = getdate() where Gid = @piGid
  return 0     
end
GO
