SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMADDIN_WEBSERVERADDR_RCVNCRMWEBSERVERADDR]
(
  @piSrc int,
  @piRcv int,
  @poMsg varchar output      
)
--with encryption
as    
begin
  declare  
    @vZBGid int, 
    @nCorrCount int,
    @Addr varchar(200),
    @Memo varchar(255),
    @Src int, 
    @SndTime datetime,
    @CreateTime datetime,
    @Creator varchar(30),
    @LstUpdTime datetime,
    @LstUpdOper varchar(30),
    @ID int,
    @Flag varchar(10), 
    @vSysUUID varchar(20)
   
  ---总部不能接收Web地址
  ---控制总部不能接收Web地址
  select @vZBGid = ZBGid from FASystem(nolock) where ZBGid <> UserGid   
  if @@ROWCOUNT = 0
  begin
    set @poMsg = '总部不能接收Web地址'
    return(1)
  end
  
  set @nCorrCount = 0 
  
  declare curNCRMWEBSERVERADDR cursor for  
    select Addr, Memo, Src, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper, ID, Flag, SysUUID
    from NCRMWEBSERVERADDR(nolock)
    where Src = @piSrc and Rcv = @piRcv and nType = 1
    
  open curNCRMWEBSERVERADDR
  fetch next from curNCRMWEBSERVERADDR into
    @Addr, @Memo, @Src, @SndTime, @CreateTime, @Creator, @LstUpdTime, @LstUpdOper, @ID, @Flag, @vSysUUID
  while @@fetch_status = 0  
  begin 
    ---Web地址
    delete from CRMWEBSERVERADDR where Addr = @Addr
    
    insert into CRMWEBSERVERADDR(Addr, Memo, Src, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper, Flag, SysUUID)
      values(@Addr, @Memo, @Src, @SndTime, @CreateTime, @Creator, @LstUpdTime, @LstUpdOper, @Flag, @vSysUUID)
    delete from NCRMWEBSERVERADDR where Src = @piSrc and Rcv = @piRcv and ID = @ID
    set @nCorrCount = @nCorrCount + 1        
    fetch next from curNCRMWEBSERVERADDR into
      @Addr, @Memo, @Src, @SndTime, @CreateTime, @Creator, @LstUpdTime, @LstUpdOper, @ID, @Flag, @vSysUUID
  end 
  close curNCRMWEBSERVERADDR
  deallocate curNCRMWEBSERVERADDR  
  set @poMsg = '接收成功: ' + Cast(@nCorrCount As varchar(10)) + '条'
  return(0)
end
GO
