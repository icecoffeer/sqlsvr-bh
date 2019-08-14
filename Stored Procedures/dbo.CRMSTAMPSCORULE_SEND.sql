SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CRMSTAMPSCORULE_SEND]
(
  @num      varchar(14),
  @cls      VARCHAR(30), 
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
  select @stat = stat from CRMSTAMPSCORULE(nolock) where num = @num 
  if @stat = 0
  begin
    set @msg = '未审核单据不能发送'
    return 1
  end
  if (select count(*) from CRMSTAMPSCORULELACSTORE(nolock) where num = @num ) = 1
  begin
    if (select storegid from CRMSTAMPSCORULELACSTORE(nolock) where num = @num ) = @store
    begin  
      set @msg = '生效单位只有本店，不能发送。'
      return(1)
    end
  end  
  
  declare cdtl cursor for
    select storegid from CRMSTAMPSCORULELACSTORE(nolock)
    where num = @num and storegid <> @store

  open cdtl
  fetch next from cdtl into @gid
  while @@fetch_status = 0
  begin
    exec @ret = CRMSTAMPSCORULE_SENDBILL @num, @cls, @store, @gid, @msg output
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

  update CRMSTAMPSCORULE set sndtime = getdate(), lstupdtime = getdate(), LSTUPDOPER = @oper
    where num = @num 
  return @ret
end
GO
