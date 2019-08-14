SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECSCOPESCORE_CHECK]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @return_status int,
    @Stat int,
    @Settleno int,
    @Line int

  --校验单据状态。
  set @Stat = null
  select @Stat = STAT from PS3SPECSCOPESCORE(nolock)
    where NUM = @Num and CLS = @Cls
  if @Stat is null
  begin
    set @Msg = '未找到单据' + isnull(@Num, '') + '，不能进行审核操作。'
    return(1)
  end
  else if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作。'
    return(1)
  end

  --校验单据明细中的供应商-部门属性的匹配关系。
  select top 1 @Line = d.LINE
    from PS3SPECSCOPESCOREDTL d(nolock)
    left join V_DPTVDR v(nolock) on v.DEPT = d.DEPT and v.VENDOR = d.VENDOR
    where d.NUM = @Num
    and d.CLS = @Cls
    and d.DEPT is not null
    and d.VENDOR is not null
    and (v.DEPT is null or v.VENDOR is null)
  if @@rowcount = 1
  begin
    set @Msg = '第' + convert(varchar, @Line) + '行明细的部门和供应商的匹配关系不符合系统的规定，不允许审核。'
    return(1)
  end

  --更新汇总信息。
  select @Settleno = max(no) from MONTHSETTLE
  update PS3SPECSCOPESCORE set
    STAT = @ToStat,
    SETTLENO = @Settleno,
    CHKDATE = getdate(),
    CHECKER = @Oper,
    LSTUPDTIME = getdate(),
    LSTUPDOPER = @Oper
    where NUM = @Num
    and CLS = @Cls

  --记录当前值。
  exec @return_status = PS3SPECSCOPESCORE_OCR @Num, @Cls, @Oper, @Msg output
  if @return_status <> 0
    return(@return_status)

  --记录状态变化日志。
  exec PS3SPECSCOPESCORE_ADD_LOG @Num, @Cls, @ToStat, '审核', @Oper

  return(0)
end
GO
