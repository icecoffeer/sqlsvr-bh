SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCADJRCV](
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
        from NPRCADJ where Src = @p_src and Id = @p_id
    if @@RowCount < 1
    begin
        raiserror('未找到指定调价单', 16, 1)
        return(4)
    end
    if @n_type <> 1
    begin
        raiserror('不是可接收单据', 16, 1)
        return(5)
    end

    select @l_filler = LGid from EMPXLATE where NGid = @n_checker
    if @@RowCount < 1
    begin
        raiserror('本地未包含审核人资料', 16, 1)
        return(6)
    end

    select @cnt = sum(case when X.LGid is null then 1 else 0 end)
        from NPRCADJDTL N, GDXLATE X
        where N.Src = @p_src and N.Id = @p_id and
            N.GdGid *= X.NGid
    if @cnt > 0
    begin
        raiserror('本地未包含商品资料', 16, 1)
        return(7)
    end

    execute @ret_status = PRCADJRCVGO @p_src, @p_id, @l_filler, @p_checker
    if @ret_status <> 0
    begin
        if @ret_status = 1
          raiserror('新核算售价低于(非本店)最低售价.', 16, 1)
        else if @ret_status = 2
          raiserror('新最低售价高于(非本店)核算售价.', 16, 1)
        else if @ret_status = 3
          raiserror('新核算售价高于(非本店)最高售价.', 16, 1)
        else if @ret_status = 4
          raiserror('新最低售价高于本店核算售价.', 16, 1)
        else if @ret_status = 5
          raiserror('新核算售价低于本店最低售价.', 16, 1)
        else if @ret_status = 6
          raiserror('新核算售价不能高于最高售价.', 16, 1)
        else
          raiserror('单据生效时发生错误.', 16, 1)
    end

    return(@ret_status)
end
GO
