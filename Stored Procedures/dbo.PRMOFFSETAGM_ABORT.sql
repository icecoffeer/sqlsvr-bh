SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETAGM_ABORT]
(
  @num varchar(14),
  @cls varchar(10),
  @toStat int, --客户端调用时传入参数值为0
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  declare
    @vstat int,
    @optSendOnChk int,
    @vret int
  select @vstat = stat from prmoffsetagm(nolock) where num = @num
  if @vstat not in(100, 800)
  begin
    set @msg = '不是已审核或已生效的单据，不能终止。';
    return(1);
  end
  exec OptReadInt 761, 'SENDONCHK', 0, @optSendOnChk output
  update prmoffsetagm set stat = 1400 where num = @num
  if @vstat = 800
  begin
    delete from PRMOFFSETAGMLAC where num = @num and rbdate > convert(varchar(10), getdate(), 120)
    update PRMOFFSETDEBIT set RECAL = 1 where num = @num
  end
  if @optSendOnChk = 1
  begin
    exec @vret = PrmOffsetAgm_SEND @cls = '', @num = @num, @oper = @oper, @tostat = 1400, @msg = @msg
    if @vRet <> 0
      return (@vret)
  end
  return(0)
end
GO
