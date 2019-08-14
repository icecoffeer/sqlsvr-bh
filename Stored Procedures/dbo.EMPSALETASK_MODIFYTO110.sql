SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPSALETASK_MODIFYTO110]
(
  @num      varchar(14),
  @oper     varchar(30),
  @tostat   int,
  @msg  varchar(255) output
)
as
begin
  declare
    @stat int
  select @stat = stat from EMPSALETASK(nolock) where num = @num
  if @stat <> 100
  begin
    set @msg = '目标状态不对' + ltrim(str(@stat))
    return 1
  end
  update EMPSALETASK set STAT = 110, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
    where num = @num
  exec EMPSALETASK_ADD_LOG @Num, @ToStat, '作废', @Oper;
  return 0
end
GO
