SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[GFTPRMBCK_MODIFY]
(
  @Num varchar(14),            
  @Cls char(10),
  @ToStat int,                 
  @Oper varchar(30),           
  @Msg varchar(255) output  
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vOper int

  select @vStat = STAT from GFTPRMBCK (nolock) where NUM = @Num
  if @vStat is null
  begin
    set @Msg = '取赠品回收单状态失败.'
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
  if (@ToStat = 100) 
  begin
    select @vOper = gid from employee where rtrim(name) + '[' + rtrim(code) + ']' = rtrim(@Oper)
    if @vOper is null
    begin
      set @Msg = '员工表中找不到当前操作者信息'
      return 1
    end
    exec @vRet = gftprmbck_check @Num,  @vOper, @Cls, @ToStat, @Msg output
  end  
  update GFTPRMBCK set LstUpdTime = getdate() where Num = @Num
  Return @vRet
end
GO
