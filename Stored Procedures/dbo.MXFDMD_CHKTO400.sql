SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFDMD_CHKTO400]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin

  declare @vRet int,
          @Stat int,
          @XCHGSTORE int,
          @EXP DATETIME,
          @OptAutoSendBill int
  exec OptReadInt 0, 'PS3_AutoSendBill', 0, @OptAutoSendBill output
  select @Stat = STAT, @XCHGSTORE = XCHGSTORE, @EXP = EXPDATE from MXFDMD(nolock) where NUM = @Num
  if @Stat <> 401
  begin
    set @Msg = '不是请求总部批准的单据，不能进行总部批准操作.'
    return(1)
  end

  --检查部门限制
  exec @vRet = MxfDmd_CheckDeptEmp @Num, @Oper, @ToStat, @Msg output
  if @vRet <> 0 return @vRet

  if  (select USERGID from system(nolock)) <> @XCHGSTORE
  begin
    set @Msg = '审批门店不是本店，不能进行总部批准操作.'
    return(2)
  end

  IF (@EXP IS NOT NULL) AND (@EXP <= GETDATE()-1)
  BEGIN
    SET @MSG = '单据' + @NUM + '已经超过到效日期'
    RETURN (3)
  END

  --根据门店经营方案处理商品明细
  exec @vRet = MXFDMD_CHKWITHSCHEME @Num, @Oper, @Msg output
  if @vRet <> 0 RETURN @vRet

  update MXFDMD
  set STAT = @ToStat,  CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num

  exec MXFDMD_ADD_LOG @Num, @ToStat, '总部批准', @Oper;
  --自动发送
  if @OptAutoSendBill = 1
  begin
    exec @vRet = MXFDMD_Snd @Num, @Oper, @Msg output
    if @vRet <> 0 return @vRet
  end
  return 0
end
GO
