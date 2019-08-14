SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OnlineSaleOrd_Remove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  declare @return_status smallint
  declare @Stat smallint

  --状态校验
  select @Stat = STAT from OnlineSaleOrd(nolock)
    where NUM = @Num
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能删除'
    return(1)
  end

  --删除汇总和明细数据
  exec @return_status = OnlineSaleOrd_DoRemove @Num, @Msg output
  if @return_status <> 0
    return(@return_status)
  --删除日志
  delete from OnlineSaleOrdLog where NUM = @Num

  return(0)
end
GO
