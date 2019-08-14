SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OnlineSaleBckOrd_On_Modify_To_3200](
  @Num char(14),
  @ToStat smallint,
  @Oper int,
  @Msg varchar(255) output
)
as
begin
  declare @Stat smallint

  --状态校验
  select @Stat = STAT from OnlineSaleBckOrd(nolock)
    where NUM = @Num
  if @Stat <> 3100
  begin
    set @Msg = '不是待退货的单据，不能进行确认'
    return(1)
  end

  --更新汇总信息
  update OnlineSaleBckOrd set
    Stat = @ToStat,
    LSTUPDTIME = getdate(),
    LSTUPDOPER = @Oper,
    SALEDATE = getdate()
  where NUM = @Num

  --记录日志
  exec OnlineSaleBckOrd_AddLog @Num, @ToStat, @Oper, '确认'

  return(0)
end
GO
