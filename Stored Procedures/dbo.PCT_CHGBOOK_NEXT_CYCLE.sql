SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_NEXT_CYCLE] (
  @piCntrNum varchar(14),           --合约号
  @piCntrVersion integer,           --合约版本号
  @piCntrLine integer,              --合约行号
  @poBeginDate datetime output,     --下次开始日期
  @poEndDate datetime output,       --下次结束日期
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vChgCls varchar(20)
  declare @vMessage varchar(255)

  select @vChgCls = f.CHGCLS
  from CTCHGDEF f, CTCNTRDTL d
  where d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine and d.CHGCODE = f.CODE

  if @vChgCls = '固定'
    select 
      @poBeginDate = NEXTBEGINDATE, 
      @poEndDate = NEXTENDDATE
    from CTCNTRFIXDTL
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  else
    select
      @poBeginDate = NEXTBEGINDATE, 
      @poEndDate = NEXTENDDATE
    from CTCNTRRATEDTL
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

  select @vMessage = convert(varchar(10), @poBeginDate, 102) + ' - ' + convert(varchar(10), @poEndDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Next_Cycle', @vMessage

  return(0)
end
GO
