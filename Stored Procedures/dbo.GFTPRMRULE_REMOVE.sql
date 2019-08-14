SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMRULE_REMOVE]
(
  @piCode	char(18),
  @piOper	char(30),
  @poErrMsg	varchar(255)	output
)
as
begin  
  declare @vStat int
  select @vStat = STAT from GFTPRMRULE where CODE = @piCode
  if @@rowcount = 0 return 0
  if @vStat <> 0
  begin
    set @poErrMsg = '促销规则' + @piCode + '是生效的规则，不能删除'
    return(1)
  end
  delete from GFTPRMRULE where CODE = @piCode;
  delete from GFTPRMRULELMT where RCODE = @piCode;
  delete from GFTPRMRULELMTDTL where RCODE = @piCode;
  delete from GFTPRMGOODS where RCODE = @piCode;
  delete from GFTPRMGIFT where RCODE = @piCode;
  delete from GFTPRMGIFTDTL where RCODE = @piCode;
  return(0)
end
GO
