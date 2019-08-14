SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GDINPUTRCV](
  @p_teamid     int,
  @p_RcvOption  int,
  @p_pregid     int output
) with encryption as
begin
    declare @gid int
    declare @code char(13)
    declare @codetype smallint
    declare @tmpgid int
  --ShenMin
    declare @qpcstr varchar(20)
    declare @qpc decimal(24,4)

    select @p_pregid = null
    select @gid = GID from NGDINPUT where teamid = @p_teamid
    if @gid is null
    begin
      raiserror('网络商品无对应网络输入码', 16, 1)
      return 1
    end
    if @p_RcvOption & 1 <> 1
      delete from gdinput where gid = @gid
    set @tmpgid = -1
    declare c_gdinput cursor for
        select GID, CODE, CODETYPE, QPCSTR, QPC from NGDINPUT  --ShenMin
        where TEAMID = @p_teamid
        order by ID
        for read only
    open c_gdinput
    fetch next from c_gdinput into @gid, @code, @codetype, @qpcstr, @qpc  --ShenMin
    while @@fetch_status = 0
    begin
      if exists (select 1 from gdinput where code = @code and gid <> @gid)
      begin
        select @p_pregid = gid from gdinput where (code = @code)
        break
      end
      if (@gid = @tmpgid) and (@p_RcvOption & 1 = 1)
      begin
        fetch next from c_gdinput into @gid, @code, @codetype, @qpcstr, @qpc  --ShenMin
        continue
      end
      if exists(select 1 from gdinput where gid = @gid)
        if not exists(select 1 from gdinput where gid = @gid and code = @code)
          if @p_RcvOption & 1 = 1
            begin
              set @tmpgid = @gid
              fetch next from c_gdinput into @gid, @code, @codetype, @qpcstr, @qpc  --ShenMin
              continue
            end

      delete from gdinput where gid = @gid and code = @code
      insert into gdinput(code, codetype, gid, qpcstr, qpc) values(@code, @codetype, @gid, @qpcstr, @qpc)  --ShenMin
      fetch next from c_gdinput into @gid, @code, @codetype, @qpcstr, @qpc
    end
    close c_gdinput
    deallocate c_gdinput
    if @p_pregid is not null
      delete from gdinput where gid = @gid
    return 0
end
GO
