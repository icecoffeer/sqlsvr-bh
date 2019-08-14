SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_SCORE_CALC]
(
  @piDate datetime,              --消费日期
  @piAmount money,               --消费金额
  @poScore money output,         --应增加的消费积分
  @poErrMsg varchar(255) output  --错误信息
) as
begin
  declare 
    @vScore money,
    @vAmount money,
    @vMinAmount money,
    @nOptionMinAmount int

  delete from TMPSUBJECTSCORE where SPID = @@spid
  select @nOptionMinAmount = Convert(int, OptionValue) from HdOption where ModuleNo = 3802 and OptionCaption = 'CRM_MINAMOUNT'
  if @@ROWCOUNT = 0
    set @nOptionMinAmount = 0  
  
 
  select @vAmount = AMOUNT, @vScore = SCORE, @vMinAmount = MINAMOUNT from CRMSCORE where CLS = '消费'
  if @@rowcount = 0
  begin
    set @vAmount = 1
    set @vScore = 0
  end
  if (@nOptionMinAmount <> 0)
  begin
    if @piAmount < @vMinAmount 
      set @piAmount = 0
  end 
  
  set @poScore = floor(@piAmount / @vAmount) * @vScore

  insert into TMPSUBJECTSCORE(SPID, SORT, SUBJECT, SCORE) values(@@spid, '-', '101', @poScore)

  return(0)
end
GO
