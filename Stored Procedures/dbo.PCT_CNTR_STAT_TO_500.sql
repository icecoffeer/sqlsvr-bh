SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_STAT_TO_500](
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet integer
  declare @vGroupNum char(14)
  declare @vGroupVersion int
  declare @vBeginDate datetime
  declare @vEndDate datetime
  declare @vCntrBeginDate datetime
  declare @vCntrEndDate datetime
  declare @vStat int
  declare @vDupNum char(14)
  declare @vDupVersion int

  select @vGroupNum = g.NUM, @vGroupVersion = g.VERSION, @vStat = g.STAT
  from GROUPCNTR gc(nolock), CNTRGROUP g(nolock)
  where g.NUM = gc.NUM
    and g.VERSION = gc.VERSION
    and gc.CNTRNUM = @piNum
    and gc.CNTRVERSION = @piVersion
    and g.TAG = 1
  if @vStat <> 100
  begin
    set @poErrMsg = '合约组状态不是已审核'
    return(1)
  end

  select @vBeginDate = BEGINDATE, @vEndDate = ENDDATE
  from CNTRGROUP(nolock) where NUM = @vGroupNum and VERSION = @vGroupVersion;
  select @vCntrBeginDate = BEGINDATE, @vCntrEndDate = ENDDATE
  from CTCNTR(nolock) where NUM = @piNum and VERSION = @piVersion;
  if (@vCntrBeginDate < @vBeginDate) or (@vCntrEndDate > @vEndDate)
  begin
    set @poErrMsg = '合约起始截止日期超出合约组的起始截止日期';
    return(1);
  end;
  
  select top 1 @vDupNum = m.NUM, @vDupVersion = m.VERSION
  from CTCNTR m(nolock), CTCNTRBRANDKWHMETER d(nolock)
  where m.NUM = d.NUM
    and m.VERSION = d.VERSION
    and not (m.NUM = @piNum and m.VERSION = @piVersion) --排除本合约
    and m.STAT in (500, 1400)
    and m.TAG in (1, 2)
    and d.NO in (select NO from CTCNTRBRANDKWHMETER(nolock) where NUM = @piNum and VERSION = @piVersion)
  order by m.NUM, m.VERSION
  if @@rowcount > 0
  begin
    set @poErrMsg = '电表重复：存在电表编号已被下列合约所引用。' + char(13) + char(10) + '合约编号：' + @vDupNum + '，版本：' + convert(varchar, @vDupVersion) + '。';
    return(1);
  end

  exec @vRet = PCT_CNTR_UPDATE_GENDATE @piNum, @piVersion, @poErrMsg output
  if @vRet <> 0 return(@vRet)
    update CTCNTR set STAT = 500 where NUM = @piNum and VERSION = @piVersion
  exec @vRet = PCT_CNTR_SEND @piNum, @piVersion, @piOperGid, @poErrMsg output
  if @vRet > 0 return(@vRet)

  return(0)
end
GO
