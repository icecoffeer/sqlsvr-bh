SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFDMD_CHKTO402]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare @vRet int,
          @Stat int,
          @UserGid int,
          @XchgStore int,
          @OptAutoSendBill int
  exec OptReadInt 0, 'PS3_AutoSendBill', 0, @OptAutoSendBill output
  select @Stat = STAT from MXFDMD(nolock) where NUM = @Num
  if @Stat <> 401
  begin
    set @Msg = '不是请求总部批准的单据，不能拒绝。'
    return(1)
  end
  
  --检查部门限制
  exec @vRet = MxfDmd_CheckDeptEmp @Num, @Oper, @ToStat, @Msg output
  if @vRet <> 0 return @vRet
  
  select @UserGid = USERGID from SYSTEM(nolock)
  select @XchgStore = XCHGSTORE from MXFDMD(nolock)
    where NUM = @Num
  if @XchgStore <> @UserGid
  begin
    set @Msg = '本单位不是审批单位，不能拒绝。'
    return(1)
  end

  update MXFDMD
  set STAT = @ToStat, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num

  exec MXFDMD_ADD_LOG @Num, @ToStat, '总部拒绝', @Oper;
  --自动发送
  if @OptAutoSendBill = 1
  begin
    exec @vRet = MXFDMD_Snd @Num, @Oper, @Msg output
    if @vRet <> 0 return @vRet
  end
  return 0
end
GO
