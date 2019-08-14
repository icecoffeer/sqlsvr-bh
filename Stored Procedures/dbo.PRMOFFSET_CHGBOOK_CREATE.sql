SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSET_CHGBOOK_CREATE] (
  @piNum varchar(14),                 --补差单号
  @piStoreGid int,                    --门店GID
  @poChgBookNum varchar(14) output,   --生成的费用单单号
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare
    @vRet integer,
    @vBillNum varchar(14),
    @vDept varchar(20),
    @vOper varchar(50),
    @vSettleNo integer,
    @vDate datetime,
    @m_ZeroChgBook varchar(10),
    @vStoreGid integer,
    @vStStore int,
    @VdrGid int,
    @CHGCODE varchar(10),
    @Total decimal(24, 2),
    @igatheringmode int, @ipsr int,
    @sgatheringmode varchar(10),
    @settledeptcode varchar(10),--zhujie 2009.8.6
    @PayDirect smallInt;  --收付方向 1=收款 -1=付款
  exec OPTREADSTR 3004, '生成零金额的费用单', '否', @m_ZeroChgBook output
  select @settledeptcode = ''
  select @settledeptcode = settledeptcode from PrmOffset where num = @piNum;--zhujie
  if @settledeptcode = ''
    select @settledeptcode = null
  select @Total = IsNull(Sum(RAmt), 0) from PrmOffsetDtlDtl where Num = @piNum and STOREGID = @piStoreGid;

  if @m_ZeroChgBook = '否'
  begin
    if @Total = 0 return(0)
  end

  if @Total < 0
    set @Total = -@Total

  select @vDate = convert(varchar, getdate(), 102)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
  from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  exec @vRet = GENNEXTBILLNUMEX '', 'CHGBOOK', @vBillNum output
  if @vRet <> 0
  begin
    set @poErrMsg = '获取下一费用单单号失败'
    return(1)
  end

  select @CHGCODE = OPTIONVALUE from HDOPTION where MODULENO = 727 and OPTIONCAPTION = 'ChgDef'
  if ((@@rowcount = 0) or (@CHGCODE = ''))
  begin
    set @poErrMsg = '促销补差模块没有定义项目代码'
    return(1)
  end

  select
    @vStStore = BillTo,
    @VdrGid = VdrGid,
    @igatheringmode = GATHERINGMODE,
    @ipsr = PSR,
    @PayDirect = PAYDIRECT  --收付方向
  from PrmOffset(nolock)
  where Num = @piNum
/*  if exists (select 1 from FASystem(nolock) where zbgid = @vStStore)
    set @vPayUnit = '总部'
  else
    set @vPayUnit = '门店'*/
  if @piStoreGid is null
    select @vStoreGid = USERGID from FASYSTEM(nolock)
  else
    set @vStoreGid = @piStoreGid
  if @igatheringmode = 0
    set @sgatheringmode = '立即交款'
  else
    set @sgatheringmode = '冲扣货款'

  insert into CHGBOOK(NUM, STAT, VENDOR, BILLTO, BTYPE, CNTRNUM, CNTRVERSION, CHGCODE, CALCBEGIN, CALCEND,
    CALCTOTAL, CALCRATE, SHOULDAMT, REALAMT, PAYTOTAL, OCRDATE, PAYDATE, GENDATE, STORE,
    FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO,  NOTE, FIXNOTE,
    SRCNUM, SRCCLS, GATHERINGMODE, ACCOUNTTERM, PAYDIRECT, DEPT, PSR, PAYUNIT, STSTORE, CASHCENTER)
  values(@vBillNum, 0, @VdrGid, @VdrGid, 3, '', null, @CHGCODE, null, null,
    0, null, @Total, @Total, 0, @vDate, null, getDate(), @vStoreGid,
    getdate(), @vOper, null, null, @vSettleNo, '由促销补差单 ' + @piNum + ' 生成', '',
    @piNum, '促销补差单', @sgatheringmode, '签约前', @PayDirect, @settledeptcode, @ipsr, '总部', null, null)
  set @poChgBookNum = @vBillNum

  exec PCT_CHGBOOK_LOGDEBUG 'Create_ChgBook', @poChgBookNum

  --记录到临时表
  insert into TMPGENBILLS(SPID, OWNER, BILLNAME, NUM, DTLCNT, STARTTIME, FINISHTIME, STAT)
  values(@@spid, '生成费用单', '费用单', @poChgBookNum, 0, getdate(), getdate(), 0)

  return(0)
end
GO
