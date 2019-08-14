SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMADDIN_WEBSERVERADDR_SENDNCRMWEBSERVERADDR]
(
  @piAddr varchar(200),
  @piRcv int,    
  @poMsg varchar output      
)
--with encryption
as    
begin
  declare  
    @nID int,
    @nSrc int,
    @vAddr varchar(200),
    @vZBGid int,
    @vSysUUID varchar(20)
  
  ---非总部不能发送Web地址
  ---控制非总部不能发送Web地址
  select @vZBGid = ZBGid  from FASystem(nolock) where ZBGid = UserGid   
  if @@ROWCOUNT = 0
  begin
    set @poMsg = '非总部不能发Web地址'
    return(1)
  end 
  
  --读取SysUUID系统选项
  --select @vSysUUID = OptionValue from HDOption(nolock) where OptionCaption = 'CRM_SYSUUID' and ModuleNo = 0  
  --if @@ROWCOUNT = 0
  --begin
  --  set @poMsg = '请配置系统选项 CRM_SYSUUID'
  --  return(1)
  --end 

  select @nSrc = UserGid from FASystem(nolock)
  
  delete from NCRMWebServerAddr where Addr = @piAddr and Rcv = @piRcv
  EXEC @nID = SEQNEXTVALUE 'NCRMWEBSERVERADDR'
  insert into NCRMWEBSERVERADDR(Src, ID, Rcv, FrcChk, Ntype, NStat, 
    Addr, Memo, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper,Flag, SysUUID)
  select @nSrc, @nID, @piRcv, 1, 0, 0,
    Addr, Memo, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper,Flag, SysUUID
  from CRMWEBSERVERADDR(nolock)
  where Addr = @piAddr
  return 0  
end
GO
