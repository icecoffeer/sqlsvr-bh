SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[EMPSALETASK_REMOVE]
(
    @Num varchar(14),         --单号
    @Msg varchar(255) output  --错误信息
)
as
begin
  declare
    @Stat int,
    @Ret int
  select @Stat = STAT from EMPSALETASK(nolock) where NUM = @NUM
  if @Stat <> 0
  begin
    set @Msg = '不是未审核状态，不允许删除!';
    return(1);
  end
  exec @ret = EMPSALETASK_DOREMOVE @num, @msg output
  IF @RET <> 0 RETURN(@RET)
  delete from EMPSALETASKLOG where NUM = @Num
  return(0)
end
GO
