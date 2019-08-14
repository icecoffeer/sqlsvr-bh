SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdChgVdrDRpt_YTZH]
  @store int,
  @settleno int,
  @gdgid int,
  @oldvdrgid int,
  @vdrgid int
as
begin
  declare @msg varchar(255)
  if (select SALE from GOODS(nolock) where GID = @gdgid) <> 3
  begin
    set @msg = '商品不是联销商品，不能更改供应商'
    raiserror(@msg, 16, 1)
    return(1)
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
    @DR1 money, @DR2 money, @DR3 money, @DR4 money,
    @NegDQ2 money, @NegDT3 money, @NegDI2 money

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
    --修改原供应商的数据
    
    select @NegDQ2 = -1 * @DQ2, @NegDT3 = -1 * @DT3, @NegDI2 = -1 * @DI2
    exec AppUpdVdrDrpt @store = @store, @settleno = @settleno, @date = @ADATE, @vdrgid = @oldvdrgid,
      @wrh = @wrh, @gdgid = @gdgid, @dq1 = 0, @dq2 = @NegDQ2, @dq3 = 0, @dq4 = 0, @dq5 = 0, @dq6 = 0,
      @dt1 = 0, @dt2 = 0, @dt3 = @NegDT3, @dt4 = 0, @dt5 = 0, @dt6 = 0, @dt7 = 0, @di2 = @NegDI2

    --修改新供应商的数据

    exec AppUpdVdrDrpt @store = @store, @settleno = @settleno, @date = @ADATE, @vdrgid = @vdrgid,
      @wrh = @wrh, @gdgid = @gdgid, @dq1 = 0, @dq2 = @DQ2, @dq3 = 0, @dq4 = 0, @dq5 = 0, @dq6 = 0,
      @dt1 = 0, @dt2 = 0, @dt3 = @DT3, @dt4 = 0, @dt5 = 0, @dt6 = 0, @dt7 = 0, @di2 = @DI2

    fetch next from c_vdrdrpt into
      @ADATE, @wrh,
      @DQ1, @DQ2, @DQ3, @DQ4, @DQ5, @DQ6,
      @DT1, @DT2, @DT3, @DT4, @DT5, @DT6, @DT7, @DI2
  end
  close c_vdrdrpt
  deallocate c_vdrdrpt

  return(0)
end
GO
