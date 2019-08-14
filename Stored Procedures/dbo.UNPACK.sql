SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[UNPACK](
  @pgid int,
  @egid int output,
  @mult money output
) with encryption as
begin
  declare @ret_status int, @gid int
  select @ret_status = 0
  exec @ret_status = GETPKG @pgid, @egid output, @mult output
/*  declare @count int
  select @egid = @pgid, @mult = 1 ,@count=1
  while (select ISPKG from GOODS where GID = @egid) = 1
  begin
    select @egid = EGID, @mult = @mult * QTY
    from PKG where PGID = @egid
    -- 1999.6.15 修改大小包装设定不完整会导致数据无法导入。HLJ
    select @count=@count+1
    if @count>=6 begin
    raiserror(' 该商品的大小包装设定不完整 ! ',16,1)
    return(1)
    end
  end */
  return(0)
end
GO
