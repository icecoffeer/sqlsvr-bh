SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCORE_CALC_DEPOSIT]
(
  @piDate datetime,              --储值日期
  @piAmount money,               --储值金额
  @poScore money output,         --应增加的储值积分
  @poErrMsg varchar(255) output  --错误信息
) as
begin
  declare @vScore money
  declare @vAmount money

  select @vAmount = AMOUNT, @vScore = SCORE from CRMSCORE where CLS = '储值'
  if @@rowcount = 0
  begin
    set @vAmount = 1
    set @vScore = 0
  end
  set @poScore = floor(@piAmount / @vAmount) * @vScore

  return(0)
end
GO
