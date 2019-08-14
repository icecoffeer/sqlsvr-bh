SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETLENDUPD]
(
  @num varchar(14),
  @Sign int --符号，1：审核时增加数量，-1：作废时减少数量
) as
begin
  declare
    @gdgid int,
    @StoreGid int,
    @agmnum varchar(14),
    @agmline int,
    @start DateTime,
    @finish DateTime,
    @qty decimal(24, 4),
    @amt decimal(24, 4),
    @date DateTime,
    @days int,
    @sqty decimal(24, 4),
    @samt decimal(24, 4),
    @rqty decimal(24, 4),
    @ramt decimal(24, 4)
  declare c_dtl cursor for
    select d.GDGID, d.STOREGID, d.AGMNUM, ISNULL(d.AGMLINE, 0) AGMLINE, m.START, m.FINISH, d.RQTY, d.RAMT from PRMOFFSETDTLDTL D(nolock), PRMOFFSETDTL m
    where m.num = @num and d.num = m.num and d.line = m.line
  open c_dtl;
  fetch next from c_dtl into @gdgid, @StoreGid, @agmnum, @agmline, @start, @finish, @qty, @amt
  while @@fetch_status = 0
  begin
    if @sign = 1
      exec PRMOFFSETLENDUPDSG @gdgid, @StoreGid, @agmnum, @agmline, @start, @finish, @qty, @amt
    else
      exec PRMOFFSETLENDUPDSGBAL @gdgid, @StoreGid, @agmnum, @agmline, @start, @finish, @qty, @amt
    fetch next from c_dtl into @gdgid, @StoreGid, @agmnum, @agmline, @start, @finish, @qty, @amt
  end
  close c_dtl
  deallocate c_dtl
  exec UPDOFFSETED @num
end
GO
