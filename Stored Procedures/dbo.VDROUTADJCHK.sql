SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDROUTADJCHK] (
  @num char(10)
) with encryption as
begin
  declare
    @stat smallint,
    @settleno int,
    @wrh int,
    @date datetime,
    @gdgid int,
    @vdrgid int,
    @difqty money,
    @diftotal money,
    @inprc money,
    @rtlprc money
  select
    @stat = STAT,
    @wrh = WRH
    from VDROUTADJ where NUM = @num
  if @stat <> 0 begin
    raiserror('被审核的不是未审核的单据', 16, 1)
    return(1)
  end
  update VDROUTADJ set STAT = 1 where NUM = @num
  declare c_vdrout cursor for
    select SETTLENO, convert(datetime, convert(char, DATE, 102)),
      GDGID, VENDOR, QTY-OLDQTY, TOTAL-OLDTOTAL
    from VDROUTADJDTL
    where NUM = @num
  open c_vdrout
  fetch next from c_vdrout into @settleno, @date,
    @gdgid, @vdrgid, @difqty, @diftotal
  while @@fetch_status = 0 begin
    select @rtlprc = FRTLPRC, @inprc = FINPRC
    from INVDRPT
    where BGDGID = @gdgid and BWRH = @wrh and ADATE = @date
      and ASETTLENO = @settleno
    -------------
    if @rtlprc is null select @rtlprc = 0
    if @inprc is null select @inprc = 0
    -------------

    insert into ZK (BWRH, BGDGID, BVDRGID, ADATE, ASETTLENO,
      GX_Q, GX_A, GX_R, GX_I)
    values (@wrh, @gdgid, @vdrgid, @date, @settleno,
      @difqty, @diftotal, @difqty * @rtlprc, @difqty * @inprc)

    fetch next from c_vdrout into @settleno, @date,
      @gdgid, @vdrgid, @difqty, @diftotal
  end
  close c_vdrout
  deallocate c_vdrout
  return (0)
end
GO
