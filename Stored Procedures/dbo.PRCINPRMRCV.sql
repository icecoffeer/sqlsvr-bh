SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCINPRMRCV](
    @p_src int,
    @p_id int,
    @p_checker int
) with encryption as
begin
    declare
    @ret_status int,
    @n_type smallint,
    @n_checker int,
    @l_filler int,
    @cnt int

    select @ret_status = 0
    select @n_type = Type, @n_checker = Checker
        from NINPRCPRM where Src = @p_src and Id = @p_id
    if @@RowCount < 1
    begin
        raiserror('未找到指定进价促销单', 16, 1)
        return(2)
    end
    if @n_type <> 1
    begin
        raiserror('不是可接收单据', 16, 1)
        return(3)
    end

    select @l_filler = LGid from EMPXLATE where NGid = @n_checker
    if @@RowCount < 1
    begin
        raiserror('本地未包含审核人资料', 16, 1)
        return(4)
    end

    select @cnt = sum(case when X.LGid is null then 1 else 0 end)
        from NINPRCPRMDTL N, GDXLATE X
        where N.Src = @p_src and N.Id = @p_id and
            N.GdGid *= X.NGid
    if @cnt > 0
    begin
        raiserror('本地未包含商品资料', 16, 1)
        return(5)
    end

    execute @ret_status = PRCINPRMRCVGO @p_src, @p_id, @l_filler, @p_checker
    if @ret_status <> 0
    begin
        if @ret_status = 1
            raiserror('审核的不是未审核的单据.', 16, 1)
        else
            raiserror('单据接收失败.', 16, 1)
    end

    return(@ret_status)
end
GO
