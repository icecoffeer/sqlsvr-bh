SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将INXRPT中@store, @settleno, @vdrgid, @gdgid的WRH从@oldwrh改成@wrh
*/
create procedure [dbo].[GdChgWrhDRpt]
  @store int,
  @settleno int,
  @gdgid int,
  @oldwrh int,
  @wrh int
as
begin
  if @oldwrh = @wrh
          return(0)

  declare
    @ADATE datetime, @vdrgid int, @cstgid int,
    @CQ money, @CT money, @FQ money, @FT money,
    @DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money,
    @DQ5 money, @DQ6 money, @DQ7 money,
    @DT1 money, @DT2 money, @DT3 money, @DT4 money,
    @DT5 money, @DT6 money, @DT7 money, @DT91 money, @DT92 money,
    @DI1 money, @DI2 money, @DI3 money, @DI4 money,
    @DI5 money, @DI6 money, @DI7 money,
    @DR1 money, @DR2 money, @DR3 money, @DR4 money,
    @DR5 money, @DR6 money, @DR7 money

  /* INDRPT */
  declare c_indrpt cursor for
    select ADATE, BVDRGID,
      DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
      DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
    from INDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BWRH = @oldwrh and BGDGID = @gdgid
  open c_indrpt
  fetch next from c_indrpt into
    @ADATE, @vdrgid,
    @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
    @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  while @@fetch_status = 0
  begin
    if exists (
      select * from INDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      )
    begin
      update INDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4,
      DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      delete from INDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
    end
    else
    begin
      update INDRPT set
      BWRH = @wrh,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
    end
    fetch next from c_indrpt into
      @ADATE, @vdrgid,
      @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
      @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  end
  close c_indrpt
  deallocate c_indrpt

  /* INVDRPT */
  declare c_invdrpt cursor for
    select ADATE, CQ, CT, FQ, FT
    from INVDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @gdgid and BWRH = @oldwrh
  open c_invdrpt
  fetch next from c_invdrpt into @ADATE, @CQ, @CT, @FQ, @FT
  while @@fetch_status = 0
  begin
    if exists ( select * from INVDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @wrh)
    begin
      update INVDRPT set
      CQ = CQ + @CQ, CT = CT + @CT, FQ = FQ + @FQ, FT = FT + @FT,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @wrh
      delete from INVDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    else
    begin
      update INVDRPT set
      BWRH = @wrh,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    fetch next from c_invdrpt into @ADATE, @CQ, @CT, @FQ, @FT
  end
  close c_invdrpt
  deallocate c_invdrpt

  /* INVCHGDRPT */
  declare c cursor for
    select ADATE,
      DQ1 , DQ2 , DQ4 , DQ5 ,
      DI1 , DI2 , DI3 , DI4 , DI5 ,
      DR1 , DR2 , DR3 , DR4 , DR5
    from INVCHGDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @gdgid and BWRH = @oldwrh
  open c
  fetch next from c into
    @ADATE ,
    @DQ1 , @DQ2 , @DQ4 , @DQ5 ,
    @DI1 , @DI2 , @DI3 , @DI4 , @DI5 ,
    @DR1 , @DR2 , @DR3 , @DR4 , @DR5
  while @@fetch_status = 0
  begin
    if exists ( select * from INVCHGDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @wrh)
    begin
      update INVCHGDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5,
      DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5,
      DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @wrh
      delete from INVCHGDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    else
    begin
      update INVCHGDRPT set
      BWRH = @wrh,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    fetch next from c into
      @ADATE ,
      @DQ1 , @DQ2 , @DQ4 , @DQ5 ,
      @DI1 , @DI2 , @DI3 , @DI4 , @DI5 ,
      @DR1 , @DR2 , @DR3 , @DR4 , @DR5
  end
  close c
  deallocate c

  /* OUTDRPT */
  declare c cursor for
    select ADATE, BCSTGID,
      DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
      DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
      DI1, DI2, DI3, DI4, DI5, DI6, DI7,
      DR1, DR2, DR3, DR4, DR5, DR6, DR7
    from OUTDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @gdgid and BWRH = @oldwrh
  open c
  fetch next from c into
    @ADATE, @cstgid,
    @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
    @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
    @DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
    @DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
  while @@fetch_status = 0
  begin
    if exists ( select * from OUTDRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @wrh)
    begin
      update OUTDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6, DQ7 = DQ7 + @DQ7,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4, DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
      DT91 = DT91 + @DT91, DT92 = DT92 + @DT92,
      DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5, DI6 = DI6 + @DI6, DI7 = DI7 + @DI7,
      DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5, DR6 = DR6 + @DR6, DR7 = DR7 + @DR7,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @wrh
      delete from OUTDRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    else
    begin
      update OUTDRPT set
      BWRH = @wrh,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    fetch next from c into
      @ADATE, @cstgid,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
      @DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
      @DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
  end
  close c
  deallocate c


  /* CSTDRPT */
  declare c cursor for
    select ADATE, BCSTGID, DQ1, DQ2, DQ3, DT1, DT2, DT3
    from CSTDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @gdgid and BWRH = @oldwrh
  open c
  fetch next from c into
    @ADATE, @cstgid, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
  while @@fetch_status = 0
  begin
    if exists ( select * from CSTDRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @wrh)
    begin
      update CSTDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @wrh
      delete from CSTDRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    else
    begin
      update CSTDRPT set BWRH = @wrh
      where ASTORE = @store and ASETTLENO = @settleno
        and ADATE = @ADATE and BCSTGID = @cstgid
        and BGDGID = @gdgid and BWRH = @oldwrh
    end
    fetch next from c into
      @ADATE, @cstgid, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
  end
  close c
  deallocate c

  /*为了防止配货中心'合并供应商', '合并仓位', '修正供应商', '修正仓位'后
	再接收门店的VDRXRPT出问题, 增加三个表
	CREATE TABLE VDRDRPTLOG ( ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID )
	CREATE TABLE VDRMRPTLOG ( ASTORE, ASETTLENO, BVDRGID, BWRH, BGDGID )
	CREATE TABLE VDRYRPTLOG ( ASTORE, ASETTLENO, BVDRGID, BWRH, BGDGID )
	这三个表中保留两个结转期的数据,
	将表中ASTORE=@store and ASETTLENO=@settleno and ADATE=@adate and BVDRGID=@vdrgid and @BGDGID=@gdgid
	的记录的BWRH改为@wrh
	修改于1999.06.21*/

  /* VDRDRPT */
  declare c_vdrdrpt cursor for
    select ADATE, BVDRGID,
      DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
      DT1, DT2, DT3, DT4, DT5, DT6, DT7, DI2
    from VDRDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BWRH = @oldwrh and BGDGID = @gdgid
  open c_vdrdrpt
  fetch next from c_vdrdrpt into
    @ADATE, @vdrgid,
    @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
    @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
  while @@fetch_status = 0
  begin
    if exists (select * from VDRDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid)
    begin
      update VDRDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
      DI2 = DI2 + @DI2,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      delete from VDRDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
    end
    else
    begin
      update VDRDRPT set
      BWRH = @wrh,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid
    end

    update VDRDRPTLOG set BWRH = @wrh
    where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
      and BWRH = @oldwrh and BGDGID = @gdgid and BVDRGID = @vdrgid

    fetch next from c_vdrdrpt into
      @ADATE, @vdrgid,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
  end
  close c_vdrdrpt
  deallocate c_vdrdrpt
end
GO
