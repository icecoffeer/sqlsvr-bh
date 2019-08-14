SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3MbrPromSubj_ABORT]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare @Stat int
  declare @uuid varchar(32)
  select @Stat = STAT from PS3MBRPROMSUBJ(nolock) where Cls = @Cls And NUM = @Num
  if @Stat <> 100
  begin
    set @Msg = '不是已审核的单据，不能进行作废操作。'
    return(1)
  end

  -- 删除当前值
  select @uuid = uuid from PS3MBRPROMSUBJ where Cls = @Cls And NUM = @Num
  delete from PS3CRMPROMSUBJECT where UUID = @uuid
  delete from PS3CRMPROMSUBJECTDTL where SUBJUUID = @uuid

  --更新单据状态
  update PS3MBRPROMSUBJ
    set STAT = @ToStat, ABORTDATE = GETDATE(), ABORTER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

  exec PS3MbrPromSubj_ADD_LOG @Num, @Cls, @ToStat, '作废', @Oper
  return(0)
end
GO
