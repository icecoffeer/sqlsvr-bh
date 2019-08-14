SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetRecOutSubWrh]
  @Wrh int,
  @GdGid int,
  @qty money,
  @mode int,
  @SubWrh int output
as
begin
  select @subwrh = null
  if @mode & 1 <> 0
  begin
    if @mode & 2 <> 0
      select @subwrh = min(SUBWRH) from SUBWRHINV
      where WRH = @wrh and GDGID = @gdgid and QTY =
      (select max(QTY) from SUBWRHINV where WRH = @wrh and GDGID = @gdgid and QTY >= @qty)
    else
      select @subwrh = min(SUBWRH) from SUBWRHINV
      where WRH = @wrh and GDGID = @gdgid and QTY =
      (select min(QTY) from SUBWRHINV where WRH = @wrh and GDGID = @gdgid and QTY >= @qty)
    if @subwrh is null
    begin
      if @mode & 4 <> 0
        select @subwrh = min(SUBWRH) from SUBWRHINV
        where WRH = @wrh and GDGID = @gdgid and QTY =
        (select max(QTY) from SUBWRHINV where WRH = @wrh and GDGID = @gdgid)
      else
        select @subwrh = min(SUBWRH) from SUBWRHINV
        where WRH = @wrh and GDGID = @gdgid and QTY =
        (select min(QTY) from SUBWRHINV where WRH = @wrh and GDGID = @gdgid)
    end
  end
  else
  begin
    if @mode & 4 <> 0
      select @subwrh = min(SUBWRH) from SUBWRHINV
      where WRH = @wrh and GDGID = @gdgid and QTY =
      (select max(QTY) from SUBWRHINV where WRH = @wrh and GDGID = @gdgid)
    else
      select @subwrh = min(SUBWRH) from SUBWRHINV
      where WRH = @wrh and GDGID = @gdgid and QTY =
      (select min(QTY) from SUBWRHINV where WRH = @wrh and GDGID = @gdgid)
  end
end
GO
