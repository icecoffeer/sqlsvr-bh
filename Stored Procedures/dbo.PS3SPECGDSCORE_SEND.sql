SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECGDSCORE_SEND]
(
  @cls      varchar(10),
  @num      varchar(14),
  @oper     varchar(30),
  @tostat   int,
  @msg      varchar(255) output
)
as
begin
  declare
    @ret    int,
    @store  int,
    @stat   int,
    @gid    int

  set @ret = 0
  select @store = usergid from fasystem(nolock)
  select @stat = stat from PS3SPECGDSCORE(nolock) where num = @num and cls = @cls
  if @stat = 0
  begin
    set @msg = '未审核单据不能发送'
    return 1
  end
  if (select count(*) from PS3SPECGDSCORELACSTORE(nolock) where num = @num and cls = @cls) = 1
  begin
    if (select storegid from PS3SPECGDSCORELACSTORE(nolock) where num = @num and cls = @cls) = @store
    begin  
      select @msg = '生效单位只有本店，不能发送。'
      return(1)
    end
  end
  declare cdtl cursor for
    select storegid from PS3SPECGDSCORELACSTORE(nolock)
    where num = @num and cls = @cls and storegid <> @store

  open cdtl
  fetch next from cdtl into @gid
  while @@fetch_status = 0
  begin
    exec @ret = SENDONEPS3SPECGDSCORE @num, @cls, @store, @gid, @msg output
    if @ret <> 0
    begin
      close cdtl
      deallocate cdtl
      return(@ret)
    end
    fetch next from cdtl into @gid
  end
  close cdtl
  deallocate cdtl

  update PS3SPECGDSCORE set sndtime = getdate(), lstupdtime = getdate(), LSTUPDOPER = @oper
    where num = @num and cls = @cls
  return @ret
end
GO
