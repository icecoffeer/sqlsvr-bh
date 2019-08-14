SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[POLYPAYRATEPRM_REMOVE]
(
    @Num varchar(14),         --单号
    @Cls varchar(10),         --类型
    @Msg varchar(255) output  --错误信息
)
as
begin
  declare
    @Stat int,
    @Ret int

  select @Stat = STAT from POLYPAYRATEPRM(nolock) where NUM = @NUM and CLS = @Cls
  if @Stat <> 0
  begin
  	if @Cls = '批量联销率'
      set @Msg = @cls + '单(' + @Num + ')不是未审核状态，不允许删除!'
    else if @Cls = '商品折扣'
      set @Msg = '商品折扣联销率协议(' + @Num + ')不是未审核状态，不允许删除!'
    return(1);
  end

  exec @ret = POLYPAYRATEPRM_DOREMOVE @num, @cls, @msg output
  IF @RET <> 0 RETURN(@RET)
  delete from POLYPAYRATEPRMLOG where NUM = @Num and CLS = @Cls

  return(0)
end
GO
