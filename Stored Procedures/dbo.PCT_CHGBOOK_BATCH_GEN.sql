SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_BATCH_GEN] (
  @piCntrNum varchar(14),           --合约号
  @piChgCode varchar(20),           --帐款项目，如果为null，表示该合约的所有帐款项目
  @piOperGid integer,               --操作人
  @poErrMsg varchar(255) output,    --出错信息
  @piBegDate datetime = null,       --统计开始日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
  @piEndDate datetime = null        --统计截止日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
) as
begin
  declare @vCntrVersion integer
  declare @vStat integer
  declare @vRet integer
  declare @vCntrLine integer
  declare @vMessage varchar(255)

  set @vMessage = '合约=' + @piCntrNum + ', 帐款项目约束=' + @piChgCode
  exec PCT_CHGBOOK_LOGDEBUG 'Batch_Gen', @vMessage

  select
    @vCntrVersion = VERSION,
    @vStat = STAT
  from CTCNTR where NUM = @piCntrNum and TAG = 1
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到当前合约'
    return(1)
  end
  if @vStat not in (500, 1400)
  begin
    set @poErrMsg = '不是已审核或已终止的合约'
    return(1)
  end

  if object_id('c_Line') is not null deallocate c_Line
  declare c_Line cursor for
    select d.LINE from CTCNTRDTL d, CTCHGDEF c
    where d.NUM = @piCntrNum and d.VERSION = @vCntrVersion
      and d.CHGCODE = c.CODE and c.AUTOCALC = 0 and c.WHENGEN = '指定时间'
      and (@piChgCode is null or c.CODE = @piChgCode)
      and (((d.NEXTGENDATE is not null and d.NEXTGENDATE <= getdate())
      and c.DESIGNCYCLE = 0) or (c.DESIGNCYCLE = 1))

  set @vRet = 0
  delete from TMPGENBILLS where OWNER = '生成费用单' and SPID = @@spid
  open c_Line
  fetch next from c_Line into @vCntrLine
  while @@fetch_status = 0
  begin
    exec @vRet = PCT_CHGBOOK_BATCH_GEN_ONE @piCntrNum, @vCntrVersion, @vCntrLine, 2, @piOperGid, @poErrMsg output, @piBegDate, @piEndDate 
    if @vRet <> 0 break

    fetch next from c_Line into @vCntrLine
  end
  close c_Line
  deallocate c_Line

  return(@vRet)
end
GO
