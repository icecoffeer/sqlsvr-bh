SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLBCKDLT](
    @p_oldnum char(10),
    @p_newoper int
) with encryption as
begin
    declare
        @ret_status int,        @max_num char(10),      @neg_num char(10),
        @conflict smallint,     @m_stat smallint,       @in_num char(10),
        @style smallint,        @om_provider int,       @usergid int

    select @conflict = 1, @max_num = @p_oldnum
    while @conflict = 1
    begin
        execute NEXTBN @max_num, @neg_num output
        if exists (select * from RTLBCK where NUM = @neg_num)
            select @max_num = @neg_num, @conflict = 1
        else
            select @conflict = 0
    end
    select @usergid = USERGID from SYSTEM
    select @om_provider = provider from RTLBCK where NUM = @p_oldnum

    /* 按照供货单位确定单据类型，@style:
        1   本店
        2   配供    */
    if @om_provider = @usergid
        select @style = 1
    else
        select @style = 2

    if @style = 2
    begin
        /* 冲单，配货进货退货单 */
        select @in_num = NUM from STKINBCK
            where CLS = '配货' and GEN = @usergid and GENBILL = 'RTLBCK'
            and GENCLS is null and GENNUM = @p_oldnum
        execute @ret_status = STKINBCKDLT '配货', @in_num, @p_newoper
        if @ret_status <> 0
        begin
            raiserror('对应的配货进货退货单冲单失败。', 16, 1)
            return(@ret_status)
        end
    end

    execute @ret_status = RTLBCKDLTNUM @p_oldnum, @p_newoper, @neg_num

    if @ret_status <> 0
    begin
        raiserror('处理单据时发生错误.', 16, 1)
        return (@ret_status)
    end

    return(@ret_status)
end
GO
