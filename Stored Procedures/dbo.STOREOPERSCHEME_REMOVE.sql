SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[STOREOPERSCHEME_REMOVE]
(
    @Num varchar(14),         --单号
    @Msg varchar(255) output  --错误信息
)
as
begin
  declare
    @Stat int,
    @Ret int

  select @Stat = STAT from STOREOPERSCHEME(nolock) where NUM = @Num
  if @Stat <> 0
  begin
  	set @Msg = '门店经营方案单据(' + @Num + ')不是未审核状态，不允许删除!'
    return(1)
  end

  exec @ret = STOREOPERSCHEME_DOREMOVE @Num, @Msg output
  IF @RET <> 0 RETURN(@RET)
  delete from STOREOPERSCHEMELOG where NUM = @Num

  return(0)
end
GO
