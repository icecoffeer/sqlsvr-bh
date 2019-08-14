SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSRCV_Old](
    @p_src int,
    @p_id int,
    @p_frcupd smallint,
    @p_RcvOption int
) with encryption as
begin
/*
99-5-25: 将@e_msg从varchar改成char(100)
*/
    declare
    @ret_status int,
    @n_gid int,
    @n_code char(13),
    @n_frcupd smallint,
    @n_type smallint,
    @l_gid int,
    @e_code char(13),
    @e_msg char(100)

    select @ret_status = 0
    select
        @n_gid = Gid, @n_code = Code, @n_frcupd = FrcUpd,
        @n_type = Type
        from NGOODS
        where Src = @p_src and Id = @p_id
    if @n_type <> 1
    begin
        raiserror('不是可接收商品', 16, 1)
        return(1)
    end

    select @l_gid = LGid
        from GDXLATE
        where NGid = @n_gid
    if @l_gid is not null
    begin
        if @p_frcupd = 1 or @n_frcupd = 1
        begin
            execute @ret_status = GDINPUTRCV_Old @n_gid, @l_gid, 0, @n_code,@p_RcvOption, @e_code output
            if @ret_status <> 0
            begin
                select @e_msg = '本地找到相同商品，但与本地其它商品输入码(' + @e_code + ')重复。'
                raiserror(@e_msg, 16, 1)
                return(1)
            end
            --2002.5.16
            if (select singlevdr from system) = 2
              execute @ret_status = VDRGD2RCV @n_gid, @l_gid
            if @ret_status <> 0
            begin
                select @e_msg = '商品所属的供应商资料不存在。'
                raiserror(@e_msg, 16, 1)
                return(1)
            end

            execute @ret_status = GOODSRCVUPD @p_src, @p_id, @l_gid
            if @ret_status <> 0
                raiserror('覆盖本地商品信息时发生错误。', 16, 1)
        end
        delete from NGDINPUT
            where GID = @n_gid
        delete from NGOODS
            where Src = @p_src and Id = @p_id
        return(@ret_status)
    end

    if exists (select * from GOODSH where Gid = @n_gid)
    begin
        if not exists (select GID from GDINPUT where Gid = @n_gid)
        begin
            execute @ret_status = GDINPUTRCV_Old @n_gid, @n_gid, 1, @n_code, @p_RcvOption ,@e_code output
            if @ret_status <> 0
            begin
                select @e_msg = '本地找到相同商品，但与本地其它商品输入码(' + @e_code + ')重复。'
                raiserror(@e_msg, 16, 1)
            end else begin
                delete from NGDINPUT where GID = @n_gid
                --2002.5.16
                if (select singlevdr from system) = 2
                  execute @ret_status = VDRGD2RCV @n_gid, @n_gid
                if @ret_status <> 0
                begin
                  select @e_msg = '商品所属的供应商资料不存在。'
                  raiserror(@e_msg, 16, 1)
                  return(1)
                end

                execute @ret_status = GOODSRCVAPD @p_src, @p_id
                if @ret_status <> 0
                    raiserror('将商品添加到本地时发生错误。', 16, 1)
                delete from NGOODS
                    where Src = @p_src and Id = @p_id
            end
        end else
        begin
            if @p_frcupd = 1 or @n_frcupd = 1
            begin
                execute @ret_status = GDINPUTRCV_Old @n_gid, @n_gid, 0, @n_code, @p_RcvOption, @e_code output
                if @ret_status <> 0
                begin
                    select @e_msg = '新商品，与本地商品输入码(' + @e_code + ')重复。'
                    raiserror(@e_msg, 16, 1)
                    return(1)
                end
                --2002.5.16
                if (select singlevdr from system) = 2
                  execute @ret_status = VDRGD2RCV @n_gid, @n_gid
                if @ret_status <> 0
                begin
                  select @e_msg = '商品所属的供应商资料不存在。'
                  raiserror(@e_msg, 16, 1)
                  return(1)
                end

                execute @ret_status = GOODSRCVUPD @p_src, @p_id, @n_gid
                if @ret_status <> 0
                    raiserror('将商品添加到本地时发生错误。', 16, 1)
            end
            delete from NGDINPUT where GID = @n_gid
            delete from NGOODS
                where Src = @p_src and Id = @p_id
        end
    end else
    begin
        execute @ret_status = GDINPUTRCV_Old @n_gid, @n_gid, 1, @n_code, @p_RcvOption, @e_code output
        if @ret_status <> 0
        begin
            select @e_msg = '新商品，与本地商品输入码(' + @e_code + ')重复。'
            raiserror(@e_msg, 16, 1)
            return(1)
        end
        delete from NGDINPUT where GID = @n_gid
        --2002.5.16
        if (select singlevdr from system) = 2
           execute @ret_status = VDRGD2RCV @n_gid, @n_gid
        if @ret_status <> 0
        begin
           select @e_msg = '商品所属的供应商资料不存在。'
           raiserror(@e_msg, 16, 1)
           return(1)
        end

        execute @ret_status = GOODSRCVAPD @p_src, @p_id
        if @ret_status <> 0
            raiserror('将商品添加到本地时发生错误。', 16, 1)
        delete from NGOODS
            where Src = @p_src and Id = @p_id
    end
    return(@ret_status)
end
GO
