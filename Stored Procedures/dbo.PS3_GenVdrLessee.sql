SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PS3_GenVdrLessee] (
  @piCntrNum varchar(14), --合约号
  @piCntrVersion integer, --合约版本号
  @piCntrChgCode Char(10), --合约项目代码
  @piVdrGid Int,       --供应商
  @piOper Int,         --操作员
  @piNewRate Int,      --新联销率
  @poErrMsg Varchar(255) OutPut  --错误信息
) As
BEGIN
  declare
    @vRet integer,
    @newLesNum varchar(14),
    @vOper VarChar(30),
    --对方签约人取合约的字段
    @vVdrSigner Char(30)

  --首先判断是否维护了对应的生成联销协议的配置,如没有则直接跳出
  If Not Exists(Select 1 From CNTR_GENVDRLESSEE
    Where CNTRNUM = @piCntrNum And VERSION = @piCntrVersion
      And ChgCode = @piCntrChgCode And VDRGID = @piVdrGid)
    Return 0

  Select @vOper = RTrim(NAME) + '[' + RTrim(Code) + ']'
    From Employee Where Gid = @piOper
  Select @vVdrSigner = VDRSIGNER From CtCntr
  Where NUM = @piCntrNum And VERSION = @piCntrVersion

  Exec GENNEXTBILLNUMEX '', 'VDRLESSEE', @newLesNum output
  insert into VDRLESSEE(NUM, VDRGID, BUYER, FILDATE, FILLER, STAT,
    ORGVISER, PAYRATE)
  Select @newLesNum, VDRGID, @vOper, Getdate(), @piOper, 0,
    @vVdrSigner, ORIPAYRATE
  From CNTR_GENVDRLESSEE
  Where CNTRNUM = @piCntrNum And VERSION = @piCntrVersion
    And ChgCode = @piCntrChgCode And VDRGID = @piVdrGid
  if @@ERROR <> 0
  begin
    set @poErrMsg = '生成供应商联销贸易协议过程出错.'
    RETURN 1
  end

  --生成 供应商联销协议类别明细
  Insert Into VDRLESSORTD(NUM, SORT, PAYRATE)
  Select @newLesNum, DEPT, PAYRATE
    From CNTR_GENVDRLSEDEPT
  Where CNTRNUM = @piCntrNum And VERSION = @piCntrVersion
    And ChgCode = @piCntrChgCode And VDRGID = @piVdrGid
  --生成 供应商联销协议类别品牌明细
  insert into VDRLESSORTBRAND(NUM, SORT, BRAND, PAYRATE, SORTCODE)
  Select @newLesNum, DEPT, BRAND, PAYRATE, SORTCODE
    From CNTR_GENVDRLSEDEPTBRAND
  Where CNTRNUM = @piCntrNum And VERSION = @piCntrVersion
    And ChgCode = @piCntrChgCode And VDRGID = @piVdrGid

  --审核生效
  exec @vRet = VdrLeChk @newLesNum, @vOper, 100, @poErrMsg OutPut
  if @vRet <> 0 return @vRet

  return(0)
END
GO
