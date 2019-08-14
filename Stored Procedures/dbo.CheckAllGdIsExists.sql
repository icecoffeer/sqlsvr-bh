SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CheckAllGdIsExists](
  @p_teamid int,
  @p_n_gid int
) as
begin
  declare
      @l_gid int,
      @ispkg int,
      @isbind int

    select @l_gid = LGid
        from GDXLATE
    where NGid = @p_n_gid

    if @l_gid is null
    begin
        raiserror('该商品本地不存在。', 16, 1)
        return(1)
    end

    --验证gdinput是否存在
    if not exists(select 1 from gdinput(nolock) where gid = @l_gid)
    begin
      raiserror('接收商品失败，输入码不存在。', 16, 1)
      return(1)
    end

    --验证pkg是否存在
    select @ispkg = isnull(ISPKG, 0), @isbind = isnull(ISBIND, 0) from GOODS(nolock) where gid = @l_gid

    if @ispkg = 1
    begin
      if not exists(select 1 from PKG(nolock) where PGID = @l_gid)
      begin
        raiserror('接收商品资料失败，大包装商品不存在。', 16, 1)
        return(1)
      end
    end

    if @isbind = 1
    begin
      if not exists(select 1 from GDBIND(nolock) where BINDGID = @l_gid)
      begin
        raiserror('接收商品资料失败,捆绑商品不存在。', 16, 1)
        return(1)
      end
   end

   if not exists(select 1 from GDQPC(nolock) where gid = @l_gid)
   begin
     raiserror('接收商品资料失败，商品规格不存在。', 16, 1)
     return(1)
   end
   return 0
end
GO
