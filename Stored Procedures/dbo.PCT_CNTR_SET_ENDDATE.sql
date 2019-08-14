SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_SET_ENDDATE] (
  @piNum varchar(14),           --合约号
  @piVersion integer,           --合约版本号
  @piEndDate datetime,              --延期日期
  @piNextBeginDate datetime,        --下次统计开始日期
  @piNextEndDate datetime,          --下次统计结束日期
  @piAddedNextBeginDate datetime,        --下次补充协议统计开始日期
  @piAddedNextEndDate datetime,          --下次补充协议统计结束日期
  @piOperGid int,
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vVersion int
  declare @vLine int
  declare @vIsAdded int
  declare @GenDate datetime
  declare @RealEndDate datetime
  declare @vGenMethod integer

  --数据检查
  exec PCT_CNTR_CURRENT_VERSION @piNum, @vVersion output
  if (@vVersion <> @piVersion)
  begin
    set @poErrMsg = '不能处理历史版本的合约.'
    return(1)
  end
  select @vStat = STAT from CTCNTR(nolock)
    where NUM = @piNum and VERSION = @piVersion
  if (@vStat is null)
  begin
    set @poErrMsg = '取合约状态失败.'
    return(1)
  end
  if @vStat not in (500, 1400)
  begin
    set @poErrMsg = '不是已审核或者已终止状态的合约，不能延期。'
    return(1)
  end

  --延期 - 更新结束日期，实际结束日期，更新明细下次生成日期，更新状态为已审核
  select @RealEndDate = S.RealEndDate from CTCNTR C, GROUPCNTR G, CNTRGROUP S
    where C.NUM = @piNum and C.VERSION = @piVersion and C.NUM = G.CNTRNUM and C.Version = G.CNTRVERSION and G.Num = S.Num and G.Version = S.Version
  declare @vOper varchar(50)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  update CTCNTR set EndDate = @piEndDate, RealEndDate = @RealEndDate, stat = 500, MODIFIER = @vOper, LSTUPDTIME = getdate() where NUM = @piNum and VERSION = @piVersion

  declare c_cntr cursor for
    select LINE, IsAdded
    from CTCNTRDTL where NUM = @piNum and VERSION = @piVersion
  open c_cntr
  fetch next from c_cntr into @vLine, @vIsAdded
  while @@fetch_status = 0
  begin
    If @vIsAdded = 1
    begin
      update CTCNTRDTL set NEXTGENDATE = @piAddedNextEndDate + 1 where NUM = @piNum and VERSION = @piVersion and LINE = @vLine
      update CTCNTRRATEDTL set NEXTBEGINDATE = @piAddedNEXTBEGINDATE, NEXTENDDATE = @piAddedNEXTENDDATE where NUM = @piNum and VERSION = @piVersion and LINE = @vLine
    end
    else
    begin
      update CTCNTRDTL set NEXTGENDATE = @piNextEndDate + 1 where NUM = @piNum and VERSION = @piVersion and LINE = @vLine
      update CTCNTRRATEDTL set NEXTBEGINDATE = @piNEXTBEGINDATE, NEXTENDDATE = @piNEXTENDDATE where NUM = @piNum and VERSION = @piVersion and LINE = @vLine
    end

    fetch next from c_cntr into @vLine, @vIsAdded
  end
  close c_cntr
  deallocate c_cntr


  if @vRet <> 0 return(@vRet)
  exec PCT_CNTR_ADDLOG @piNum, @piVersion, @piOperGid, @vStat, 500, '延期'
  return(0)
end
GO
