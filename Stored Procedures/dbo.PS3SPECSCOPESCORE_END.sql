SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECSCOPESCORE_END]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare @Stat int
  select @Stat = STAT from PS3SPECSCOPESCORE(nolock) where NUM = @Num
  if @Stat <> 100
  begin
    set @Msg = '不是已审核的单据，不能进行结束操作。'
    return(1)
  end

  -- 删除当前值
  delete from PS3SPECSCOPESCOREINV where SRCNUM = @Num and SRCCLS = @cls
  delete from PS3SPECSCOPESCOREINVOUT where SRCNUM = @Num and SRCCLS = @cls
  delete from PS3SPECSCOPESCOREINVSPECDIS where SRCNUM = @Num and SRCCLS = @cls

  --更新单据状态
  update PS3SPECSCOPESCORE
    set STAT = @ToStat, ABORTDATE = GETDATE(), ABORTER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

  exec PS3SPECSCOPESCORE_ADD_LOG @Num, @Cls, @ToStat, '结束', @Oper

  Return(0)
end
GO
