SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_IMPORT_TO_POOL] (
  @piCntrNum varchar(14),
  @piVdrCode varchar(15),
  @piChgCode varchar(20),
  @piBeginDate datetime,
  @piEndDate datetime,
  @piOcrDate datetime,
  @piPayDate datetime,
  @piAmt decimal(24, 2),
  @piGatheringMode varchar(20),
  @piSrcCls varchar(20),
  @piSrcNum varchar(20),
  @piPsr varchar(20),
  @piDept varchar(20),
  @piNote varchar(255),
  @poErrMsg varchar(255) output
) as
begin
  declare @vVdrGid integer
  declare @vVdrName varchar(100)
  declare @vCntrVersion integer

  --合法性检查
  select @vVdrGid = GID, @vVdrName = NAME from VENDOR(nolock) where CODE = @piVdrCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '未找到供应商' + @piVdrCode
    return(1)
  end
  if @piCntrNum is not null
  begin
    select @vCntrVersion = VERSION from CTCNTR where NUM = @piCntrNum and TAG = 1
    if @@rowcount = 0
    begin
      set @poErrMsg = '未找到合约' + @piCntrNum
      return(1)
    end
  end
  if not exists(select 1 from CTCHGDEF where CODE = @piChgCode)
  begin
    set @poErrMsg = '未找到帐款项目' + @piChgCode
    return(1)
  end
  if @piGatheringMode not in ('立即缴款', '冲扣货款')
  begin
    set @poErrMsg = '收款方式不正确: ' + @piGatheringMode
    return(1)
  end
  if @piAmt < 0
  begin
    set @poErrMsg = '金额不能小于0'
    return(1)
  end

  insert into TMPCHGBOOK(SPID, VDRGID, VDRCODE, VDRNAME, BILLTO, BILCODE, BILNAME, OCRDATE, PAYDATE,
    CHGCODE, CALCBEGIN, CALCEND, SHOULDAMT, REALAMT, CALCTOTAL, CALCRATE, PAYDIRECT, GATHERINGMODE,
    NUM, SRCCLS, SRCNUM, PSR, DEPT, NOTE, CNTRNUM, CNTRVERSION)
  values(@@SPID, @vVdrGid, @piVdrCode, @vVdrName, @vVdrGid, @piVdrCode, @vVdrName, @piOcrDate, @piPayDate,
    @piChgCode, @piBeginDate, @piEndDate, @piAmt, @piAmt, @piAmt, 100, 1, @piGatheringMode,
    '-', @piSrcCls, @piSrcNum, @piPsr, @piDept, @piNote, @piCntrNum, @vCntrVersion)

  return(0)
end
GO
