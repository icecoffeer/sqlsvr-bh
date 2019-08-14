SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_ON_CHANGE]
(
  @piNum	char(14),
  @piOldVersion	int,
  @piNewVersion	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vRet int
  declare @vEndDate datetime
  declare @vGroupNum char(14)
  declare @vGroupEndDate datetime
  declare @vStat int
  declare @vopt int
  declare @piNewVersion2 int

  set @vopt = 1
  if exists (select 1 from hdoption where moduleno = 3004 and optioncaption = '变更后状态是否为已审核' and optionvalue = '否') 
    set @vopt = 0
  
  select @vEndDate = ENDDATE, @vStat = STAT from CTCNTR 
  	where NUM = @piNum and VERSION = @piNewVersion;
  --where MODULENO = 3004 and OPTIONCAPTION = '子合约变更方式';  
  
  if @vopt = 0 
    update CTCNTR set STAT = 834 where NUM = @piNum and VERSION = @piNewVersion
  else
    update CTCNTR set STAT = 500 where NUM = @piNum and VERSION = @piNewVersion
  
  if @vopt = 0   
    set @piNewVersion2 = @piNewVersion + 1
  else 
    set @piNewVersion2 = @piNewVersion
    
  exec @vRet = PCT_CNTR_INTERNAL_MODIFY @piNum, @piNewVersion2, @piOperGid, @poErrMsg output
  if (@vRet <> 0) return(@vRet)
  
  if @vopt = 0  
    update CTCNTR set TAG = 2
    where NUM = @piNum and VERSION = @piNewVersion
  
  exec PCT_CNTR_ADDLOG @piNum, @piOldVersion, @piOperGid, @vStat, @vStat, '变更为无效'
  exec PCT_CNTR_ADDLOG @piNum, @piNewVersion, @piOperGid, @vStat, @vStat, '变更产生'
  
  if @vopt = 1   
  begin
    exec @vRet = PCT_CNTR_SEND @piNum, @piNewVersion, @piOperGid, @poErrMsg output
    if @vRet > 0 return(@vRet)
  end
  
  return(0);  
end
GO
