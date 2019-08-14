SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[UnLoadSubWrh]
  @Wrh int,
  @SubWrh int,
  @GdGid int,
  @Qty money
as
begin
  /* 2000-05-11 */
  /*
  select @Qty = -@Qty
  execute LoadInSubWrh @Wrh, @SubWrh, @GdGid, @Qty
  */
  /* 2000-05-11 */
  declare @newqty money, @dspqty money, @bckqty money
  if not exists ( select * from SUBWRHINV where WRH = @Wrh and
  SUBWRH = @SubWrh and GDGID = @GdGid )
  begin
    if not exists (select * from SUBWRH where WRH = @wrh and GID = @subwrh)
    begin
      raiserror( '仓位/货位对应错误.', 16, 1)
      return 11
    end
    insert into SUBWRHINV( WRH, SUBWRH, GDGID ) values ( @Wrh, @SubWrh, @GdGid )
  end
  select @newqty = QTY - @qty, @dspqty = DSPQTY, @bckqty = BCKQTY
  from SUBWRHINV where SUBWRH = @SubWrh and GDGID = @GdGid

  /* 2000-05-13 */
  if @newqty < 0 and ((select SWINVFLAG from SYSTEM) & 1 = 1)
  begin
    raiserror('货位库存不能小于0.', 16, 1)
    return 1023
  end

  if @newqty <> 0 or @dspqty <> 0 or @bckqty <> 0
    update SUBWRHINV set QTY = @newqty
    where SUBWRH = @SubWrh and GDGID = @GdGid
  else
    delete from SUBWRHINV where SUBWRH = @SubWrh and GDGID = @GdGid
end
GO
