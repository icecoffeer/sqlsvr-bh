SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PosProc_ProcTwiceBuy](
  @posno varchar(10),
  @flowno varchar(12),
  @msg varchar(255) output
)
as
begin
  /*卡号*/
  declare @cardcode varchar(20)
  select @cardcode = CARDCODE from BUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  if @cardcode is null
  begin
    return 0
  end

  /*预售活动单号、活动开始结束日期。出于对效率的追求，没有使用游标来遍
    历ADVANCESALES，项目人员确认同一时间只有一个生效的预售单号*/
  declare @asnum int
  declare @asstart datetime
  declare @asfinish datetime
  select top 1 @asnum = ASNUM, @asstart = ASSTART, @asfinish = ASFINISH
    from ADVANCESALES(nolock)
    where TSSTART <= getdate() and TSFINISH > getdate() - 1
    and NEEDTWICEBUY = 1 --zhujied
    order by ASSTART desc
  if @@rowcount = 0
  begin
    return 0
  end

  /*检查同一卡号是否在预售期间消费，有则记录在TWICEBUY*/
  declare @prebuyposno varchar(10)
  declare @prebuyflowno varchar(12)
  declare c_prebuy1 cursor for
    select POSNO, FLOWNO from PREBUY1(nolock)
    where CARDCODE = @cardcode
    and FILDATE >= @asstart and FILDATE < @asfinish + 1
    and ASNUM = @asnum --zhujied
  open c_prebuy1
  fetch next from c_prebuy1 into @prebuyposno, @prebuyflowno
  while @@fetch_status = 0
  begin
    if not exists(select * from TWICEBUY(nolock)
      where PREBUYFLOWNO = @prebuyflowno
      and PREBUYPOSNO = @prebuyposno)
    begin
      insert into TWICEBUY(PREBUYFLOWNO, PREBUYPOSNO, BUYFLOWNO, BUYPOSNO, RECORDTIME)
        select @prebuyflowno, @prebuyposno, @flowno, @posno, getdate()
    end

    fetch next from c_prebuy1 into @prebuyposno, @prebuyflowno
  end
  close c_prebuy1
  deallocate c_prebuy1

  return 0
end
GO
