SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRCV](
    @p_src int,
    @p_id int,
    @p_frcupd smallint,
    @p_RcvOption int
) with encryption as
begin
                declare @p_gid  int
                declare @p_postgid int
                declare @p_postgid2 int
                declare @p_postpostgid int
                declare @p_pregid int
                declare @p_prepregid int
                declare @p_prepostgid int
                declare @p_teamid int
                declare @p_preteamid int
                declare @p_postteamid int
                declare @p_postteamid2 int
                declare @n_type smallint
                declare @p_other_src int
                declare @p_other_id int
                declare @post_rcv smallint
                declare @m_src int
                declare @m_id int
                declare @m_frcupd int
                declare @return_status int

                /*合法性检查*/
    select
        @n_type = TYPE,
        @p_gid  = GID,
        @p_teamid = isnull(TEAMID, 0)
    from NGOODS
    where Src = @p_src and Id = @p_id
    if @n_type is null return 0
    if @n_type <> 1
    begin
        raiserror('不是可接收商品', 16, 1)
        return(1)
    end

    if @p_teamid = 0
    begin
                exec @return_status = GoodsRcv_Old @p_src, @p_id, @p_frcupd, @p_RcvOption
                if @return_status <> 0 return @return_status

                declare c_npkg cursor for
                select src, id, frcupd from npkg
                where pgid = @p_gid or egid = @p_gid
                open c_npkg
                fetch next from c_npkg into @m_src, @m_id, @m_frcupd
                while @@fetch_status = 0
                begin
                                exec @return_status = pkgrcv_old @m_src, @m_id, @m_frcupd
                                if @return_status <> 0
                                begin
                                                close c_npkg
                                                deallocate c_nokg
                                                return @return_status
                                end
                                fetch next from c_npkg into @m_src, @m_id, @m_frcupd
                end
                close c_npkg
                deallocate c_npkg

                declare c_ngdbind cursor for
                select src, id, frcupd from ngdbind
                where bindgid = @p_gid or egid = @p_gid
                open c_ngdbind
                fetch next from c_ngdbind into @m_src, @m_id, @m_frcupd
                while @@fetch_status = 0
                begin
                                exec @return_status = gdbindrcv_old @m_src, @m_id, @m_frcupd
                                if @return_status <> 0
                                begin
                                                close c_ngdbind
                                                deallocate c_ngdbind
                                                return @return_status
                                end
                                fetch next from c_ngdbind into @m_src, @m_id, @m_frcupd
                end
                close c_ngdbind
                deallocate c_ngdbind
                return 0
    end

                /*接收NGOODS*/
                exec @return_status = GOODSRCVGO @p_src, @p_id, @p_frcupd, 1, @p_postgid output
                if @return_status <> 0 return @return_status
                if @p_postgid is not null
                begin
                select @p_other_src = src, @p_other_id = id, @p_postteamid = teamid
        from NGOODS where ID = (
                select min(ID) from NGOODS
            where GID = @p_postgid and TYPE = 1
        )
        exec @return_status = GOODSRCVGO @p_other_src, @p_other_id, @p_frcupd, 0, @p_postpostgid output
                                if @return_status <> 0 return @return_status
                if @p_postpostgid is not null
                begin
                                raiserror('商品资料中有3个以上（含3个）的商品发生主码交换', 16, 1)
                                return 1
                end
    end

                /*接收NGDINPUT*/
                if @p_postgid is null
                                set @post_rcv = 1
                else
                                set @post_rcv = 0
                while 1 = 1
                begin
                exec @return_status = GDINPUTRCV @p_teamid, @p_RcvOption, @p_pregid output
                if @return_status <> 0 return @return_status
                if @p_pregid is not null
                begin
                                if (@post_rcv = 0) and (@p_pregid = @p_postgid)
                                begin
                                                exec @return_status = GDINPUTRCV @p_postteamid, @p_RcvOption, @p_prepostgid output
                                                if @return_status <> 0 return @return_status
                                                if @p_prepostgid is not null
                                                begin
                                                                raiserror('该商品的前置商品的输入码被其他商品使用', 16, 1)
                                                                return 1
                                                end else
                                                begin
                                                                delete from NGDINPUT where TEAMID = @p_postteamid
                                                                set @post_rcv = 1
                                                                continue
                                                end
                                end

                                select
                                                @p_preteamid = teamid,
                                                @p_other_src = src,
                                                @p_other_id = id
                                from NGOODS where ID = (
                                                select min(ID) from NGOODS
                                                where GID = @p_pregid
                                ) and SRC = @p_src
                                if @@rowcount = 0
                                begin
                                                raiserror('网络商品中没有该商品的前置商品信息', 16, 1)
                                                return 1
                                end else
                                                begin
                                                set @p_postgid2 = @p_pregid
                                                set @p_postteamid2 = @p_preteamid
                                                exec @return_status = GOODSRCVGO @p_other_src, @p_other_id, @p_frcupd, 0, @p_postgid output
                                                if @return_status <> 0 return @return_status
                                                if @p_postgid is not null
                                                begin
                                                                raiserror('该商品的前置接收商品的代码被其他商品使用', 16, 1)
                                                                return 1
                                                end
                                                exec @return_status = GDINPUTRCV @p_preteamid, @p_prepregid output
                                                if @return_status <> 0 return @return_status
                                                if @p_prepregid is not null
                                                begin
                                                                raiserror('该商品的前置商品的输入码被其他商品使用', 16, 1)
                                                                return 1
                                                end
                                                delete from NGDINPUT where TEAMID = @p_preteamid
                                end
                end else
                begin
                                delete from NGDINPUT where TEAMID = @p_teamid
                                break
                end
    end
    if @post_rcv = 0
    begin
                exec @return_status = GDINPUTRCV @p_postteamid, @p_pregid output
                if @return_status <> 0 return @return_status
                if @p_pregid is not null
                begin
                                raiserror('该商品的前置商品的输入码已被其他商品使用', 16, 1)
                                return 1
                end else
                                delete from NGDINPUT where TEAMID = @p_postteamid
    end

    /*接收NGDBIND*/
    exec @return_status = GDBINDRCV @p_teamid, @p_gid  /*2003.04.22*/
    if @return_status <> 0 return @return_status
    delete from NGDBIND where TEAMID = @p_teamid
    if @p_postgid is not null
    begin
                exec @return_status = GDBINDRCV @p_postteamid, @p_postgid  /*2003.04.22*/
                if @return_status <> 0 return @return_status
                delete from NGDBIND where TEAMID = @p_postteamid
    end
    if @p_postgid2 is not null
    begin
                exec @return_status = GDBINDRCV @p_postteamid2, @p_postgid2  /*2003.04.22*/
                if @return_status <> 0 return @return_status
                delete from NGDBIND where TEAMID = @p_postteamid2
    end

    /*接收NPKG*/
    exec @return_status = PKGRCV @p_teamid, @p_gid /*2003.04.22*/
    if @return_status <> 0 return @return_status
    delete from NPKG where TEAMID = @p_teamid
    if @p_postgid is not null
    begin
                exec @return_status = PKGRCV @p_postteamid, @p_postgid /*2003.04.22*/
                if @return_status <> 0 return @return_status
                delete from NPKG where TEAMID = @p_postteamid
    end
    if @p_postgid2 is not null
    begin
                exec @return_status = PKGRCV @p_postteamid2, @p_postgid2 /*2003.04.22*/
                if @return_status <> 0 return @return_status
                delete from NPKG where TEAMID = @p_postteamid2
    end

    /*接收NGDQPC*/  --ShenMin
    exec @return_status = GDQPCRCV @p_teamid, @p_gid
    if @return_status <> 0 return @return_status
    delete from NGDQPC where TEAMID = @p_teamid
    if @p_postgid is not null
    begin
                exec @return_status = GDQPCRCV @p_postteamid, @p_postgid
                if @return_status <> 0 return @return_status
                delete from NGDQPC where TEAMID = @p_postteamid
    end
    if @p_postgid2 is not null
    begin
                exec @return_status = GDQPCRCV @p_postteamid2, @p_postgid2  /*2003.04.22*/
                if @return_status <> 0 return @return_status
                delete from NGDQPC where TEAMID = @p_postteamid2
    end

    /*接收NNOAUTOORDERREASON*/
    exec @return_status = NOAUTOORDERREASONRCV @p_teamid;
    if @return_status <> 0 return @return_status;
    delete from NNOAUTOORDERREASON where TEAMID = @p_teamid;

    --验证Goods相关表是否接收完整
    if @p_postgid is not null
    begin
      exec @return_status = CheckAllGdIsExists @p_postteamid, @p_postgid
      if @return_status <> 0 return @return_status
    end
    if @p_postgid2 is not null
    begin
      exec @return_status = CheckAllGdIsExists @p_postteamid2, @p_postgid2
      if @return_status <> 0 return @return_status
    end


    /*2003.06.09*/
    delete from ngdinput where gid not in (select gid from ngoods)
    delete from ngdbind where bindgid not in (select gid from ngoods)
    delete from npkg where pgid not in (select gid from ngoods)
    delete from nvdrgd2 where gdgid not in (select gid from ngoods)
    delete from ngdqpc where gid not in (select gid from ngoods) --ShenMin

    return 0
end
GO
