SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[KillUser](
  @empcode char(10), --被踢用户代码
  @hostname nchar(256), --被踢工作站编号
  @msg varchar(255) output
)
--with encryption
as
begin
  declare
    @return_status int,
    @loginname sysname,
    @sid varbinary(85),
    @loop int,
    @spid int,
    @sql varchar(1000)

  --踢出用户之前的动作，用于定制。
  exec @return_status = KillUser_DoBeforeKill @empcode, @hostname, @msg output
  if @return_status <> 0 return @return_status

  set @loginname = rtrim(db_name()) + '_' + rtrim(@empcode)
  select @sid = suser_sid(@loginname)
  if object_id('tempdb..#killuser_spid') is not null drop table #killuser_spid
  select spid, loginame, IDENTITY (int, 1, 1) as seq into #killuser_spid
    from master.dbo.sysprocesses
    where sid = @sid
      and hostname = isnull(@hostname, '')
  select @loop = isnull(max(seq), 0) from #killuser_spid
  if @loop > 0
  begin
    while @loop > 0
    begin
      select @spid = spid from #killuser_spid where seq=@loop
      set @sql = 'kill ' + cast(@spid as char(20))
      exec (@sql)
      if @@error <> 0
      begin
        set @Msg = '踢出用户' + @empcode + '时发生异常。错误代码：' + cast(@@error as varchar)
        return 1
      end
      set @loop = @loop - 1
    end

    --踢出用户之后的动作，用于定制。
    exec @return_status = KillUser_DoAfterKill @empcode, @hostname, @msg output
    if @return_status <> 0 return @return_status
  end

  return 0
end

GO
