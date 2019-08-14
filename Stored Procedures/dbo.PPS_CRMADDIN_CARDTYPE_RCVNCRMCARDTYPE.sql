SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMADDIN_CARDTYPE_RCVNCRMCARDTYPE] 
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
    @Code varchar(10),   
    @Name varchar(20),  
    @CardType varchar(10),  
    @DisCount money,   
    @ParValue money,  
    @CardCost money,   
    @CardUsage int,   
    @Medium varchar(20),   
    @MsPrc money, @MpPrc money,  
    @McPrc money,   
    @ValidPrd int, @AbortPrc money,   
    @BackPrc money, @ResumePrc money,  
    @Tranrate money, @Creator varchar(30),   
    @CreateTime datetime,   
    @LstUpdOper varchar(30),   
    @LstUpdTime datetime,  
    @SndTime datetime,   
    @ID int,  
    @vSysUUID varchar(20),  
    @usercode varchar(20)  
  
  ---总部不能接收卡类型  
  ---控制总部不能接收卡类型  
  select @vZBGid = ZBGid from FASystem(nolock) where ZBGid <> UserGid     
  if @@ROWCOUNT = 0  
  begin  
    set @poMsg = '总部不能接收卡类型'  
    return(1)  
  end  
    
  select @usercode = usercode from FASystem(nolock)  
  set @nCorrCount = 0   
    
  declare curNCRMCardType cursor for    
    select Code, Name, CardType, DisCount, ParValue,  
      CardCost, CardUsage, Medium, MsPrc, MpPrc,  
      McPrc, ValidPrd, AbortPrc, BackPrc, ResumePrc,  
      Tranrate, Creator, CreateTime, LstUpdOper, LstUpdTime,  
      SndTime, ID, SysUUID  
    from NCRMCardType(nolock)  
    where Src = @piSrc and Rcv = @piRcv and nType = 1  
      
  open curNCRMCardType  
  fetch next from curNCRMCardType into  
    @Code, @Name, @CardType, @DisCount, @ParValue,  
    @CardCost, @CardUsage, @Medium, @MsPrc, @MpPrc,  
    @McPrc, @ValidPrd, @AbortPrc, @BackPrc, @ResumePrc,  
    @Tranrate, @Creator, @CreateTime, @LstUpdOper, @LstUpdTime,  
    @SndTime, @ID, @vSysUUID  
      
  while @@fetch_status = 0    
  begin   
    ---卡类型  
    delete from CRMCardType where Code = @Code
      
    --会员卡卡类型按超市、百货业态区分：超市的会员卡只有会员和积分功能1001000000，百货的会员卡只有折扣和积分功能0101000000 
    if @vSysUUID='ZHSCO'    --积分卡
    begin 
      if len(@usercode)=4   --超市
      insert into CRMCardType(  
        Code, Name, CardType, DisCount, ParValue,  
        CardCost, CardUsage, Medium, MsPrc, MpPrc,  
        McPrc, ValidPrd, AbortPrc, BackPrc, ResumePrc,  
        Tranrate, Creator, CreateTime, LstUpdOper, LstUpdTime,   
        SndTime, SysUUID)  
      values(@Code, @Name, '1001000000', @DisCount, @ParValue,  
        @CardCost, @CardUsage, @Medium, @MsPrc, @MpPrc,  
        @McPrc, @ValidPrd, @AbortPrc, @BackPrc, @ResumePrc,  
        @Tranrate, @Creator, @CreateTime, @LstUpdOper, @LstUpdTime,   
        @SndTime, @vSysUUID)
  
      else if len(@usercode)=2  --百货
      insert into CRMCardType(  
        Code, Name, CardType, DisCount, ParValue,  
        CardCost, CardUsage, Medium, MsPrc, MpPrc,  
        McPrc, ValidPrd, AbortPrc, BackPrc, ResumePrc,  
        Tranrate, Creator, CreateTime, LstUpdOper, LstUpdTime,   
        SndTime, SysUUID)  
      values(@Code, @Name, '0101000000', @DisCount, @ParValue,  
        @CardCost, @CardUsage, @Medium, @MsPrc, @MpPrc,  
        @McPrc, @ValidPrd, @AbortPrc, @BackPrc, @ResumePrc,  
        @Tranrate, @Creator, @CreateTime, @LstUpdOper, @LstUpdTime,   
        @SndTime, @vSysUUID)
     end

       else if @vSysUUID='ZHDES'    --储值卡
       insert into CRMCardType(  
         Code, Name, CardType, DisCount, ParValue,  
         CardCost, CardUsage, Medium, MsPrc, MpPrc,  
         McPrc, ValidPrd, AbortPrc, BackPrc, ResumePrc,  
         Tranrate, Creator, CreateTime, LstUpdOper, LstUpdTime,   
         SndTime, SysUUID)  
       values(@Code, @Name, @CardType, @DisCount, @ParValue,  
         @CardCost, @CardUsage, @Medium, @MsPrc, @MpPrc,  
         @McPrc, @ValidPrd, @AbortPrc, @BackPrc, @ResumePrc,  
         @Tranrate, @Creator, @CreateTime, @LstUpdOper, @LstUpdTime,   
         @SndTime, @vSysUUID)
       
  
  
    delete from NCRMCardType where Src = @piSrc and Rcv = @piRcv and ID = @ID;   
    set @nCorrCount = @nCorrCount + 1          
    fetch next from curNCRMCardType into  
      @Code, @Name, @CardType, @DisCount, @ParValue,  
      @CardCost, @CardUsage, @Medium, @MsPrc, @MpPrc,  
      @McPrc, @ValidPrd, @AbortPrc, @BackPrc, @ResumePrc,  
      @Tranrate, @Creator, @CreateTime, @LstUpdOper, @LstUpdTime,  
      @SndTime, @ID, @vSysUUID  
  end   
  close curNCRMCardType  
  deallocate curNCRMCardType    
  set @poMsg = '接收成功: ' + Cast(@nCorrCount As varchar(10)) + '条'  
  return(0)  
end  

GO
