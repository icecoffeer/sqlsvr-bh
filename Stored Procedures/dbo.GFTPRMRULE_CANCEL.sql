SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMRULE_CANCEL]
(
  @piCode	char(18),
  @piOper	char(30),
  @poErrMsg	varchar(255)	output
)
as
begin  
  declare @vStat int
  declare @vEndTime datetime
  select @vStat = STAT, @vEndTime = ENDTIME from GFTPRMRULE where CODE = @piCode
  if @vStat = 1
  begin
      update GFTPRMRULE set STAT = 0 where CODE = @piCode
      if @vEndTime > getdate() 
        update GFTPRMRULE set ENDTIME = getdate() where CODE = @piCode
  end else
  begin
    set @poErrMsg = '促销规则' + @piCode + '已经无效，无法作废'
    return(1)
  end
  exec gftprmrule_addlog @piCode, '作废', @piOper
  return(0)
end
GO
