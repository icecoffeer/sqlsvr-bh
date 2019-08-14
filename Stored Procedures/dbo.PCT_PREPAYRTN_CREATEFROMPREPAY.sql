SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PCT_PREPAYRTN_CREATEFROMPREPAY](
    @Num Varchar(14),	--预付款单单号
    @Oper int,		--操作人
    @MSG VARCHAR(255) OUTPUT	--出错信息
  ) 
as
begin
  declare @GenNUM Varchar(14)
  declare @vRet integer

  EXEC GENNEXTBILLNUMEX NULL, 'CTPREPAYRTN', @GenNUM OUTPUT
  insert into CTPREPAYRTN(NUM, VENDOR, STAT, FILLER, FILDATE, CHECKER, CHKDATE, OCRDATE, DEPT, PSR, TOTAL, PREPAYNUM, NOTE)
  select @GenNUM, VENDOR, 0, @Oper, getdate(), @Oper, getdate(), CONVERT(datetime, floor(CONVERT(money, GETDATE()))),
  DEPT, PSR, TOTAL - TOTALOFF, num, null
  from CNTRPREPAY where num = @Num

  exec @vRet = PCT_PREPAYRTN_ON_MODIFY @GenNUM, 900, @Oper, @Msg output
  if @vRet <> 0 return(@vRet)

  return(0);
end
GO
