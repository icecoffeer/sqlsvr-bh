SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AppUpdVdrDrpt]
  @store int,
  @settleno int,   -- 当时的
  @date datetime,  -- 当时的, 这一天的VDRDRPT发生了变化
  @vdrgid int,
  @wrh int,
  @gdgid int,
  --以下是变化值
  @dq1 money, @dq2 money, @dq3 money, @dq4 money, @dq5 money, @dq6 money,
  @dt1 money, @dt2 money, @dt3 money, @dt4 money, @dt5 money, @dt6 money, @dt7 money,
  @di2 money
as
begin
  declare @yno int, @emsettleno int, @t_yno int, @t_settleno int, @t_date datetime
  declare @ct8 money
  declare @cur_date datetime, @cur_settleno int, @cur_yno int, @t int
  declare @tempyearno int
  select @cur_date = convert(datetime, convert(char, getdate(), 102))
  select @cur_settleno = max(no) from monthsettle
  select @cur_yno = max(no) from yearsettle
  select @yno = yno from v_ym where mno = @settleno
  select @emsettleno = max(mno) from v_ym where yno = @yno
  /* VDRDRPT */
  if not exists (
    select * from VDRDRPT(nolock)
    where astore = @store and asettleno = @settleno and adate = @date
    and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
  )
  begin
    insert into VDRDRPT (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID)
    values (@store, @settleno, @date, @vdrgid, @wrh, @gdgid)
  end
  update VDRDRPT set
    dq1 = dq1 + isnull(@dq1, 0), dq2 = dq2 + isnull(@dq2, 0),
    dq3 = dq3 + isnull(@dq3, 0), dq4 = dq4 + isnull(@dq4, 0),
    dq5 = dq5 + isnull(@dq5, 0), dq6 = dq6 + isnull(@dq6, 0),
    dt1 = convert( dec(20,2), dt1 + isnull(@dt1, 0) ),
    dt2 = convert( dec(20,2), dt2 + isnull(@dt2, 0) ),
    dt3 = convert( dec(20,2), dt3 + isnull(@dt3, 0) ),
    dt4 = convert( dec(20,2), dt4 + isnull(@dt4, 0) ),
    dt5 = convert( dec(20,2), dt5 + isnull(@dt5, 0) ),
    dt6 = convert( dec(20,2), dt6 + isnull(@dt6, 0) ),
    DT7 = convert( dec(20,2), DT7 + isnull(@dt7, 0) ),
    di2 = convert( dec(20,2), di2 + isnull(@di2, 0) ),
    LSTUPDTIME = getdate()
    where astore = @store and asettleno = @settleno and adate = @date
    and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
  /* VDRDRPTI */
  select @t_settleno = @settleno, @t_date = dateadd(day,1,@date)

  while @t_settleno <= @cur_settleno and @t_date <= @cur_date
  begin
    if not exists (
      select * from VDRDRPTI(nolock)
      where astore = @store and asettleno = @t_settleno and adate = @t_date
      and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
    )
    begin
      insert into VDRDRPTI (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID)
      values (@store, @t_settleno, @t_date, @vdrgid, @wrh, @gdgid)
    end
    if @t_settleno <> @settleno
       update VDRDRPTI set
            CT8 = convert( dec(20,2), CT8 + ISNULL(@DT3,0) - ISNULL(@DT4,0) + ISNULL(@DT6,0) )
      where astore = @store and asettleno = @t_settleno
        and adate = @t_date
        and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
    else
       update VDRDRPTI set
            CQ1 = CQ1 + ISNULL(@DQ1,0), CQ2 = CQ2 + ISNULL(@DQ2,0),
            CQ3 = CQ3 + ISNULL(@DQ3,0), CQ4 = CQ4 + ISNULL(@DQ4,0),
            CQ5 = CQ5 + ISNULL(@DQ5,0), CQ6 = CQ6 + ISNULL(@DQ6,0),
            CT1 = convert( dec(20,2), CT1 + ISNULL(@DT1,0) ),
            CT2 = convert( dec(20,2), CT2 + ISNULL(@DT2,0) ),
            CT3 = convert( dec(20,2), CT3 + ISNULL(@DT3,0) ),
            CT4 = convert( dec(20,2), CT4 + ISNULL(@DT4,0) ),
            CT5 = convert( dec(20,2), CT5 + ISNULL(@DT5,0) ),
            CT6 = convert( dec(20,2), CT6 + ISNULL(@DT6,0) ),
            CT7 = convert( dec(20,2), CT7 + ISNULL(@DT7,0) ),
            CT8 = convert( dec(20,2), CT8 + ISNULL(@DT3,0) - ISNULL(@DT4,0) + ISNULL(@DT6,0) ),
            CI2 = convert( dec(20,2), CI2 + ISNULL(@DI2,0) )
      where astore = @store and asettleno = @t_settleno
        and adate = @t_date
        and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid

    /* next date: 结转这一天应有2条 */
    select @t =
    (select no from monthsettle(nolock) where convert(char,begindate,102) = convert(char,@t_date,102))
    if @t is not null
    begin
      if @t <> @t_settleno select @t_settleno = @t_settleno + 1
      else select @t_date = dateadd(day, 1, @t_date)
    end
    else select @t_date = dateadd(day, 1, @t_date)
  end

  /* VDRMRPT */
  select @t_settleno = @settleno
  while @t_settleno <= @cur_settleno
  begin
    if not exists (
      select * from VDRMRPT(nolock)
      where astore = @store and asettleno = @t_settleno
      and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
    )
    begin
      insert into VDRMRPT (ASTORE, ASETTLENO, BVDRGID, BWRH, BGDGID)
      values (@store, @t_settleno, @vdrgid, @wrh, @gdgid)
    end
    select @t_settleno = @t_settleno + 1
  end
  update VDRMRPT set
    dq1 = dq1 + isnull(@dq1, 0), dq2 = dq2 + isnull(@dq2, 0),
    dq3 = dq3 + isnull(@dq3, 0), dq4 = dq4 + isnull(@dq4, 0),
    dq5 = dq5 + isnull(@dq5, 0), dq6 = dq6 + isnull(@dq6, 0),
    dt1 = convert( dec(20,2), dt1 + isnull(@dt1, 0) ),
    dt2 = convert( dec(20,2), dt2 + isnull(@dt2, 0) ),
    dt3 = convert( dec(20,2), dt3 + isnull(@dt3, 0) ),
    dt4 = convert( dec(20,2), dt4 + isnull(@dt4, 0) ),
    dt5 = convert( dec(20,2), dt5 + isnull(@dt5, 0) ),
    dt6 = convert( dec(20,2), dt6 + isnull(@dt6, 0) ),
    DT7 = convert( dec(20,2), DT7 + isnull(@dt7, 0) ),
    DI2 = convert( dec(20,2), DI2 + ISNULL(@DI2, 0) )
    where astore = @store and asettleno = @settleno
    and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
  declare @tempmonthno int
  select @tempmonthno = @settleno + 1
  while @tempmonthno <= @cur_settleno
  begin
    if @tempMonthno > @emsettleno
       update VDRMRPT set
          CT8 = convert( dec(20,2), CT8 + ISNULL(@DT3,0) - ISNULL(@DT4,0) + ISNULL(@DT6,0) )
          where astore = @store and asettleno = @tempmonthno
            and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
    else
       update VDRMRPT set
          CQ1 = CQ1 + ISNULL(@DQ1,0), CQ2 = CQ2 + ISNULL(@DQ2,0),
          CQ3 = CQ3 + ISNULL(@DQ3,0), CQ4 = CQ4 + ISNULL(@DQ4,0),
          CQ5 = CQ5 + ISNULL(@DQ5,0), CQ6 = CQ6 + ISNULL(@DQ6,0),
          CT1 = convert( dec(20,2), CT1 + ISNULL(@DT1,0) ),
          CT2 = convert( dec(20,2), CT2 + ISNULL(@DT2,0) ),
          CT3 = convert( dec(20,2), CT3 + ISNULL(@DT3,0) ),
          CT4 = convert( dec(20,2), CT4 + ISNULL(@DT4,0) ),
          CT5 = convert( dec(20,2), CT5 + ISNULL(@DT5,0) ),
          CT6 = convert( dec(20,2), CT6 + ISNULL(@DT6,0) ),
          CT7 = convert( dec(20,2), CT7 + ISNULL(@DT7,0) ),
          CT8 = convert( dec(20,2), CT8 + ISNULL(@DT3,0) - ISNULL(@DT4,0) + ISNULL(@DT6,0) ),
          CI2 = convert( dec(20,2), CI2 + ISNULL(@DI2,0) )
          where astore = @store and asettleno = @tempmonthno
            and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
    select @tempmonthno = @tempmonthno + 1
  end
  /* VDRYRPT */
  select @t_yno = @yno
  while @t_yno <= @cur_yno
  begin
    if not exists (
      select * from VDRYRPT(nolock)
      where astore = @store and asettleno = @t_yno
      and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
    )
    begin
      insert into VDRYRPT (ASTORE, ASETTLENO, BVDRGID, BWRH, BGDGID)
      values (@store, @t_yno, @vdrgid, @wrh, @gdgid)
    end
    select @t_yno = (select min(no) from yearsettle where no > @t_yno)
    if @t_yno is null select @t_yno = @cur_yno + 1
  end
  update VDRYRPT set
    dq1 = dq1 + isnull(@dq1, 0), dq2 = dq2 + isnull(@dq2, 0),
    dq3 = dq3 + isnull(@dq3, 0), dq4 = dq4 + isnull(@dq4, 0),
    dq5 = dq5 + isnull(@dq5, 0), dq6 = dq6 + isnull(@dq6, 0),
    dt1 = convert( dec(20,2), dt1 + isnull(@dt1, 0) ),
    dt2 = convert( dec(20,2), dt2 + isnull(@dt2, 0) ),
    dt3 = convert( dec(20,2), dt3 + isnull(@dt3, 0) ),
    dt4 = convert( dec(20,2), dt4 + isnull(@dt4, 0) ),
    dt5 = convert( dec(20,2), dt5 + isnull(@dt5, 0) ),
    dt6 = convert( dec(20,2), dt6 + isnull(@dt6, 0) ),
    DT7 = convert( dec(20,2), DT7 + isnull(@dt7, 0) ),
    DI2 = convert( dec(20,2), DI2 + ISNULL(@DI2, 0) )
    where astore = @store and asettleno = @yno
    and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
  select @tempyearno = @yno + 1
  while @tempyearno <= @cur_yno
  begin
     update VDRYRPT set
        CQ1 = CQ1 + ISNULL(@DQ1,0), CQ2 = CQ2 + ISNULL(@DQ2,0),
        CQ3 = CQ3 + ISNULL(@DQ3,0), CQ4 = CQ4 + ISNULL(@DQ4,0),
        CQ5 = CQ5 + ISNULL(@DQ5,0), CQ6 = CQ6 + ISNULL(@DQ6,0),
        CT1 = convert( dec(20,2), CT1 + ISNULL(@DT1,0) ),
        CT2 = convert( dec(20,2), CT2 + ISNULL(@DT2,0) ),
        CT3 = convert( dec(20,2), CT3 + ISNULL(@DT3,0) ),
        CT4 = convert( dec(20,2), CT4 + ISNULL(@DT4,0) ),
        CT5 = convert( dec(20,2), CT5 + ISNULL(@DT5,0) ),
        CT6 = convert( dec(20,2), CT6 + ISNULL(@DT6,0) ),
        CT7 = convert( dec(20,2), CT7 + ISNULL(@DT7,0) ),
        CT8 = convert( dec(20,2), CT8 + ISNULL(@DT3,0) - ISNULL(@DT4,0) + ISNULL(@DT6,0) ),
        CI2 = convert( dec(20,2), CI2 + ISNULL(@DI2,0) )
        where astore = @store and asettleno = @tempyearno
          and bwrh = @wrh and bgdgid = @gdgid and bvdrgid = @vdrgid
     select @tempyearno = @tempyearno + 1
  end
end
GO
