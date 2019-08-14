SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMRULE_STOP]
(
  @piCode	char(18),
  @piOper	char(30),
  @poErrMsg	varchar(255)	output
)
as
begin  
  declare @vStat int
  declare @vEndTime datetime, @vBeginTime datetime
  select @vStat = STAT, @vEndTime = ENDTIME, @vBeginTime = BEGINTIME from GFTPRMRULE where CODE = @piCode
  if @vStat = 1
  begin
  	if @vBeginTime > getDate()
  	  update GFTPRMRULE set ENDTIME = BEGINTIME where CODE = @piCode
    else if @vEndTime > getdate()
      update GFTPRMRULE set ENDTIME = getdate() where CODE = @piCode
    else begin
      set @poErrMsg = '促销规则' + @piCode + '已经过期，无法终止'
      return(1)
    end
  end else
  begin
    set @poErrMsg = '促销规则' + @piCode + '已经无效，无法终止'
    return(1)
  end
  update GFTPRMRULE set ENDTIME = getdate() where CODE = @piCode;
  exec gftprmrule_addlog @piCode, '终止', @piOper
  return(0)
end
GO
