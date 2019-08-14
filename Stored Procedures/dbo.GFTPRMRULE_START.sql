SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMRULE_START]
(
  @piCode	char(18),
  @piOper	char(30),
  @poErrMsg	varchar(255)	output
)
as
begin  
  declare @vStat int 
  declare @vEndTime datetime, @vBeginTime datetime
  select @vStat = STAT, @vBeginTime = BEGINTIME, @vEndTime = ENDTIME from GFTPRMRULE where CODE = @piCode
  if @vStat = 1
  begin
    set @poErrMsg = '促销规则' + @piCode + '已经生效'
    return(1)
  end
 /* if (@vBeginTime < GetDate()) or (@vEndTime < GetDate()) 
  begin
    set @poErrMsg = '促销规则' + @piCode + '不能生效，因为开始结束时间非法'
    raiserror('不能生效，因为规则的开始结束时间非法', 16, 1);
    return(-1)
  end*/
  update GFTPRMRULE set STAT = 1 where CODE = @piCode   --, BEGINTIME = getdate()
  exec gftprmrule_addlog @piCode, '审核', @piOper
  return(0)
end
GO
