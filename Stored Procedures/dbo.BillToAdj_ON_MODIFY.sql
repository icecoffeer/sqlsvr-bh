SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[BillToAdj_ON_MODIFY]
(
  @Num varchar(14),            --协议号
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output  --错误信息
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from BILLTOADJ (nolock) where NUM = @Num
  if @vStat is null
  begin
    set @Msg = '取商品缺省供应商调整单状态失败.'
    return 1
  end
  if @ToStat = 0
  begin
    if @vStat <> 0
    begin
      set @Msg = '单据已经被其他人处理，不能保存'
      return 1
    end
  end else if @ToStat = 100
  begin
    if @vStat <> 0
    begin
      set @Msg = '此单据已变更,不能保存'
      return 1
    end
  end else
  begin
    set @Msg = '未知状态.'
    return(1)
  end

  set @vRet = 0
  --状态调度
  --if @vStat <> @ToStat
  if @ToStat = 100
    exec @vRet = BILLTOADJCHK @Num, '', @ToStat, @Oper, @Msg output
  update BILLTOADJ set LstUpdTime = getdate() where Num = @Num
  exec BillToAdj_ADD_LOG @Num, @vStat, @ToStat, @Oper
  Return @vRet
end
GO
