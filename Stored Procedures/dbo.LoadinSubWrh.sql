SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LoadinSubWrh]
  @Wrh int,
  @SubWrh int,
  @GdGid int,
  @Qty money,
  @InPrc money = null
as
begin
  declare @newqty money,
  /* 2000-04-21 */ @dspqty money, @bckqty money
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
  select @newqty = QTY + @qty /* 2000-04-21 */, @dspqty = DSPQTY, @bckqty = BCKQTY
  from SUBWRHINV where SUBWRH = @SubWrh and GDGID = @GdGid
  if @newqty <> 0 /* 2000-04-21 */ or @dspqty <> 0 or @bckqty <> 0
    update SUBWRHINV set QTY = @newqty, LSTINPRC = @InPrc
    where SUBWRH = @SubWrh and GDGID = @GdGid
  else
    delete from SUBWRHINV where SUBWRH = @SubWrh and GDGID = @GdGid
end
GO
