SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3NOTSCOREGDSCOPE_REMOVE]
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
  select @Stat = STAT from PS3NOTSCOREGDSCOPE(nolock) where NUM = @NUM
  if @Stat <> 0
  begin
    set @Msg = @cls + '单(' + @Num + ')不是未审核状态，不允许删除!'
    return(1)
  end
  exec @ret = PS3NOTSCOREGDSCOPE_DOREMOVE @num, @cls, @msg output
  IF @RET <> 0 RETURN(@RET)
  delete from PS3NOTSCOREGDSCOPELOG where NUM = @Num and CLS = @Cls
  return(0)
end
GO
