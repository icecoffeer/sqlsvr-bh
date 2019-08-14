SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将INXRPT中@store, @settleno, @wrh, @gdgid的供应商从@oldvdrgid改成@vdrgid
*/
create procedure [dbo].[GdChgVdrMRpt]
  @store int,
  @settleno int,
  @gdgid int,
  @oldvdrgid int,
  @vdrgid int
as
begin
  if @oldvdrgid = @vdrgid
          return(0)

  declare @ChgMode int
  exec OptReadInt 214, 'ChgMode', 0, @ChgMode output
  if @ChgMode = 1
  begin
    exec GdChgVdrMRpt_YTZH @store, @settleno, @gdgid, @oldvdrgid, @vdrgid
    return(0)
  end

  declare
    @wrh int,
    @CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money,
    @CQ5 money, @CQ6 money,
    @CT1 money, @CT2 money, @CT3 money, @CT4 money,
    @CT5 money, @CT6 money, @CT7 money, @CT8 money,
    @CI1 money, @CI2 money, @CI3 money, @CI4 money,
    @CR1 money, @CR2 money, @CR3 money, @CR4 money,
    @DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money,
    @DQ5 money, @DQ6 money,
    @DT1 money, @DT2 money, @DT3 money, @DT4 money,
    @DT5 money, @DT6 money, @DT7 money,
    @DI1 money, @DI2 money, @DI3 money, @DI4 money,
    @DR1 money, @DR2 money, @DR3 money, @DR4 money

  declare c_inmrpt cursor for
    select
      BWRH,
      CQ1, CQ2, CQ3, CQ4, CT1, CT2, CT3, CT4,
      CI1, CI2, CI3, CI4, CR1, CR2, CR3, CR4,
      DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
      DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
    from INMRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BVDRGID = @oldvdrgid and BGDGID = @gdgid
  open c_inmrpt
  fetch next from c_inmrpt into
    @wrh,
    @CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
    @CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
    @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
    @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  while @@fetch_status = 0
  begin
    if exists (
      select * from INMRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      )
    begin
      update INMRPT set
      CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
      CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
      CI1 = CI1 + @CI1, CI2 = CI2 + @CI2, CI3 = CI3 + @CI3, CI4 = CI4 + @CI4,
      CR1 = CR1 + @CR1, CR2 = CR2 + @CR2, CR3 = CR3 + @CR3, CR4 = CR4 + @CR4,
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DI1 = DI1 + @DI1, DI2 = DI2 + @DI2, DI3 = DI3 + @DI3, DI4 = DI4 + @DI4,
      DR1 = DR1 + @DR1, DR2 = DR2 + @DR2, DR3 = DR3 + @DR3, DR4 = DR4 + @DR4
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      delete from INMRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end
    else
    begin
      update INMRPT set BVDRGID = @vdrgid
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end
    fetch next from c_inmrpt into
      @wrh,
      @CQ1, @CQ2, @CQ3, @CQ4, @CT1, @CT2, @CT3, @CT4,
      @CI1, @CI2, @CI3, @CI4, @CR1, @CR2, @CR3, @CR4,
      @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
      @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  end
  close c_inmrpt
  deallocate c_inmrpt

  /* VDRMRPT */
  declare c_vdrmrpt cursor for
    select
      BWRH,
      CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
      CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8,
      DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
      DT1, DT2, DT3, DT4, DT5, DT6, DT7, CI2, DI2
    from VDRMRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @gdgid and BVDRGID = @oldvdrgid
  open c_vdrmrpt
  fetch next from c_vdrmrpt into
    @wrh,
    @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
    @CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
    @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
    @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @CI2, @DI2
  while @@fetch_status = 0
  begin
    if exists (select * from VDRMRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid)
    begin
      update VDRMRPT set
      CQ1 = CQ1 + @CQ1, CQ2 = CQ2 + @CQ2, CQ3 = CQ3 + @CQ3, CQ4 = CQ4 + @CQ4,
      CQ5 = CQ5 + @CQ5, CQ6 = CQ6 + @CQ6,
      CT1 = CT1 + @CT1, CT2 = CT2 + @CT2, CT3 = CT3 + @CT3, CT4 = CT4 + @CT4,
      CT5 = CT5 + @CT5, CT6 = CT6 + @CT6, CT7 = CT7 + @CT7,
      CT8 = CT8 + @CT8,
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
                        CI2 = CI2 + @CI2, DI2 = DI2 + @DI2
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      delete from VDRMRPT
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end
    else
    begin
      update VDRMRPT set BVDRGID = @vdrgid
      where ASTORE = @store and ASETTLENO = @settleno
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end

    update VDRMRPTLOG set BVDRGID = @vdrgid
    where ASTORE = @store and ASETTLENO = @settleno
      and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid

    fetch next from c_vdrmrpt into
      @wrh,
      @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
      @CT1, @CT2, @CT3, @CT4, @CT5, @CT6, @CT7, @CT8,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @CI2, @DI2
  end
  close c_vdrmrpt
  deallocate c_vdrmrpt
end
GO
