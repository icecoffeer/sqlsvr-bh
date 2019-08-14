SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PGFBOOK_GEN_FROM_POOL] (
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vRet integer
  declare @vPGFBookNum varchar(14)
  declare @vSysDate datetime
  declare @vVdrGid integer
  declare @vPGFCode varchar(20)
  declare @vCntrNum varchar(14)
  declare @vCalcBegin datetime
  declare @vCalcEnd datetime
  declare @vCalcTotal decimal(24, 2)
  declare @vSrcNum varchar(20)
  declare @vSrcCls varchar(20)
  declare @vGatheringMode varchar(20)
  declare @vPayDirect integer
  declare @vDept varchar(20)
  declare @vPsr varchar(20)
  declare @vPsrGid integer
  declare @vPayDate datetime

  if object_id('c_Pool') is not null deallocate c_Pool
  declare c_Pool cursor for
    select VDRGID, PGFCODE, CNTRNUM, CALCBEGIN, CALCEND,
      CALCTOTAL, SRCNUM, SRCCLS, GATHERINGMODE, PAYDIRECT,
      DEPT, PSR, PAYDATE
    from TMPPGFBOOK where SPID = @@spid

  select @vSysDate = convert(varchar, getdate(), 102)

  delete from TMPGENBILLS where OWNER = '生成抵扣货款单' and SPID = @@spid
  open c_Pool
  fetch next from c_Pool into @vVdrGid, @vPGFCode, @vCntrNum, @vCalcBegin, @vCalcEnd,
    @vCalcTotal, @vSrcNum, @vSrcCls, @vGatheringMode, @vPayDirect, @vDept, @vPsr, @vPayDate
  while @@fetch_status = 0
  begin
    set @vPsrGid = null
    if rtrim(isnull(@vPsr, '')) <> ''
    begin
      select @vPsrGid = GID from EMPLOYEE where CODE = @vPsr
      if @@rowcount = 0
      begin
        set @poErrMsg = '未找到采购员 ' + @vPsr
        close c_Pool
        deallocate c_Pool
        return(1)
      end
    end
    exec @vRet = PCT_PGFBOOK_FILL @vVdrGid, @vCntrNum, @vPGFCode, @vCalcBegin, @vCalcEnd,
      @vCalcTotal, @vSysDate, @vPayDate, @vGatheringMode, @vPayDirect,
      @vDept, @vPsrGid, '外部导入', @vSrcCls, @vSrcNum,
      @piOperGid, @vPGFBookNum output, @poErrMsg output
    if @vRet <> 0
    begin
      close c_Pool
      deallocate c_Pool
      return(@vRet)
    end
    --记录到临时表
    insert into TMPGENBILLS(SPID, OWNER, BILLNAME, NUM, DTLCNT, STARTTIME, FINISHTIME, STAT)
    values(@@spid, '生成抵扣货款单', '抵扣货款单', @vPGFBookNum, 0, getdate(), getdate(), 0)

    fetch next from c_Pool into @vVdrGid, @vPGFCode, @vCntrNum, @vCalcBegin, @vCalcEnd,
      @vCalcTotal, @vSrcNum, @vSrcCls, @vGatheringMode, @vPayDirect, @vDept, @vPsr, @vPayDate
  end
  close c_Pool
  deallocate c_Pool

  return(0)
end
GO
