SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCORE_TOMONEY]
(
  @piDate datetime,              --转换日期
  @piScore money,                --转换积分
  @poAmount money output,        --应增加的储值金额
  @poChange money output,        --不能兑换的积分零头
  @poErrMsg varchar(255) output  --出错信息
) as
begin
  declare @vScore money
  declare @vAmount money
  declare @vCount money

  if @piScore < 0 
  begin
    set @poErrMsg = '转化积分不能小于零'
    return(1)
  end

  set @poAmount = 0
  set @poChange = @piScore
  while @poChange > 0
  begin
    select @vScore = isnull(max(SCORE), 0) from CRMSCOREMONEY(nolock) where SCORE <= @poChange
    if @vScore = 0 return(0)
    select @vAmount = AMOUNT from CRMSCOREMONEY(nolock) where SCORE = @vScore
    set @vCount = floor(@poChange / @vScore)
    set @poAmount = @poAmount + @vCount * @vAmount
    set @poChange = @poChange - @vCount * @vScore
  end
  
  return(0)
end
GO
