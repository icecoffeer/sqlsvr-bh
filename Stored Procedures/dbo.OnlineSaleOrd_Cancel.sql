SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OnlineSaleOrd_Cancel](
  @Num char(14),
  @Cls char(10),
  @Oper Varchar(30),
  @ToStat int,
  @Msg varchar(255) output
)
as
begin
  declare
    @Stat smallint,
    @OperGid int

  --状态校验
  select @Stat = STAT from OnlineSaleOrd(nolock)
    where NUM = @Num
  if @Stat <> 3700
  begin
    set @Msg = '不是待取货的单据，不能取消'
    return(1)
  end
  --获取员工Gid
  Select @OperGid = Gid From Employee
    Where Code = SUBSTRING(@Oper, 1, CHARINDEX('[', @Oper) -1)

  --更新汇总信息
  update OnlineSaleOrd set
    STAT = @ToStat,
    LSTUPDTIME = getdate(),
    LSTUPDOPER = @OperGid
  where NUM = @Num

  --记录日志
  exec OnlineSaleOrd_AddLog @Num, @ToStat, @OperGid, '取消'

  return(0)
end
GO
