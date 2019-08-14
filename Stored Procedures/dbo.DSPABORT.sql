SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DSPABORT] @num char(10) as
begin
  /* 对每一个明细减除其待提数. STAT := 3 */
  declare
  @wrh int,    @gdgid int,   @qty money, @return_status int, @subwrh int

  select @return_status = 0
  if (select STAT from DSP where NUM = @num) = 3
  begin
    select @return_status = 1
    raiserror( '不能再次作废已作废的提货单.', 16, 1)
    return @return_status
  end
  update DSP set STAT = 3 where NUM = @num
  select @wrh = WRH from DSP where NUM = @num
  declare c_dspdtl cursor for
  select GDGID, SALEQTY - DSPQTY - BCKQTY, /* 00-3-3 */SUBWRH
  from DSPDTL where NUM = @num
  open c_dspdtl
  fetch next from c_dspdtl into @gdgid, @qty, /* 00-3-3 */@subwrh
  while @@fetch_status = 0
  begin
    execute DecDspQty @wrh, @gdgid, @qty, /* 00-3-3 */@subwrh
    fetch next from c_dspdtl into @gdgid, @qty, /* 00-3-3 */@subwrh
  end
  close c_dspdtl
  deallocate c_dspdtl
  return @return_status
end
GO
