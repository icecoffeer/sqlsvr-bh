SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PGFBOOK_DEDUCT] (
  @piNum varchar(14),               --抵扣货款单单号
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

  select
    @vStat = STAT,
    @vTotal = REALAMT,
    @vPayDirect = PAYDIRECT,
    @vPayTotal = PAYTOTAL
  from PGFBOOK where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到抵扣货款单 ' + @piNum
    return(1)
  end
  if @vStat <> 500
  begin
    set @poErrMsg = '抵扣货款单 ' + @piNum + ' 不是已审核状态'
    return(1)
  end

  --if @piPayTotal < 0
    --set @vPayTotal = @vPayTotal - @piPayTotal
  --else
    set @vPayTotal = @vPayTotal + @piPayTotal

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid

  if @vPayTotal >= @vTotal
  begin
    update PGFBOOK set
      LSTUPDTIME = getdate(),
      PAYTOTAL = @vPayTotal,
      SIGNDATE = getdate(),
      SIGNER = @vOper,
      STAT = 300
    where NUM = @piNum
  end else
  begin
    update PGFBOOK set
      LSTUPDTIME = getdate(),
      PAYTOTAL = @vPayTotal,
      SIGNDATE = getdate(),
      SIGNER = @vOper
    where NUM = @piNum
  end

  return(0)
end
GO
