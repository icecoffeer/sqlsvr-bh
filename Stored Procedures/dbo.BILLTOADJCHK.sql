SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[BILLTOADJCHK]
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
    --@m_launch datetime,
    @usergid int,
    @m_GoOnChk int

  select @return_status = 0
  select @usergid = usergid from FASYSTEM(nolock)
  select @stat = STAT, /*@m_launch = LAUNCH,*/ @m_GoOnChk = GoOnChk from BILLTOADJ(nolock) where NUM = @num

  if (@stat <> 0) and (@toStat = 100)
  begin
    set @Msg = '审核的不是未审核的单据.'
    return(1)
  end
  update BILLTOADJ set STAT = 100, Checker = @oper, ChkDate = GETDATE() where NUM = @num

  --如果审核时生效
  if @m_GoOnChk = 0
    execute @return_status = BILLTOADJGO @num, @Oper
  if @return_status <> 0
    return(@return_status)

  -- 审核时发送
  DECLARE @SendOnChk int
  EXEC OptReadInt 776, 'SendOnChk', 0, @SendOnChk OUTPUT
  IF @SendOnChk <> 0
  BEGIN
    EXEC @return_status = BILLTOADJSEND @num, @Msg OUTPUT
    IF @return_status <> 0
      RETURN @return_status
  END
  RETURN 0
end
GO
