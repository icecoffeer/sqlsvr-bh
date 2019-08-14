SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECGDSCORE_END]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare @Stat int
  select @Stat = STAT from PS3SPECGDSCORE(nolock)
    where NUM = @Num And CLS = @Cls
  if @Stat <> 100
  begin
    set @Msg = '不是已审核的单据，不能进行结束操作。'
    return(1)
  end

  -- 删除当前值
  delete from PS3SPECGDSCOREINV where SRCNUM = @Num and SRCCLS = @Cls
  delete from PS3SPECGDSCOREINVOUT where SRCNUM = @Num and SRCCLS = @Cls
  delete from PS3SPECGDSCOREINVSPECDIS Where SRCNUM = @Num and SRCCLS = @Cls

  --更新单据状态
  update PS3SPECGDSCORE
    set STAT = @ToStat, ABORTDATE = GETDATE(), ABORTER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

  exec PS3SPECGDSCORE_ADD_LOG @Num, @Cls, @ToStat, '结束', @Oper

  Return(0)
end
GO
