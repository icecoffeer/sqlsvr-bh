SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLDLT](
    @p_oldnum char(10),
    @p_newoper int
) with encryption as
begin
    declare
	@sysnum char(2),
        @ret_status int,        @max_num char(10),      @neg_num char(10),
        @conflict smallint,     @m_stat smallint,       @in_num char(10),
        @usergid int,           @style smallint,        @alc_num char(10),
        @om_provider int

    select @conflict = 1, @max_num = @p_oldnum
    while @conflict = 1
    begin
        execute NEXTBN @max_num, @neg_num output
        if exists (select * from RTL where NUM = @neg_num)
            select @max_num = @neg_num, @conflict = 1
        else
            select @conflict = 0
    end
    select @usergid = USERGID, @sysnum = right(rtrim(convert(char, floor(USERGID / 1000000) + 100)), 2) from SYSTEM

    /*if substring(@neg_num, 1, 2) <> @sysnum
    begin
        raiserror('取下一单号超出范围', 16, 1)
        return (1)
    end*/ --Deleted by ShenMin

    select @om_provider = PROVIDER from RTL where NUM = @p_oldnum

    /* 按照供货单位确定单据类型，@style:
        1   本店
        2   配供
        3   供应商    */
    if @om_provider = @usergid
        select @style = 1
    else
    begin
        if not exists(select 1 from STORE where GID = @om_provider)
            select @style = 3
        else
            select @style = 2
    end

    execute @ret_status = RTLDLTNUM @p_oldnum, @p_newoper, @neg_num

    if @ret_status <> 0
    begin
        raiserror('处理单据时发生错误.', 16, 1)
        return (@ret_status)
    end

    if @ret_status = 0
    begin
        if @style = 2
        begin
            /* 冲单，配货进货单 */
            select @in_num = NUM from STKIN
                where CLS = '配货' and GEN = @usergid and GENBILL = 'RTL'
                and GENCLS is null and GENNUM = @p_oldnum
            execute @ret_status = STKINDLT '配货', @in_num, @p_newoper
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货单冲单失败。', 16, 1)
                return(@ret_status)
            end
        end
        else if @style = 3
        begin
            /* 冲单，直配进货单 */
            select @alc_num = NUM from DIRALC
                where CLS = '直配进' and GEN = @usergid and GENBILL = 'RTL'
                and GENCLS is null and GENNUM = @p_oldnum
            execute @ret_status = DIRDLT '直配进', @alc_num, @p_newoper
            if @ret_status <> 0
            begin
                raiserror('对应的直配进货单冲单失败。', 16, 1)
                return(@ret_status)
            end
        end
    end

    return(@ret_status)
end
GO
