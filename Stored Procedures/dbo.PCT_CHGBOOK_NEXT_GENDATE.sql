SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_NEXT_GENDATE] (
  @piCntrNum varchar(14),           --合约号
  @piCntrVersion integer,           --合约版本号
  @piCntrLine integer,              --合约行号
  @poGenDate datetime output,       --下次生成日期
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vMessage varchar(255)

  select @poGenDate = NEXTGENDATE
  from CTCNTRDTL where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine;
  
  select @vMessage = convert(varchar, @poGenDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Next_GenDate', @vMessage

  return(0)
end
GO
