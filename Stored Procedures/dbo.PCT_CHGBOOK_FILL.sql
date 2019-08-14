SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_FILL] (
  @piVdrGid integer,                --供应商GID
  @piCntrNum varchar(14),           --合约号
  @piChgCode varchar(20),           --帐款项目
  @piBeginDate datetime,            --统计开始日期
  @piEndDate datetime,              --统计结束日期
  @piTotal decimal(24, 2),          --费用金额
  @piOcrDate datetime,              --发生日期
  @piPayDate datetime,              --拟付款日期
  @piGatheringMode varchar(20),     --收款方式
  @piPayDirect integer,             --收付方向
  @piDept varchar(20),              --费用结算组
  @piPsr integer,                   --采购员
  @piNote varchar(255),             --备注
  @piSrcCls varchar(20),            --来源单据类型
  @piSrcNum varchar(20),            --来源单号
  @piOperGid integer,               --操作人
  @poChgBookNum varchar(14) output, --生成的费用单单号
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vTemp integer
  declare @vRet integer
  declare @vCntrVersion integer
  declare @vOper varchar(50)
  declare @vSysDate datetime
  declare @vSettleNo integer
  declare @vGatheringMode varchar(20)
  declare @vSign int
  declare @CASHCENTER int
  declare @store int    --外部导入生成费用要写入生效门店

  if exists(select 1 from HDOPTION where MODULENO = 3110 and OPTIONCAPTION = 'AllowBelowZero' and OPTIONVALUE = '是')
    set @vSign = 1
  else begin
    if @piTotal < 0
    begin
      set @piTotal = -@piTotal
      set @vSign = -1
    end else
      set @vSign = 1
  end

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
  from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @store=usergid from system(nolock)
  set @vSysDate = convert(varchar, getdate(), 102)

  --合法性检查
  if (@piCntrNum is not null) and (Rtrim(@piCntrNum) <> '') --有@piCntrNum=''的情况
  begin
    select @vCntrVersion = VERSION from CTCNTR where VENDOR = @piVdrGid and NUM = @piCntrNum and TAG = 1
    if @@rowcount = 0
    begin
      set @poErrMsg = '合约 ' + @piCntrNum + ' 不存在'
      return(1)
    end
    select @vGatheringMode = GATHERINGMODE from CTCNTRDTL where NUM = @piCntrNum and VERSION = @vCntrVersion and CHGCODE = @piChgCode
    if @@rowcount = 0
    begin
      set @poErrMsg = '帐款项目 ' + @piChgCode + ' 不是合约 ' + @piCntrNum + ' 的项目'
      return(1)
    end
  end else
  begin
    set @vCntrVersion = null
    set @vGatheringMode = @piGatheringMode
  end

  set @CASHCENTER = null
  select @CASHCENTER = CASHCENTER from CNCASHCENTER(nolock)
  where store = (select usergid from FaSystem(nolock))
    and DEPT = @piDept and VENDOR = @piVdrGid

  exec @vRet = GENNEXTBILLNUMEX '', 'CHGBOOK', @poChgBookNum output
  insert into CHGBOOK(NUM, STAT, VENDOR, BILLTO, BTYPE,
    CNTRNUM, CNTRVERSION, CHGCODE, CALCBEGIN, CALCEND,
    CALCTOTAL, CALCRATE, SHOULDAMT, REALAMT, PAYTOTAL,
    OCRDATE, SIGNDATE, SIGNER, PAYDATE,
    FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO,
    NOTE, FIXNOTE, SRCNUM, SRCCLS, GATHERINGMODE,
    ACCOUNTTERM, PAYDIRECT, DEPT, PSR, GENDATE, CASHCENTER,STORE)
  values(@poChgBookNum, 0, @piVdrGid, @piVdrGid, 0,
    @piCntrNum, @vCntrVersion, @piChgCode, @piBeginDate, @piEndDate,
    @piTotal, 100, @piTotal, @piTotal, 0,
    @piOcrDate, null, null, @piPayDate,
    @vSysDate, @vOper, null, null, @vSettleNo,
    @piNote, @piNote, @piSrcNum, @piSrcCls, @vGatheringMode,
    '签约前', @piPayDirect * @vSign, @piDept, @piPsr, @vSysDate, @CASHCENTER,@store);

  --更新电子发票相关的字段
  exec @vRet = PCT_CHGBOOK_UPDIVCFIELD @piChgCode, @poChgBookNum
  if @vRet <> 0
  begin
    set @poErrMsg = 'PCT_CHGBOOK_FILL更新费用单电票相关字段失败'
    Return(1)
  end

  return(0)
end
GO
