SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_CREATE_CHGBOOK] (
  @piStoreGid integer,                --生效门店
  @piCntrNum varchar(14),             --合约号
  @piCntrVersion integer,             --合约版本号
  @piCntrLine integer,                --合约行号
  @piGenType integer,                 --产生方式
  @piGenDate datetime,                --费用产生日期
  @piCalcBegin datetime,              --统计开始日期
  @piCalcEnd datetime,                --统计结束日期
  @piBaseTotal decimal(24, 2),        --统计基数
  @piTotal decimal(24, 2),            --费用金额
  @piCalcRate decimal(24, 2),         --提成比率
  @piSrcNum varchar(20),              --来源单号
  @piOcrDate datetime,                --发生日期
  @piPayDate datetime,                --付款日期
  @piNote varchar(255),               --备注
  @poChgBookNum varchar(14) output,   --生成的费用单单号
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vRet integer
  declare @vBillNum varchar(14)
  declare @vGatheringMode varchar(20)
  declare @vPayDirect integer
  declare @vPayUnit varchar(4)
  declare @vPayUnit2 varchar(4)
  declare @vDept varchar(20)
  declare @vSigner integer
  declare @vOper varchar(50)
  declare @vVdrGid integer
  declare @vChgCode varchar(20)
  declare @vSettleNo integer
  declare @vDate datetime
  declare @vWhenGen varchar(20)
  declare @vSrcCls varchar(20)
  declare @m_ZeroChgBook varchar(10)
  declare @vMessage varchar(255)
  declare @vStoreGid integer
  declare @vSign int
  declare @vStStore int
  declare @CASHCENTER int

  --增加一次性费用项目判断
  declare @vSinglefee smallint --为1标识一次性费用
  declare @vGenedNum varchar(14) --生成的费用单/补差单号
  --补充协议
  declare @vIsAdded smallint --是否补充协议,如果是补充协议那么计算生成补差单
  declare @vGdGid int --补差商品

  if @piTotal < 0
  begin
    set @piTotal = -@piTotal
    set @piBaseTotal = -@piBaseTotal
    set @vSign = -1
  end else
    set @vSign = 1

  exec OPTREADSTR 3004, '生成零金额的费用单', '否', @m_ZeroChgBook output
  if @m_ZeroChgBook = '否'
  begin
    if @piTotal = 0 return(0)
  end

  if @piStoreGid is null
    select @vStoreGid = USERGID from FASYSTEM(nolock)
  else
    set @vStoreGid = @piStoreGid

  select @vDate = convert(varchar, getdate(), 102)
  select
    @vVdrGid = VENDOR,
    @vSigner = SIGNER,
    @vDept = rtrim(DEPT)
  from CTCNTR where NUM = @piCntrNum and VERSION = @piCntrVersion
  select
    @vChgCode = CHGCODE,
    @vGatheringMode = GATHERINGMODE,
    @vPayUnit2 = ISNULL(PAYUNIT, ''),
    --added by zhangzhen 2012-8-20 振华补充协议
    @vSinglefee = SINGLEFEE,
    @vGenedNum = CHGBOOKNUM,
    @vIsAdded = ISADDED,
    @vGdGid = VdrGdGid
  from CTCNTRDTL
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  select
    @vPayDirect = PAYDIRECT, @vWhenGen = WHENGEN, @vPayUnit = PayUnit
  from CTCHGDEF where CODE = @vChgCode

  --如果是一次性费用,那么如果已经生成了费用单,则不再生成
  if (@vSinglefee = 1) and (@vGenedNum is not null)
    return 0
  --如果是补充协议,那么就不生成费用单而是生成补差单
  if @vIsAdded = 1
  begin
    exec @vRet = PCT_CREATE_PRMOFFSET @vStoreGid, @vVdrGid, @vGdGid, @piCntrNum, @piCntrVersion, @piCntrLine,
      @piCalcBegin, @piCalcEnd, @piTotal, @piGenDate, @piPayDate, @vPayDirect, @vBillNum output, @piOperGid,
      @poErrMsg output
    if @vRet <> 0
    begin
      set @poErrMsg = '生成补差单失败:' + @poErrMsg
      return(1)
    end
    --如果是一次性费用,那么回写合约明细的CHGBOOKNUM字段
    if @vSinglefee = 1
    begin
      Update CTCNTRDTL Set
        CHGBOOKNUM = @vBillNum
      where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
    end

    return 0
  end --end of 补充协议

  if @vPayUnit2 <> '' set @vPayUnit = @vPayUnit2
  if @vWhenGen = '发生时间'
    select @vSrcCls = DATASRCCLS from CTCHGDEFRATE where CODE = @vChgCode
  else
    set @vSrcCls = null
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
  from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)

  exec @vRet = GENNEXTBILLNUMEX '', 'CHGBOOK', @vBillNum output
  if @vRet <> 0
  begin
    set @poErrMsg = '获取下一费用单单号失败'
    return(1)
  end
  if @vPayUnit = '总部'
    select @vStStore = zbgid from FASystem(nolock)
  else
    set @vStStore = @vStoreGid
  set @CASHCENTER = null
  select @CASHCENTER = CASHCENTER from CNCASHCENTER(nolock)
  where store = (select usergid from FaSystem(nolock))
    and DEPT = @vDept and VENDOR = @vVdrGid
  insert into CHGBOOK(NUM, STAT, VENDOR, BILLTO, BTYPE,
    CNTRNUM, CNTRVERSION, CHGCODE, CALCBEGIN, CALCEND,
    CALCTOTAL, CALCRATE, SHOULDAMT, REALAMT, PAYTOTAL,
    OCRDATE, PAYDATE, GENDATE, STORE,
    FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO,
    NOTE, FIXNOTE, SRCNUM, SRCCLS, GATHERINGMODE,
    ACCOUNTTERM, PAYDIRECT, DEPT, PSR, PAYUNIT, STSTORE, CASHCENTER)
  values(@vBillNum, 0, @vVdrGid, @vVdrGid, @piGenType,
    @piCntrNum, @piCntrVersion, @vChgCode, @piCalcBegin, @piCalcEnd,
    @piBaseTotal, @piCalcRate, @piTotal, @piTotal, 0,
    @vDate, @piPayDate, @piGenDate, @vStoreGid,
    getdate(), @vOper, null, null, @vSettleNo,
    '由合约 ' + @piCntrNum + ' 生成', substring(isnull(@piNote, ''), 1, 255), @piSrcNum, @vSrcCls, @vGatheringMode,
    '签约前', @vPayDirect * @vSign, @vDept, @vSigner, @vPayUnit, @vStStore, @CASHCENTER)
  set @poChgBookNum = @vBillNum

  exec PCT_CHGBOOK_LOGDEBUG 'Create_ChgBook', @poChgBookNum
  --更新电子发票相关的字段
  exec @vRet = PCT_CHGBOOK_UPDIVCFIELD @vChgCode, @vBillNum
  if @vRet <> 0
  begin
    set @poErrMsg = 'PCT_CHGBOOK_CREATE_CHGBOOK更新费用单电票相关字段失败'
    Return(1)
  end

  --记录到临时表
  insert into TMPGENBILLS(SPID, OWNER, BILLNAME, NUM, DTLCNT, STARTTIME, FINISHTIME, STAT)
  values(@@spid, '生成费用单', '费用单', @poChgBookNum, 0, getdate(), getdate(), 0)

  --如果是一次性费用,那么回写合约明细的CHGBOOKNUM字段
  if @vSinglefee = 1
  begin
    Update CTCNTRDTL Set
      CHGBOOKNUM = @vBillNum
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  end

  return(0)
end
GO
