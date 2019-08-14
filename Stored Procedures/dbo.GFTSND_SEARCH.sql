SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_SEARCH]
(
  @piRuleCond   varchar(1000)	output,
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vMinDate datetime
  declare @vMaxDate datetime
  declare @vCode varchar(18)
  declare @vRet int
  declare @vCost money

  --清空临时表
  delete from TMPGFTSNDRESULT where spid = @@spid;
  delete from TMPGFTSNDHINT where spid = @@spid;

  select @vMinDate = min(SALETIME), @vMaxDate = max(SALETIME) from TMPGFTSNDSALE(nolock) where spid = @@spid
  if @piRuleCond is null
    declare c_rule cursor for
    select CODE from GFTPRMRULE(nolock)
    where STAT = 1 and BEGINTIME <= @vMaxDate and ENDTIME >= @vMinDate for read only
  else
    exec('declare c_rule cursor for select CODE from GFTPRMRULE(nolock) where ' + @piRuleCond + ' for read only')
  open c_rule
  fetch next from c_rule into @vCode
  while @@fetch_status = 0
  begin
    exec @vRet = GFTSND_MATCHRULE @vCode, @poErrMsg output
    if @vRet <> 0
    begin
      close c_rule
      deallocate c_rule
      return(1)
    end
    fetch next from c_rule into @vCode
  end
  close c_rule
  deallocate c_rule

  --估算规则的价值
  declare c_rule cursor for
    select RCODE from TMPGFTSNDRESULT where SPID = @@SPID for update
  open c_rule
  fetch next from c_rule into @vCode
  while @@fetch_status = 0
  begin
    exec GFTSND_RULECOST @vCode, @vCost output
    update TMPGFTSNDRESULT set COST = @vCost where current of c_rule
    fetch next from c_rule into @vCode
  end
  close c_rule
  deallocate c_rule

  return(0)
end
GO
