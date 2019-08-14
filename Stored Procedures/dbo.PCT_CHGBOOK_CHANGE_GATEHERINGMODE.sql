SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_CHANGE_GATEHERINGMODE] (
  @piNum varchar(14),            --费用单单号
  @piGatheringMode varchar(10),  --收款方式
  @piOperGid integer,            --操作人
  @poErrMsg varchar(255) output  --出错信息
) as
begin
  declare @vRet integer
  declare @vStat integer
  declare @vRefNum varchar(14)

  --检查费用单的状态
  select @vStat = STAT from CHGBOOK where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到费用单 ' + @piNum
    return(1)
  end
  if @vStat <> 500
  begin
    set @poErrMsg = '费用单 ' + @piNum + ' 不是已审核状态，不能变更收款方式'
    return(1)
  end

  --检查费用单是否被付款类单据引用
  select @vRefNum = m.NUM
  from CNTRPAYCASH m, CNTRPAYCASHDTL d
  where m.STAT in (0, 2100, 2200, 2300, 100) and m.NUM = d.NUM and d.CHGTYPE = '费用单' and d.IVCCODE = @piNum
  if @vRefNum is not null
  begin
    set @poErrMsg = '费用单已经被付款单 ' + @vRefNum + ' 引用，不能变更收款方式'
    return(1)
  end
  select @vRefNum = m.NUM
  from VDRPAY m, VDRPAYDTL d
  where m.STAT = 0 and m.NUM = d.NUM and d.CHGNUM = @piNum
  if @vRefNum is not null
  begin
    set @poErrMsg = '费用单已经被交款单 ' + @vRefNum + ' 引用，不能变更收款方式'
    return(1)
  end

  --修改费用单
  if @piGatheringMode in ('立即交款', '冲扣货款')
  begin
    update CHGBOOK set
      GATHERINGMODE = @piGatheringMode,
      LSTUPDTIME = getdate()
    where NUM = @piNum
  end

  return(0)
end
GO
