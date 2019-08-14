SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[VOUCHERBCKSTGRCV_REMOVE]
(
  @Num varchar(14),         --单号
  @Oper varchar(30),        --操作人
  @Msg varchar(255) output  --错误信息
)
as
begin
  declare
    @Stat int,
    @Ret  int
  select @Stat = STAT from VOUCHERBCKSTGRCV(nolock) where NUM = @NUM
  if @Stat <> 0
  begin
    set @Msg = '后台赠券发放单(' + @Num + ')不是未审核状态，不允许删除!';
    return(1);
  end

  exec @Ret = VOUCHERBCKSTGRCV_DOREMOVE @num, @Msg output
  if @Ret <> 0 return(@Ret)
  exec VOUCHERBCKSTGRCV_ADD_LOG @Num, 0, '删除', @Oper;
  return(0)
end
GO
