SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCORE_CALCONSCOREBACK]
(   
  @piCardNum varchar(20), ---卡号
  @piPosNo varchar(10),   ---Pos号
  @piFlowNo varchar(12),  ---交易流水号   
  @poConDate datetime output,  --消费日期            --转换日期
  @poAmount money output,        --消费金额
  @poScore money output,        --消费积分
  @poErrMsg varchar(255) output  --出错信息
) as
declare @nResult int
begin
  ---该过程需要定制为对应的Pos的取积分的过程
  --exec @Result = exec PPS_CONSSCO_CalConScoreByPosNo @piCardNum, @piPosNum, @piFlowNo, @poConDate, @poAmount, @poScore, @poErrMsg output
  return @nResult
end
GO
