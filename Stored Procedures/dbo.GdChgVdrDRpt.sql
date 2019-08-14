SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将INXRPT中@store, @settleno, @wrh, @gdgid的供应商从@oldvdrgid改成@vdrgid
*/
create procedure [dbo].[GdChgVdrDRpt]
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
    exec GdChgVdrDRpt_YTZH @store, @settleno, @gdgid, @oldvdrgid, @vdrgid
    return(0)
  end

  declare
    @ADATE datetime, @wrh int,
    @CQ1 money, @CQ2 money, @CQ3 money, @CQ4 money,
    @CT1 money, @CT2 money, @CT3 money, @CT4 money,
    @CI1 money, @CI2 money, @CI3 money, @CI4 money,
    @CR1 money, @CR2 money, @CR3 money, @CR4 money,
    @DQ1 money, @DQ2 money, @DQ3 money, @DQ4 money,
    @DQ5 money, @DQ6 money,
    @DT1 money, @DT2 money, @DT3 money, @DT4 money,
    @DT5 money, @DT6 money, @DT7 money,
    @DI1 money, @DI2 money, @DI3 money, @DI4 money,
    @DR1 money, @DR2 money, @DR3 money, @DR4 money


  /* INDRPT */
  declare c_indrpt cursor for
    select ADATE, BWRH,
      DQ1, DQ2, DQ3, DQ4, DT1, DT2, DT3, DT4,
      DI1, DI2, DI3, DI4, DR1, DR2, DR3, DR4
    from INDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BVDRGID = @oldvdrgid and BGDGID = @gdgid
  open c_indrpt
  fetch next from c_indrpt into
    @ADATE, @wrh,
    @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
    @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  while @@fetch_status = 0
  begin
    if exists (select * from INDRPT
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
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end
    else
    begin
      update INDRPT set
      BVDRGID = @vdrgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno and ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end

    fetch next from c_indrpt into
      @ADATE, @wrh,
      @DQ1, @DQ2, @DQ3, @DQ4, @DT1, @DT2, @DT3, @DT4,
      @DI1, @DI2, @DI3, @DI4, @DR1, @DR2, @DR3, @DR4
  end
  close c_indrpt
  deallocate c_indrpt


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
    select ADATE, BWRH,
      DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
      DT1, DT2, DT3, DT4, DT5, DT6, DT7, DI2
    from VDRDRPT
    where ASTORE = @store and ASETTLENO = @settleno
      and BGDGID = @gdgid and BVDRGID = @oldvdrgid
  open c_vdrdrpt
  fetch next from c_vdrdrpt into
    @ADATE, @wrh,
    @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
    @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
  while @@fetch_status = 0
  begin
    if exists (select * from VDRDRPT
      where ASTORE = @store and ASETTLENO = @settleno AND ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid)
    begin
      update VDRDRPT set
      DQ1 = DQ1 + @DQ1, DQ2 = DQ2 + @DQ2, DQ3 = DQ3 + @DQ3, DQ4 = DQ4 + @DQ4,
      DQ5 = DQ5 + @DQ5, DQ6 = DQ6 + @DQ6,
      DT1 = DT1 + @DT1, DT2 = DT2 + @DT2, DT3 = DT3 + @DT3, DT4 = DT4 + @DT4,
      DT5 = DT5 + @DT5, DT6 = DT6 + @DT6, DT7 = DT7 + @DT7,
      DI2 = DI2 + @DI2,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno AND ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @vdrgid
      delete from VDRDRPT
      where ASTORE = @store and ASETTLENO = @settleno AND ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end
    else
    begin
      update VDRDRPT set
      BVDRGID = @vdrgid,
      LSTUPDTIME = getdate()
      where ASTORE = @store and ASETTLENO = @settleno AND ADATE = @ADATE
        and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid
    end

    update VDRDRPTLOG set BVDRGID = @vdrgid
    where ASTORE = @store and ASETTLENO = @settleno AND ADATE = @ADATE
      and BWRH = @wrh and BGDGID = @gdgid and BVDRGID = @oldvdrgid

    fetch next from c_vdrdrpt into
      @ADATE, @wrh,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
  end
  close c_vdrdrpt
  deallocate c_vdrdrpt
end
GO
