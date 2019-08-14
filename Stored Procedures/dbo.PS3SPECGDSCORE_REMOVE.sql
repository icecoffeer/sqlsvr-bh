SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3SPECGDSCORE_REMOVE]
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
  select @Stat = STAT from PS3SPECGDSCORE(nolock)
    where NUM = @NUM And CLS = @Cls
  if @Stat <> 0
  begin
    set @Msg = @Cls + '单(' + @Num + ')不是未审核状态，不允许删除!'
    return(1)
  end
  exec @Ret = PS3SPECGDSCORE_DOREMOVE @Num, @Cls, @Msg output
  IF @RET <> 0 RETURN(@Ret)
  delete from PS3SPECGDSCORELOG where NUM = @Num and CLS = @Cls

  Return(0)
end
GO
