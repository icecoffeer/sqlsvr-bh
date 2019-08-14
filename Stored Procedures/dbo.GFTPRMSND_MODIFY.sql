SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[GFTPRMSND_MODIFY]
(
  @Num varchar(14),            --协议号
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output  --错误信息
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vOper int

  select @vStat = STAT from GFTPRMSND (nolock) where NUM = @Num
  if @vStat is null
  begin
    set @Msg = '取赠品发放单状态失败.'
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
    if (@vStat <> 0) and (@vStat <> 1600)
    begin
      set @Msg = '此单据已变更,不能保存'
      return 1
    end  
  end else if @ToStat = 1600 
  begin
  	if @vStat <> 0
  	begin
      set @Msg = '此单据不是未审核单据,不能预审'
      return 1  	  
  	end
  end else if @ToStat = 120
  begin
    if @vStat <> 100
    begin
      set @Msg = '此单据不是已审核单据,不能冲单'
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
  if (@ToStat = 100) or (@ToStat = 1600) or (@ToStat = 120)
  begin
    select @vOper = gid from employee where rtrim(name) + '[' + rtrim(code) + ']' = rtrim(@Oper)
    if @vOper is null
    begin
      set @Msg = '员工表中找不到当前操作者信息'
      return 1
    end
    exec @vRet = GFTPRMSND_CHECK @Num, @ToStat, @vOper, @Msg output
  end  
  update GFTPRMSND set LstUpdTime = getdate() where Num = @Num
  Return @vRet
end
GO
