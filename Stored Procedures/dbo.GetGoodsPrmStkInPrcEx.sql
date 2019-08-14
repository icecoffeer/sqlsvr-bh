SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsPrmStkInPrcEx](
  @vdrgid int,
  @storegid int,
  @gdgid int,
  @prminprc money output,
  @prmstart datetime output,
  @prmfinish datetime output
)
with encryption as
begin
  declare
    @present datetime
    
  set @present = GetDate()
  set @prminprc = 0

  select @prminprc = price,
    @prmstart = astart,
    @prmfinish = afinish
    from inprice(nolock)
    where vdrgid = @vdrgid
      and storegid = @storegid
      and gdgid = @gdgid
      and astart <= @present
      and afinish >= @present
  if @@rowcount > 0 return 0

  select @prminprc = price,
    @prmstart = astart,
    @prmfinish = afinish
  from inprice(nolock)
  where vdrgid = 0
    and storegid = @storegid
    and gdgid = @gdgid
    and astart <= @present
    and afinish >= @present
  if @@rowcount > 0 return 0
  
  return 1
end
GO
