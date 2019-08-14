SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[Recalccstdrpti]
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
    @cstgid int,
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

  if (select BEGINDATE from MONTHSETTLE where NO = @settleno) > @begindate
  begin
    raiserror('开始时间和结束时间不在同一期内', 16, 1)
    return
  end

  if (select ENDDATE from MONTHSETTLE where NO = @settleno) < @enddate
  begin
    raiserror('开始时间和结束时间不在同一期内', 16, 1)
    return
  end
  
  --if (select count(distinct NO) from monthsettle where begindate between @begindate and @enddate)
  --	> 1 
  --begin
  --  raiserror('开始时间和结束时间不在同一期内', 16, 1)
  --  return
  --end

  --if (select convert(char(10), begindate, 102) from monthsettle
  --	where NO = @settleno) > convert(char(10), @begindate, 102) 
  --begin
  --  raiserror('所选日期不在同一期内', 16, 1)
  --  return
  --end

  --if (select convert(char(10), enddate, 102) from monthsettle
  --	where NO = @settleno) < convert(char(10), @enddate, 102) 
  --begin
  --  raiserror('所选日期不在同一期内', 16, 1)
  --  return
  --end
  --if @enddate > (select max(adate) from cstdrpt)
  --begin
  --  raiserror('end date is later than the lastest available date', 16, 1)
  --  return
  --end
  --if @begindate < (select min(adate) from cstdrpt)
  --begin
  --  raiserror('begin date is earlier than the first available date', 16, 1)
  --  return
  --end

  --if @settleno <> (select no from monthsettle where @begindate between begindate and enddate)
  --begin
  --  raiserror('begin date is not in the given month settle', 16, 1)
  --  return
  --end
  --if @settleno <> (select no from monthsettle where @enddate between begindate and enddate)
  --begin
  --  raiserror('end date is not in the given month settle', 16, 1)
  --  return
  --end
  
  if @store is null select @store = usergid from system
  
  delete from cstdrpti where asettleno = @settleno
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

    select @date, @settleno, @old_date, @old_settleno

    if not exists (
    select * from CSTDRPTI
    where ASTORE = @store and ASETTLENO = @old_settleno and ADATE = @old_date )
    begin
      insert into CSTDRPTI(ASTORE, ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH)
	select @store, @old_settleno, @old_date, BGDGID, BCSTGID, BWRH
	from CSTDRPT
	where ASTORE = @store and ASETTLENO = @old_settleno
	and ADATE = @old_date
    end

    insert into CSTDRPTI (ASTORE, ASETTLENO, ADATE, BCSTGID, BWRH, BGDGID,
      CQ1, CQ2, CQ3, CT1, CT2, CT3, CT4)
    select @store, @settleno, @date, C.BCSTGID, C.BWRH, C.BGDGID,
      CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0), CQ3 + ISNULL(DQ3,0),
      CT1 + ISNULL(DT1,0), CT2 + ISNULL(DT2,0), CT3 + ISNULL(DT3,0),
      CT4 + ISNULL(DT3,0) - ISNULL(DT1,0)
    from CSTDRPTI C, CSTDRPT D
    where C.ASETTLENO = @old_settleno
    and C.ADATE = @old_date
    and D.ASETTLENO = @old_settleno
    and D.ADATE = @old_date
    and C.BGDGID *= D.BGDGID
    and C.BCSTGID *= D.BCSTGID
    and C.BWRH *= D.BWRH
    and C.ASTORE = @store
    and D.ASTORE = @store

    --//月结转后, 日报期初值清零, CT4除外
    if convert(char,@date,102) =
	(select convert(char,begindate,102)
	    from monthsettle where no = @settleno)
    begin
	update CSTDRPTI set CQ1 = 0, CQ2 = 0, CQ3 = 0, CT1 = 0, CT2 = 0, 
		CT3 = 0
	where ASTORE = @store and ASETTLENO = @settleno and ADATE = @date
    end
    declare c cursor for
      select BGDGID, BCSTGID, BWRH from CSTDRPT
      where astore = @store and asettleno = @settleno and adate = @date
    open c
    fetch next from c into @gdgid, @cstgid, @wrh
    while @@fetch_status = 0
    begin
      if not exists (
      select * from cstdrpti
      where astore = @store and asettleno = @settleno and adate = @date
      and bgdgid = @gdgid and bwrh = @wrh and bcstgid = @cstgid)
	insert into CSTDRPTI(ASTORE, ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH)
	values (@store, @settleno, @date, @gdgid, @cstgid, @wrh)
      fetch next from c into @gdgid, @cstgid, @wrh
    end
    close c
    deallocate c


    select @date = dateadd(day, 1, @date)
  end
end

GO
