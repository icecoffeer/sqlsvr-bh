SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_REMOVE] (
  @piNum varchar(14),                     --单号
  @poMsg varchar(255) output           --出错信息
) as
begin
  declare
    @vStat int,
    @vRet Int

  select @vStat = Stat from CRMMBRPROMTYPEBILL(nolock) where NUM = @piNUM
  if @@rowcount = 0
  begin
    set @poMsg = '不存在的会员促销类型登记单' + @piNum
    return(1)
  end

  if @vStat <> 0
  begin
    set @poMsg = '会员促销类型登记单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end

  exec @vRet = PCRM_MBRPROMTYPE_DOREMOVE @piNum, @poMsg output
  IF @vRet <> 0 RETURN(@vRet)

  delete from CRMMBRPROMTYPEBILLLOG where NUM = @piNum

  return(0)
end
GO
