SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[UPDOFFSETED]
(
  @num varchar(14) /*促销补差单单号*/
) as
begin
  declare
    @vagmnum varchar(14),
    @nOffseted int,
    @nAll int
  declare c_agmnum cursor for
    select distinct agmnum from prmoffsetdtl(nolock) where num = @num
  open c_agmnum
  fetch next from c_agmnum into @vagmnum
  while @@fetch_status = 0
  begin
    select @nOffseted = Count(Offseted) from prmoffsetagmdtl(nolock) where num = @vagmnum and Offseted = 1
    select @nAll = Count(num) from prmoffsetagmdtl(nolock) where num = @vagmnum
    if @nAll <= @nOffseted
      update prmoffsetagm set offseted = 1 where num = @vagmnum
    else
      update prmoffsetagm set offseted = 0 where num = @vagmnum
    fetch next from c_agmnum into @vagmnum
  end
  close c_agmnum
  deallocate c_agmnum
end
GO
