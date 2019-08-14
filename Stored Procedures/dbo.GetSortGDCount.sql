SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetSortGDCount] (
    @sort varchar(13),
    @intret smallint output
) as
begin
    declare @sortlimit int
    declare @alen int
    declare @blen int
    declare @clen int
    DECLARE @dlen int

    set @intret = 0
    exec OPTREADINT 0, 'SortLimit', 0, @sortlimit output
    if @sortlimit = 0 return

    select @alen = ALEN, @blen = BLEN, @clen = CLEN, @dlen = DLEN from SYSTEM (nolock)

    if ((@sortlimit & 1 = 1) and len(@sort) = @alen) or ((@sortlimit & 2 = 2) and len(@sort) = @alen + @blen)
      or ((@sortlimit & 4 = 4) and len(@sort) = @alen + @blen + @clen)
      or ((@sortlimit & 8 = 8) and len(@sort) = @alen + @blen + @clen + @dlen)
      select @intret = count(*) from GOODS (nolock) where SORT like @sort + '%' and isnull(ISLTD, 0) & 2 <> 2 and isnull(ISLTD, 0) & 8 <> 8
end
GO
