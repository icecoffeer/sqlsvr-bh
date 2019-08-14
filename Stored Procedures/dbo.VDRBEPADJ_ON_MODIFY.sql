SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[VDRBEPADJ_ON_MODIFY](
  @Num varchar(14),            --单号
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from VDRBEPADJ(nolock) where NUM = @Num
  if @vStat is null
  begin
    set @Msg = '取供应商保底金额调整单状态失败.'
    return 1
  end
  if @ToStat = 0
  begin
    if @vStat <> 0
    begin
      set @Msg = '单据已经被其他人处理，不能保存'
      return 1
    end
  end 
  else if @ToStat = 100
  begin
    if @vStat <> 0
    begin
      set @Msg = '审核的不是未审核的单据'
      return 1
    end  
  end else
  begin
    set @Msg = '未知状态.'
    return(1)
  end

  set @vRet = 1
  --状态调度
  if (@vStat <> @ToStat) and (@ToStat = 100)
  begin
    ---- 审核
    exec @vRet = VDRBEPADJ_CHECK @Num, @oper, @msg output
    if @vRet = 1
      return 1
    set @vRet = 1
    --生效
    exec @vRet = VDRBEPADJ_MODIFYTO800 @Num, @oper, @msg output
    Return @vRet
  end
end
GO
