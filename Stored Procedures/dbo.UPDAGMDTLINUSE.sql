SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[UPDAGMDTLINUSE]
(
  @num varchar(14)
) as
begin
  declare
    @agmnum char(14),
    @agmline int
  declare c_dtl cursor for
    select AGMNUM, AGMLINE from PRMOFFSETDTL(nolock)
    where num = @num
  open c_dtl;
  fetch next from c_dtl into @agmnum, @agmline
  while @@fetch_status = 0
  begin
    update prmoffsetagmdtl set inuse = 0, locknum = '' where num = @agmnum and line = @agmline
    fetch next from c_dtl into @agmnum, @agmline
  end
  close c_dtl
  deallocate c_dtl
end
GO
