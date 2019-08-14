SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_UNDO_DEDUCT] (
  @piNum varchar(14),               --费用单单号
  @piPayTotal decimal(24, 2),       --扣除金额
  @piOperGid integer,               --操作人
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vStat integer
  declare @vTotal decimal(24, 2)
  declare @vPayTotal decimal(24, 2)
  declare @vPayDirect integer
  declare @vOper varchar(50)
  --zz 090425
  declare @AllowLocalAcnt int
  declare @Clecent int
  declare @Usergid int

  --zz 090424
  EXEC OPTREADINT 3304, 'CNTR_AllowLocalAcnt', 0, @AllowLocalAcnt OUTPUT
  select @Usergid = usergid from system

  select
    @vStat = STAT,
    @vTotal = REALAMT,
    @vPayDirect = PAYDIRECT,
    @vPayTotal = PAYTOTAL,
    @Clecent = isnull(CASHCENTER, @Usergid)--zz 090424
  from CHGBOOK where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到费用单 ' + @piNum
    return(1)
  end
  if @vStat not in (500, 300)
  begin
    set @poErrMsg = '费用单 ' + @piNum + ' 不是已审核或已完成状态'
    return(1)
  end
  --added by zhangzhen 090424
  if @AllowLocalAcnt = 1 and @Clecent <> @Usergid
  begin
    set @poErrMsg = '费用单有所属结算中心,不能在本店交款'
    return(1)
  end
  --added end

  if @piPayTotal < 0
    set @vPayTotal = @vPayTotal + @piPayTotal
  else
    set @vPayTotal = @vPayTotal - @piPayTotal
  if @vPayTotal < 0
  begin
    set @poErrMsg = '费用单 ' + @piNum + ' 的已付金额不足'
    return(1)
  end

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid

  if @vPayTotal >= @vTotal
  begin
    update CHGBOOK set
      LSTUPDTIME = getdate(),
      PAYTOTAL = @vPayTotal,
      SIGNDATE = getdate(),
      SIGNER = @vOper,
      STAT = 300
    where NUM = @piNum
  end else
  begin
    update CHGBOOK set
      LSTUPDTIME = getdate(),
      PAYTOTAL = @vPayTotal,
      SIGNDATE = getdate(),
      SIGNER = @vOper,
      STAT = 500
    where NUM = @piNum
  end

  return(0)
end
GO
