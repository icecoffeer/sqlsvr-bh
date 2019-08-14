SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LmtPrmRcv](
    @p_src int,  /*来源单位*/
    @p_id int,   /*ID*/
    @p_checker int /*登陆员工GID*/
) with encryption as
begin
    declare
    @ret_status int,
    @n_type smallint,
    @n_checker int,
    @l_filler int,
    @cnt int,
    @s_userGid  int,
    @s_rcvGid int

    select @s_usergid = USERGID from [SYSTEM]

    select @ret_status = 0
    select @n_type = Type, @n_checker = Checker
        from NLmtPrm where Src = @p_src and Id = @p_id
    select @s_rcvGid = rcv from NLmtPrm where Src = @p_src and Id = @p_id

    if @@RowCount < 1
    begin
        raiserror('未找到指定限量促销单', 16, 1)
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
        from NLmtPrmDtl N, GDXLATE X
        where N.Src = @p_src and N.Id = @p_id and
            N.GdGid *= X.NGid
    if @cnt > 0
    begin
        raiserror('本地未包含商品资料', 16, 1)
        return(5)
    end
    if @p_src = @s_userGid 
    begin
       raiserror('来源单位是本单位，不必接收',16,1)
       return(5)
    end
    if @s_rcvGid <> @s_userGid
    begin
       raiserror('该单据的接收单位不是本单位',16,1)
       return(5)
    end

    execute @ret_status = LmtPrmRcvGo @p_src, @p_id, @l_filler, @p_checker
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
