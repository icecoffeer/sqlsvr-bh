SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PPS_CRMADDIN_CARDTYPE_SENDNCRMCARDTYPE]
(
  @piCode varchar(10),    
  @piRcv int,    
  @poMsg varchar output      
)
--with encryption
as    
begin
  declare  
    @nID int,
    @nSrc int,
    @vZBGid int,
    @vSysUUID varchar(20)
    
  
  ---非总部不能发送卡类型
  ---控制非总部不能发送卡类型
  select @vZBGid = ZBGid  from FASystem(nolock) where ZBGid = UserGid   
  if @@ROWCOUNT = 0
  begin
    set @poMsg = '非总部不能发卡类型'
    return(1)
  end  
  
  --读取SysUUID系统选项
--  select @vSysUUID = OptionValue from HDOption(nolock) where OptionCaption = 'CRM_SYSUUID' and ModuleNo = 0  
--  if @@ROWCOUNT = 0
--  begin
--    set @poMsg = '请配置系统选项 CRM_SYSUUID'
--    return(1)
--  end 

  select @nSrc = UserGid from FASystem(nolock)   
  
  delete from NCRMCardType where Code = @piCode and Rcv = @piRcv
  
  EXEC @nID = SEQNEXTVALUE 'NCRMCARDTYPE'
  
  insert into NCRMCardType(Src, ID, Rcv, FrcChk, Ntype, NStat, 
    Code, Name, CardType, DisCount, ParValue, 
    CardCost, CardUsage, Medium, MsPrc, MpPrc, 
    McPrc, ValidPrd, AbortPrc, BackPrc, ResumePrc,
    TranRate, Creator, CreateTime, LstUpdOper, LstUpdTime, SysUUID)
  select @nSrc, @nID, @piRcv, 1, 0, 0,
    Code, Name, CardType, DisCount, ParValue, 
    CardCost, CardUsage, Medium, MsPrc, MpPrc, 
    McPrc, ValidPrd, AbortPrc, BackPrc, ResumePrc,
    TranRate, Creator, CreateTime, LstUpdOper, LstUpdTime, SysUUID
  from CRMCardType (nolock)
  where Code = @piCode
  return 0     
end
GO
