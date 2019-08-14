SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_AllocByStkOut_ChkStkOutNum](
  @piStkOutNum varchar(10),     --传入参数：配出单号。
  @poIsProcessed int output,    --传出参数：单号为 @piStkOutNum 的配出单是否已经过RF配货？0-否；1-是。返回值为0时有效。
  @poErrMsg varchar(255) output --传出参数：错误消息。返回值不为0时有效。
)
as
begin
  declare
    @StkOutStat int

  --检查单号合法性。
  if @piStkOutNum is null or rtrim(@piStkOutNum) = ''
  begin
    set @poErrMsg = '配货出货单号不能为空。'
    return 1
  end
  select @StkOutStat = STAT
    from STKOUT(nolock)
    where CLS = '配货'
    and NUM = @piStkOutNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '配货出货单' + rtrim(@piStkOutNum) + '不在数据库中存在。'
    return 1
  end
  else if @StkOutStat <> 0
  begin
    set @poErrMsg = '配货出货单' + rtrim(@piStkOutNum) + '的状态不是未审核，不能录入。'
    return 1
  end

  --检查单号是否已经被配过货了，@poIsProcessed 将返回界面由操作人确认。
  if exists(select 1 from RFALLOCBYSTKOUTH(nolock) where STKOUTNUM = @piStkOutNum)
  begin
    set @poIsProcessed = 1
  end
  else begin
    set @poIsProcessed = 0
  end

  return 0
end
GO
