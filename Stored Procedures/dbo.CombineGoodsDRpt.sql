SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将日报表中@store, @settleno, 的商品@oldgdgid, 改成@gdgid
*/
create procedure [dbo].[CombineGoodsDRpt]
  @store int,
  @settleno int,
  @oldgdgid int,  --被合并商品
  @gdgid int      --并入商品
as
begin
  if @oldgdgid = @gdgid
          return(0)

  declare
    @ADATE datetime, @vdrgid int, @cstgid int, @wrh int,
    @CQ money, @CT money, @FQ money, @FT money,
    @CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money,
    @CT1 money, @CT2 money, @CT3 money, @CT4 money,
    @CI1 money, @CI2 money, @CI3 money, @CI4 money,
    @CR1 money, @CR2 money, @CR3 money, @CR4 money,
    @DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money, @DQ5 money,
    @DQ6 money, @DQ7 money,
    @DT1 money, @DT2 money, @DT3 money, @DT4 money, @DT5 money,
    @DT6 money, @DT7 money, @DT91 money, @DT92 money,
    @DI1 money, @DI2 money, @DI3 money, @DI4 money, @DI5 money,
    @DI6 money, @DI7 money,
    @DR1 money, @DR2 money, @DR3 money, @DR4 money, @DR5 money,
    @DR6 money, @DR7 money

  /* INDRPT */
  declare c_rpt cursor for
    select ADATE, BVDRGID, BWRH,
      DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
      DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
    from INDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @oldgdgid
  open c_rpt
  fetch next from c_rpt into
    @ADATE, @vdrgid, @wrh,
    @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
    @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  while @@fetch_status = 0
  begin
    if exists (
      select * from INDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh
      )
    begin
      update INDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4,
      DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh
      delete from INDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh
    end
    else
    begin
      update INDRPT set
      BGDGID = @gdgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh
    end
    fetch next from c_rpt into
      @ADATE, @vdrgid, @wrh,
      @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
      @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  end
  close c_rpt
  deallocate c_rpt

  /*INVDRPT*/
  declare c_rpt cursor for
    select ADATE, BWRH, CQ, CT, FQ, FT
    from INVDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @oldgdgid
  open c_rpt
  fetch next from c_rpt into @ADATE, @wrh, @CQ, @CT, @FQ, @FT
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
        and BGDGID = @oldgdgid and BWRH = @wrh
    end
    else
    begin
      update INVDRPT set
      BGDGID = @gdgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BWRH = @wrh
    end
    fetch next from c_rpt into @ADATE, @wrh, @CQ, @CT, @FQ, @FT
  end
  close c_rpt
  deallocate c_rpt

  /* INVCHGDRPT */
  declare c_rpt cursor for
    select ADATE, BWRH,
      DQ1 , DQ2 , DQ4 , DQ5 ,
      DI1 , DI2 , DI3 , DI4 , DI5 ,
      DR1 , DR2 , DR3 , DR4 , DR5
    from INVCHGDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @oldgdgid
  open c_rpt
  fetch next from c_rpt into
    @ADATE, @wrh,
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
        and BGDGID = @oldgdgid and BWRH = @wrh
    end
    else
    begin
      update INVCHGDRPT set
      BGDGID = @gdgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BWRH = @wrh
    end
    fetch next from c_rpt into
      @ADATE, @wrh,
      @DQ1 , @DQ2 , @DQ4 , @DQ5 ,
      @DI1 , @DI2 , @DI3 , @DI4 , @DI5 ,
      @DR1 , @DR2 , @DR3 , @DR4 , @DR5
  end
  close c_rpt
  deallocate c_rpt

  /* OUTDRPT */
  declare c_rpt cursor for
    select ADATE, BCSTGID, BWRH,
      DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,
      DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,
      DI1, DI2, DI3, DI4, DI5, DI6, DI7,
      DR1, DR2, DR3, DR4, DR5, DR6, DR7
    from OUTDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @oldgdgid
  open c_rpt
  fetch next from c_rpt into
    @ADATE, @cstgid, @wrh,
    @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
    @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
    @DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
    @DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
  while @@fetch_status = 0
  begin
    if exists ( select * from OUTDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
    begin
      update OUTDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4, DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6, DQ7 = DQ7 + @DQ7,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4, DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
      DT91 = DT91 + @DT91, DT92 = DT92 + @DT92,
      DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4, DI5 = DI5 + @DI5, DI6 = DI6 + @DI6, DI7 = DI7 + @DI7,
      DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4, DR5 = DR5 + @DR5, DR6 = DR6 + @DR6, DR7 = DR7 + @DR7,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
      delete from OUTDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
    end
    else
    begin
      update OUTDRPT set
      BGDGID = @gdgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
    end
    fetch next from c_rpt into
      @ADATE, @cstgid, @wrh,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6, @DQ7,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DT91, @DT92,
      @DI1, @DI2, @DI3, @DI4, @DI5, @DI6, @DI7,
      @DR1, @DR2, @DR3, @DR4, @DR5, @DR6, @DR7
  end
  close c_rpt
  deallocate c_rpt

  /* CSTDRPT */
  declare c_rpt cursor for
    select ADATE, BCSTGID, BWRH, DQ1, DQ2, DQ3, DT1, DT2, DT3
    from CSTDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @oldgdgid
  open c_rpt
  fetch next from c_rpt into
    @ADATE, @cstgid, @wrh, @DQ1, @DQ2, @DQ3, @DT1, @DT2, @DT3
  while @@fetch_status = 0
  begin
    if exists ( select * from CSTDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh)
    begin
      update CSTDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BCSTGID = @cstgid and BWRH = @wrh
      delete from CSTDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
    end
    else
    begin
      update CSTDRPT set BGDGID = @gdgid
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BCSTGID = @cstgid and BWRH = @wrh
    end
    fetch next from c_rpt into
      @ADATE, @cstgid, @wrh, @DQ1, @DQ2, @DQ3,
      @DT1, @DT2, @DT3
  end
  close c_rpt
  deallocate c_rpt

  /* VDRDRPT */
  declare c_rpt cursor for
    select ADATE, BVDRGID, BWRH,
      DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
      DT1, DT2, DT3, DT4, DT5, DT6, DT7,
      DI2
    from VDRDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @oldgdgid
  open c_rpt
  fetch next from c_rpt into
    @ADATE, @vdrgid, @wrh,
    @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
    @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7,
    @DI2
  while @@fetch_status = 0
  begin
    if exists (select * from VDRDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh)
    begin
      update VDRDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
      DI2 = DI2 + @DI2,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @gdgid and BVDRGID = @vdrgid and BWRH = @wrh
      delete from VDRDRPT
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh
    end
    else
    begin
      update VDRDRPT set
      BGDGID = @gdgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BGDGID = @oldgdgid and BVDRGID = @vdrgid and BWRH = @wrh
    end
    fetch next from c_rpt into
      @ADATE, @vdrgid, @wrh,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7,
      @DI2
  end
  close c_rpt
  deallocate c_rpt

        --execute CombineGoodsBill @store, @settleno, @oldgdgid, @gdgid
end
GO
