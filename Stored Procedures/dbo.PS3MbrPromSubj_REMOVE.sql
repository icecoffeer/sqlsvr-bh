SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3MbrPromSubj_REMOVE]
(
    @Num varchar(14),         --单号
    @Cls varchar(10),
    @Msg varchar(255) output  --错误信息
)
as
begin
  declare
    @Stat int,
    @Ret int
  select @Stat = STAT from PS3MBRPROMSUBJ(nolock)
  where Cls = @Cls And NUM = @NUM
  if @Stat <> 0
  begin
    set @Msg = '会员促销主题' + @Cls + '单(' + @Num + ')不是未审核状态，不允许删除!'
    return(1)
  end
  exec @ret = PS3MbrPromSubj_DOREMOVE @Num, @Cls, @Msg output
  IF @RET <> 0 RETURN(@RET)

  delete from PS3MBRPROMSUBJLOG where NUM = @Num and CLS = @Cls

  Return(0)
end
GO
