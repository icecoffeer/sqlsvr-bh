SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Recalcvdrdrpti]
  @settleno int,
  @begindate datetime,
  @enddate datetime,
  @store int = null
as
begin
  declare
    @old_date datetime,
    @old_settleno int,
    @date datetime,
    @gdgid int,
    @vdrgid int,
    @wrh int

  if not exists(select * from MONTHSETTLE where NO = @settleno)
  begin
	raiserror('所选结转期不存在', 16, 1)
	return
  end

  if @begindate > @enddate
  begin
    raiserror('开始日期大于结束日期', 16, 1)
    return
  end

  if convert(char(10), @enddate, 102) > convert(char(10), getdate(), 102)
  begin
    raiserror('结束日期不能晚于今天', 16, 1)
    return
  end

  if (select convert(char(10), BEGINDATE, 102)
	from MONTHSETTLE where NO = @settleno) >
	convert(char(10), @begindate, 102)
  begin
    raiserror('开始时间和结束时间不在同一期内', 16, 1)
    return
  end

  if (select convert(char(10), ENDDATE, 102)
	 from MONTHSETTLE where NO = @settleno) <
	 convert(char(10), @enddate, 102)
  begin
    raiserror('开始时间和结束时间不在同一期内', 16, 1)
    return
  end

  if @store is null select @store = usergid from system

  delete from vdrdrpti where asettleno = @settleno
  and adate between @begindate and @enddate and astore = @store

  select @date = @begindate
  while @date <= @enddate
  begin
    if convert(char,@date,102) =
    (select convert(char,begindate,102)
    from monthsettle where no = @settleno)
      select
	@old_date = @date,
	@old_settleno = @settleno - 1
    else
      select
	@old_date = dateadd(day, -1, @date),
	@old_settleno = @settleno

    --select @date, @settleno, @old_date, @old_settleno

    if not exists (
    select * from VDRDRPTI
    where ASTORE = @store and ASETTLENO = @old_settleno and ADATE = @old_date )
    begin
      insert into VDRDRPTI(ASTORE, ASETTLENO, ADATE, BGDGID, BVDRGID, BWRH)
	select @store, @old_settleno, @old_date, BGDGID, BVDRGID, BWRH
	from VDRDRPT
	where ASTORE = @store and ASETTLENO = @old_settleno
	and ADATE = @old_date
    end


    insert into VDRDRPTI (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID,
      CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
      CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, ci2)
    select @store, @settleno, @date, C.BVDRGID, C.BWRH, C.BGDGID,
      CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0), CQ3 + ISNULL(DQ3,0),
      CQ4 + ISNULL(DQ4,0), CQ5 + ISNULL(DQ5,0), CQ6 + ISNULL(DQ6,0),
      CT1 + ISNULL(DT1,0), CT2 + ISNULL(DT2,0), CT3 + ISNULL(DT3,0),
      CT4 + ISNULL(DT4,0), CT5 + ISNULL(DT5,0), CT6 + ISNULL(DT6,0),
      CT7 + ISNULL(DT7,0), CT8 + ISNULL(DT3,0) - ISNULL(DT4,0) + ISNULL(DT6,0),
      ci2 + isnull(di2,0)
    from VDRDRPTI C, VDRDRPT D
    where C.ASETTLENO = @old_settleno
    and C.ADATE = @old_date
    and D.ASETTLENO = @old_settleno
    and D.ADATE = @old_date
    and C.BGDGID *= D.BGDGID
    and C.BVDRGID *= D.BVDRGID
    and C.BWRH *= D.BWRH
    and C.ASTORE = @store
    and D.ASTORE = @store

    --//月结转后, 日报期初值清零, CT8除外
    if convert(char,@date,102) =
	(select convert(char,begindate,102)
	    from monthsettle where no = @settleno)
    begin
	update VDRDRPTI set CQ1 = 0, CQ2 = 0, CQ3 = 0, CQ4 = 0, CQ5 = 0, CQ6 = 0,
		CT1 = 0, CT2 = 0, CT3 = 0, CT4 = 0, CT5 = 0, CT6 = 0, CT7 = 0,
                ci2 = 0
	where ASTORE = @store and ASETTLENO = @settleno and ADATE = @date
    end

    declare c cursor for
      select BGDGID, BVDRGID, BWRH from VDRDRPT
      where astore = @store and asettleno = @settleno and adate = @date
    open c
    fetch next from c into @gdgid, @vdrgid, @wrh
    while @@fetch_status = 0
    begin
      if not exists (
      select * from vdrdrpti
      where astore = @store and asettleno = @settleno and adate = @date
      and bgdgid = @gdgid and bwrh = @wrh and bvdrgid = @vdrgid)
	insert into VDRDRPTI(ASTORE, ASETTLENO, ADATE, BGDGID, BVDRGID, BWRH)
	values (@store, @settleno, @date, @gdgid, @vdrgid, @wrh)
      fetch next from c into @gdgid, @vdrgid, @wrh
    end
    close c
    deallocate c

    select @date = dateadd(day, 1, @date)
  end
end
GO
