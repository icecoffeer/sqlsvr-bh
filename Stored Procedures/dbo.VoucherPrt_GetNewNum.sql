SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VoucherPrt_GetNewNum]
(
  @piVoucherActCode Char(10), --活动代码
  @piCurNum Char(32), --已在发券明细中使用的券号
  @piCurStore int, --赠券制单单位  
  @poNewNum Char(32) Output, --新的券号
  @poErrMsg Char(255) Output --错误信息
) as
begin
  declare
    @v_CurNum varchar(32), --当前券号,起始是"券活动.券起始券号"
    @v_EndNum varchar(32), --券结束单号
    @v_MadeType smallint, --制券方式-0:预制,l:机打
    @v_state int,
    @v_Count int, --计数
    @v_VoucherCount int,--券活动中定义的券数量
    @v_ReceiveStore int,--预制券发放门店    
    @v_Ret int

  Select @v_CurNum = A.BEGINNUM, @v_MadeType = T.MADETYPE,
    @v_VoucherCount = A.Qty, @v_EndNum = ENDNUM
  From VOUCHERACTIVITY A, VOUCHERTYPE T
    Where A.VOUCHERTYPE = T.Code and A.Code = @piVoucherActCode
  
  if @v_CurNum is null 
  begin    
    Set @poErrMsg = '总部对应活动号'+ rtrim(@piVoucherActCode) +'不存在.'    
    return 1    
  end  
  --如果传入的券号不为空,那么先取下一个券号
  if (RTrim(@piCurNum) <> '') and (@piCurNum is not null)
  begin
    Exec @v_Ret = Voucher_NextNum @piCurNum, @v_CurNum Output, @poErrMsg Output
    if @v_Ret <> 0
      return 1
    Set @v_VoucherCount = Convert(Money, @v_EndNum) - Convert(Money, @v_CurNum) + 1
  end

  --对券活动中定义的起止券区间做循环
  SET @v_Count = 0
  WHILE @v_Count <> @v_VoucherCount
  begin
    --判断机打券（@v_MadeType = 1）券号是不是已制作(state=0)
    --edit by zc ,预制券（@v_MadeType = 0）必须是已发放到发生门店的（state = 1 and receivestore = curstore）  
    --否则取下一张  
    Select @v_state = State,@v_ReceiveStore = ReceiveStore from Voucher Where Num = @v_CurNum  
    if (@v_state = 0 and @v_MadeType = 1) or (@v_state = 1 and  @v_MadeType = 0 and @v_ReceiveStore = @piCurStore)
      Break

    --如果券不可用,那么算下一张券号
    SET @v_Count = @v_Count + 1
    Exec @v_Ret = Voucher_NextNum @v_CurNum, @v_CurNum Output, @poErrMsg Output
    if @v_Ret <> 0
      return 1
  end
  --如果券遍历完还没有找到,那么返回错误提示
  if @v_Count = @v_VoucherCount    
  begin    
    Set @poErrMsg = '未找到发券规则对应制作的可用券,或者活动号' + rtrim(@piVoucherActCode) + '可用券不足!'   
    return 1    
  end    
  Set @poNewNum = @v_CurNum   

  return 0
end
GO
