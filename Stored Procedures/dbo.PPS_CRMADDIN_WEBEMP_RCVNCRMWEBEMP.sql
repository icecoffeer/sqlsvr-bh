SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMADDIN_WEBEMP_RCVNCRMWEBEMP]
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
    @Gid int,
    @IsWebUser smallint,
    @WebPwd varchar(32),
    @StartDate datetime,
    @EndDate datetime,
    @Ineffect smallint,
    @Store varchar(32),
    @Memo varchar(255),
    @Src int,
    @SndTime datetime,
    @CreateTime datetime, 
    @Creator varchar(30),
    @LstUpdOper varchar(30), 
    @LstUpdTime datetime,
    @ID int,
    @vSysUUID varchar(20)
    
  ---总部不能接收Web员工
  ---控制总部不能接收Web员工
  select @vZBGid = ZBGid from FASystem(nolock) where ZBGid <> UserGid   
  if @@ROWCOUNT = 0
  begin
    set @poMsg = '总部不能接收Web员工'
    return(1)
  end
  
  set @nCorrCount = 0 
  
  declare curNCRMWebEmp cursor for  
    select Gid, IsWebUser, WebPwd, StartDate, EndDate, Ineffect, Store,
    Memo, Src, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper, ID, SysUUID
    from NCRMWebEmp(nolock)
    where Src = @piSrc and Rcv = @piRcv and nType = 1
    
  open curNCRMWebEmp
  fetch next from curNCRMWebEmp into
    @Gid, @IsWebUser, @WebPwd, @StartDate, @EndDate, @Ineffect, @Store,
    @Memo, @Src, @SndTime, @CreateTime, @Creator, @LstUpdTime, @LstUpdOper, @ID, @vSysUUID
  while @@fetch_status = 0  
  begin 
    ---Web员工
    delete from CRMWebEmp where Gid = @Gid
    
    insert into CRMWebEmp(
      Gid, IsWebUser, WebPwd, StartDate, EndDate, Ineffect, Store,
      Memo, Src, SndTime, CreateTime, Creator, LstUpdTime, LstUpdOper, SysUUID)
    values(@Gid, @IsWebUser, @WebPwd, @StartDate, @EndDate, @Ineffect, @Store,
    @Memo, @Src,  @SndTime, @CreateTime, @Creator, @LstUpdTime, @LstUpdOper, @vSysUUID)
    delete from NCRMWebEmp where Src = @piSrc and Rcv = @piRcv and ID = @ID
    set @nCorrCount = @nCorrCount + 1        
    fetch next from curNCRMWebEmp into
      @Gid, @IsWebUser, @WebPwd, @StartDate, @EndDate, @Ineffect, @Store,
      @Memo, @Src, @SndTime, @CreateTime, @Creator, @LstUpdTime, @LstUpdOper, @ID, @vSysUUID
  end 
  close curNCRMWebEmp
  deallocate curNCRMWebEmp  
  set @poMsg = '接收成功: ' + Cast(@nCorrCount As varchar(10)) + '条'
  return(0)
end
GO
