SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_ON_MODIFY] (
  @Num varchar(14),                  --单号
  @Oper varchar(40),                 --操作人
  @ToStat int,                       --目标状态
  @Msg varchar(255) output           --出错信息
) as
begin
  declare
    @vRet int,
    @vStat int/*,
    @vOper varchar(80)*/

  select @vStat = STAT from CRMMBRPROMTYPEBILL(nolock) where NUM = @Num
  if @vStat is null
  begin
    set @Msg = '取会员促销类型登记单状态失败.'
    return(1)
  end

  if @ToStat = 0
  begin
    if @vStat <> 0
    begin
      set @Msg = '单据已经被其他人处理，不能保存'
      return(1)
    end
  end else if @ToStat = 100
  begin
    if @vStat <> 0
    begin
      set @Msg = '单据已经被其他人处理，不能保存'
      return(1)
    end
  end else if @ToStat = 110
  begin
    if @vStat <> 100
    begin
      set @Msg = '单据不是已审核状态，不能作废'
      return(1)
    end
  end else
  begin
    set @Msg = '不能识别的目标状态: ' + rtrim(convert(varchar, @ToStat))
    return(1)
  end

  --状态调度
  if (@vStat = 0) and (@ToStat = 100)
  begin
    exec @vRet = PCRM_MBRPROMTYPE_STAT_TO_100 @Num, @Oper, @Msg output
    return(@vRet)
  end else if (@vStat = 100) and (@ToStat = 110)
  begin
    exec @vRet = PCRM_MBRPROMTYPE_STAT_TO_110 @Num, @Oper, @Msg output
    return(@vRet)
  end

  --select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @OperGid
  update CRMMBRPROMTYPEBILL set MODIFIER = @Oper, LSTUPDTIME = getdate() where NUM = @Num
  exec PCRM_MBRPROMTYPE_ADD_LOG @Num, @vStat, @ToStat, @Oper

  return(0)
end
GO
