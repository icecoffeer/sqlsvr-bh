SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRCVGO] (
    @p_src int,
    @p_id int,
    @p_frcupd smallint,
    @p_recursive smallint,
    @p_postgid int              output
) with encryption as
begin
    declare @n_gid int
    declare @n_code char(13)
    declare @p_teamid int
    declare @l_gid int
    declare @l_other_gid int
    declare @tempcode char(13)
    declare @ret_status int

    select
        @n_gid = GID,
        @n_code = Code,
        @p_teamid = TEAMID
    from NGOODS
    where Src = @p_src and Id = @p_id

    select @p_postgid = null
    select @l_gid = LGid from GDXLATE where NGid = @n_gid
    if @l_gid is null
      select @l_gid = @n_gid
    if exists(select 1 from GOODS where Gid = @l_gid)
    begin
      if exists(select 1 from GOODSH where Gid = @l_gid)
        delete from GOODSH where GID = @l_gid

      select @l_other_gid = GID from GOODS where code = @n_code and gid <> @l_gid
      if @l_other_gid is not null
      begin
        if not exists(select 1 from NGOODS where gid = @l_other_gid and type = 1)
        begin
          raiserror('本地找到相同商品，但与本地其它商品输入码(%s)重复。', 16, 1, @n_code)
          return 1
        end
        else
        begin
          if @p_recursive = 0
          begin
            select @p_postgid = @l_other_gid
            return 1
          end
          else
          begin
            exec GetTempGdCode @tempcode output
            update GOODS set code = @tempcode where gid = @l_other_gid
            delete from GDINPUT where gid = @l_other_gid and code = @n_code
            exec @ret_status = GOODSRCVUPD @p_src, @p_id, @l_gid
            if @ret_status <> 0
              raiserror('将商品添加到本地时发生错误。', 16, 1)
            delete from GDINPUT where gid = @l_gid
            delete from NGOODS where src = @p_src and id = @p_id
            select @p_postgid = @l_other_gid
          end
        end
      end
      else
        exec GOODSRCVUPD @p_src, @p_id, @l_gid
    end
    else
    begin
      exec GOODSRCVAPD @p_src, @p_id
    end
    delete from NGOODS where src = @p_src and id = @p_id

    /*接收VDRGD2RCV*/
    if (select singlevdr from system) = 2
    begin
      exec @ret_status = VDRGD2RCV @n_gid, @l_gid
      if @ret_status <> 0
      begin
        raiserror('商品所属的供应商资料不存在。', 16, 1)
        return 1
      end
    end
end
GO
