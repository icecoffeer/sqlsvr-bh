SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PRMOFFSETAGMCHK]
(
  @num varchar(14),
  @cls varchar(10),
  @toStat int,  --100 审核
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  declare
    @return_status int,
    @stat int,
    @m_launch datetime,
    @optSendOnChk int
  select @return_status = 0;

  select @stat = STAT, @m_launch = LAUNCH from PRMOFFSETAGM where NUM = @num;
  if (@stat <> 0) and (@toStat = 100)
  begin
    set @Msg = '审核的不是未审核的单据.';
    return(1)
  end
  update PRMOFFSETAGM set STAT = 100, Checker = @oper, ChkDate = GETDATE() where NUM = @num;

  if (@m_launch is null or @m_launch < getdate())
    execute @return_status = PRMOFFSETAGMGO @num, '', -1, @Oper, NULL;
  if @return_status <> 0
    return(@return_status);

  -- 自动发送
  exec OptReadInt 761, 'SENDONCHK', 0, @optSendOnChk output
  if @optSendOnChk = 1
  begin
    exec @return_status = PrmOffsetAgm_SEND @cls = '', @num = @num, @oper = @oper, @tostat = @tostat, @msg = @msg
    if @return_status <> 0
      return (@return_status)
  end
  RETURN (@return_status);
end
GO
