SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_CALC_GUARDTOTAL] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piBeginDate datetime,
  @piEndDate datetime,
  @poGuardTotal decimal(24, 2) output,
  @poErrMsg varchar(255) output
) as
begin
  declare @vGuardMode int
  declare @vFixCost decimal(24, 2)
  declare @vRateTotal decimal(24, 2)
  declare @vChgCode varchar(10)
  declare @vOtherCntrNum varchar(14)
  declare @vOtherChgCode varchar(10)

  declare c cursor for
    select OTHERCNTRNUM, OTHERCHGCODE from CTCNTRRATEGUARDCHG 
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine order by ITEMNO
  select @vChgCode = CHGCODE from CTCNTRDTL
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  select @vGuardMode = GUARDMODE from CTCHGDEFRATE where CODE = @vChgCode
  select @vFixCost = FIXCOST from CTCNTRRATEDTL 
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  if @vGuardMode = 0
  begin
    deallocate c
    set @poGuardTotal = @vFixCost
  end
  else if @vGuardMode = 1
  begin
    set @poGuardTotal = 0
    open c
    fetch next from c into @vOtherCntrNum, @vOtherChgCode
    while @@fetch_status = 0
    begin
      select @vRateTotal = isnull(sum(RATETOTAL), 0) from CTCNTRRATERPT
      where NUM = @vOtherCntrNum and CHGCODE = @vOtherChgCode and GENDATE > @piBeginDate and GENDATE <= @piEndDate + 1
      set @poGuardTotal = @poGuardTotal + @vRateTotal
      fetch next from c into @vOtherCntrNum, @vOtherChgCode
    end
    close c
    deallocate c
  end else
  begin
    deallocate c
    set @poErrMsg = '不能识别的保底方式: ' + convert(varchar, @vGuardMode)
    return(1)
  end

  return(0)
end
GO
