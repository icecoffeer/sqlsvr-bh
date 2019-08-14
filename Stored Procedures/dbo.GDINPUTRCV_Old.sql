SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GDINPUTRCV_Old](
    @p_n_gid int,
    @p_l_gid int,
    @p_byapp smallint,
    @p_except_code char(13),
    @p_RcvOption int,
    @p_code char(13) output
) with encryption as
begin
    declare
    @n_code char(13),
    @n_codetype smallint,
    @l_other_gid int,	--2002.6.10
    @ret_status int

    select @ret_status = 0

    declare c_gdinput cursor for
        select CODE, CODETYPE from NGDINPUT
        where GID = @p_n_gid
        order by ID
        for read only
    open c_gdinput
    fetch next from c_gdinput into @n_code, @n_codetype
    while @@fetch_status = 0
    begin
      select @l_other_gid = GID from GDINPUT
        where CODE = @n_code and GID <> @p_l_gid
      if @@rowcount <> 0
      begin
        if not exists (select 1 from NGOODS	where GID =
          (select NGID from GDXLATE where LGID = @l_other_gid))
        begin
          select @ret_status = -1, @p_code = @n_code
          break
        end
        delete from GDINPUT where CODE = @n_code
      end
      if exists (select 1 from gdinput where gid = @p_l_gid)
        if not exists (select 1 from gdinput where gid = @p_l_gid and code = @n_code)
          if @p_RcvOption & 1 = 1
            return 0

      delete from GDINPUT where GID = @p_l_gid and code = @n_code
      insert into GDINPUT(CODE, CODETYPE, GID) values(@n_code, @n_codetype, @p_l_gid)
      fetch next from c_gdinput into @n_code, @n_codetype
    end
    close c_gdinput
    deallocate c_gdinput
    return(@ret_status)
end
GO
