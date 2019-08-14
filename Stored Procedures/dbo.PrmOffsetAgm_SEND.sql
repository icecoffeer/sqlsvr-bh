SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrmOffsetAgm_SEND]
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
  select @stat = stat from PrmOffsetAgm(nolock) where num = @num
  if @stat = 0
  begin
    set @msg = '未审核单据不能发送'
    return 1
  end
  if not exists(select 1 from PRMOFFSETAGMLACSTORE(nolock)
    where num = @num and storegid <> @store)
  begin
    set @msg = '生效单位只有本店，不能发送'
    return 0
  end
  declare cdtl cursor for
    select storegid from PRMOFFSETAGMLACSTORE(nolock)
    where num = @num and storegid <> @store

  open cdtl
  fetch next from cdtl into @gid
  while @@fetch_status = 0
  begin
    exec @ret = SENDONEPrmOffsetAgm @num, @cls, @store, @gid, @msg output
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

  update PrmOffsetAgm set sndtime = getdate(), lstupdtime = getdate()
    where num = @num
  return @ret
end
GO
