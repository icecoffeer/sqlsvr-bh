SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CREATE_PRMOFFSET] (
  @piStoreGid integer,                --生效门店
  @piVdrGid integer,                  --供应商
  @piGdGid integer,                   --商品
  @piCntrNum varchar(14),             --合约号
  @piCntrVersion integer,             --合约版本号
  @piCntrLine integer,                --合约行号
  @piCalcBegin datetime,              --统计开始日期
  @piCalcEnd datetime,                --统计结束日期
  @piTotal decimal(24, 2),            --实际费用金额
  @piOcrDate datetime,                --发生日期
  @piPayDate datetime,                --付款日期
  @piPayDirect integer,               --收付方向(1 = 收 -1 = 付)
  @poPrmOffSetNum varchar(14) output, --生成的补差单单号
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare
    @opt_PrmOffsetStat int,
    @opt_OffSetType SMALLINT,
    @opt_GatheringMode SMALLINT,
    @opt_SettleDept VARCHAR(10),
    @opt_PsrCode VARCHAR(20),
    @vPsrGid int,
    @vSettleno int,
    @vOper VARCHAR(30), --操作人姓名代码
    @vRet SMALLINT,
    @vSrc Int,
    @vDtlLine int, --明细行号
    @vItemLine int --明细明细行号

  EXEC OPTREADINT 727, 'OFFSETTYPE', 0, @opt_OffSetType OUTPUT
  EXEC OPTREADINT 727, 'GATHERINGMODE', 0, @opt_GatheringMode OUTPUT
  EXEC OPTREADSTR 727, 'SETTLEDEPTCODE', '', @opt_SettleDept OUTPUT
  --默认采购员
  EXEC OPTREADSTR 727, 'PSRCODE', '-', @opt_PsrCode OUTPUT
  SELECT @vPsrGid = GID FROM EMPLOYEE(NOLOCK) WHERE CODE = @opt_PsrCode

  SELECT @vSettleno = MAX(NO) FROM MONTHSETTLE(NOLOCK)
  SELECT @vOper = RTRIM(NAME) + '[' + RTRIM(CODE) + ']' FROM EMPLOYEE(NOLOCK)
    WHERE GID = @piOperGid
  IF @vOper IS NULL SET @vOper = '未知[-]'
  SELECT @vSrc = USERGID FROM SYSTEM(NOLOCK)

  if @piGdGid is null
  begin
    Set @poErrMsg = '补差商品不能为空'
    return 1
  end

  --生成促销补差单
  EXEC GENNEXTBILLNUMEX '', 'PRMOFFSET', @poPrmOffSetNum OUTPUT
  --抢占单号
  INSERT INTO PRMOFFSET(NUM, VDRGID, SETTLENO, FILDATE, FILLER, RECCNT, STAT,
    EON, LSTUPDTIME, OFFSETTYPE, OFFSETCALCTYPE, TOTAL, AMOUNT, TAX, BILLTO,
    GATHERINGMODE, SRC, SETTLEDEPTCODE, PSR, PAYDIRECT, BTYPE, NOTE)
  VALUES(@poPrmOffSetNum, @piVdrGid, @vSettleno, GETDATE(), @piOperGid, 0, 0,
    1, GETDATE(), @opt_OffSetType, 1/*差价模式*/, 0, 0, 0, @piVdrGid,
    @opt_GatheringMode, @vSrc, @opt_SettleDept, @vPsrGid, @piPayDirect, 1, '由日结程序合约自动生成')

  --固化明细
  select @vDtlLine = Isnull(Max(Line), 0) from PRMOFFSETDTL
    Where Num = @poPrmOffSetNum
  Set @vDtlLine = @vDtlLine + 1
  INSERT INTO PRMOFFSETDTL(NUM, LINE, SETTLENO, GDGID, AGMNUM, AGMLINE,
    SAMT, RAMT, START, FINISH, AGMTABLENAME)
  VALUES(@poPrmOffSetNum, @vDtlLine, @vSettleno, @piGdGid, @piCntrNum, @piCntrLine,
    @piTotal, @piTotal, @piCalcBegin, @piCalcEnd, 'CTCNTR')

  --固化明细明细
  select @vItemLine = Isnull(Max(Item), 0) from PRMOFFSETDTLDTL
    Where Num = @poPrmOffSetNum and Line = @vDtlLine
  Set @vItemLine = @vItemLine + 1
  INSERT INTO PRMOFFSETDTLDTL(NUM, LINE, ITEM, GDGID, STOREGID, AGMNUM,
    AGMLINE, SAMT, RAMT, AGMTABLENAME)
  SELECT @poPrmOffSetNum, @vDtlLine, @vItemLine, @piGdGid, @piStoreGid, @piCntrNum,
    @piCntrLine, @piTotal, @piTotal, 'CTCNTR'

  --修改汇总的一些字段的值
  declare @vReccnt int
  SELECT @vReccnt = COUNT(NUM)
    FROM PRMOFFSETDTL(NOLOCK)
  WHERE NUM = @poPrmOffSetNum

  UPDATE PRMOFFSET
    SET RECCNT = @VRECCNT
  WHERE NUM = @poPrmOffSetNum

  --借用促销补差协议中的选项控制是否审核促销补差单
  EXEC OPTREADINT 8102, 'PRMOFFSETSTAT', 0, @OPT_PRMOFFSETSTAT OUTPUT
  IF @OPT_PRMOFFSETSTAT = 100
  BEGIN
    EXEC @VRET = PRMOFFSETCHK @poPrmOffSetNum, '', 100, @VOPER, @poErrMsg OUTPUT
    IF @VRET <> 0 RETURN @VRET
  END

  RETURN(0)
end
GO
