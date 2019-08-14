SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CMB](
  @store int,
  @wrh int,
  @gdgid int
) with encryption as
begin
  declare @return_status int, @qty money, @total money

  select @qty = null, @total = null
  select
    @qty = sum(QTY),
    @total = sum(TOTAL)
    from INV where WRH = @wrh and GDGID = @gdgid and STORE = @store
  if @qty is not null or @total is not null begin
    delete from INV where WRH = @wrh and GDGID = @gdgid and STORE = @store
    insert into INV (WRH, GDGID, QTY, TOTAL, VALIDDATE, STORE)
      values (@wrh, @gdgid, @qty, @total, NULL, @store)
  end
end
GO
