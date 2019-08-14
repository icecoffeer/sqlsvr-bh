SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLBCKUPD](
    @p_n_num char(10)
) with encryption as
begin
    declare
        @ret_status int,        @n_stat smallint,       @o_num char(10),
        @max_num char(10),      @neg_num char(10),      @conflict smallint,
        @n_filler int,          @style smallint,        @n_provider int,
        @in_num char(10),       @o_in_num char(10),     @usergid int

    select @ret_status = 0
    select @usergid = USERGID from SYSTEM
    select @n_stat = STAT, @o_num = MODNUM, @n_filler = FILLER,
        @n_provider = PROVIDER
        from RTLBCK where NUM = @p_n_num
    if @n_stat <> 0
    begin
        raiserror('修改单不是未审核的单据。', 16, 1)
        return(1)
    end
    if (select STAT from RTLBCK where NUM = @o_num) <> 1
    begin
        raiserror('被修改的不是已审核的单据。', 16, 1)
        return(1)
    end

    /* 按照供货单位确定单据类型，@style:
        1   本店
        2   配供    */
    if @n_provider = @usergid
        select @style = 1
    else
        select @style = 2

    /*2003-04-16 应该先审核再冲单*/
    /* 单据附件 */
    update BILLAPDX set NUM = @p_n_num
        where BILL = 'RTLBCK' and CLS = '' and NUM = @o_num

    execute @ret_status = RTLBCKCHK @p_n_num
    if @ret_status <> 0
    begin
        raiserror('审核新的单据时发生错误。', 16, 1)
        return (@ret_status)
    end

    if @ret_status = 0
    begin
        if @style = 2
        begin
            /* 修正，配货进货退货单 */
            select @in_num = NUM from STKINBCK
                where GEN = @usergid and GENBILL = 'RTLBCK'
                and GENCLS is null and GENNUM = @p_n_num
            select @o_in_num = NUM from STKINBCK
                where GEN = @usergid and GENBILL = 'RTLBCK'
                and GENCLS is null and GENNUM = @o_num
            update STKINBCK set STAT = 0, MODNUM = @o_in_num
                where CLS = '配货' and NUM = @in_num
            delete from BILLAPDX
                where BILL = 'STKINBCK' and CLS = '配货' and NUM = @in_num
            execute @ret_status = STKINBCKUPD '配货', @in_num
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货单修正失败。', 16, 1)
                return (@ret_status)
            end
        end
    end

    select @conflict = 1, @max_num = @p_n_num
    while @conflict = 1
    begin
        execute NEXTBN @max_num, @neg_num output
        if exists (select * from RTLBCK where NUM = @neg_num)
            select @max_num = @neg_num, @conflict = 1
        else
            select @conflict = 0
    end

    execute @ret_status = RTLBCKDLTNUM @o_num, @n_filler, @neg_num  /*2001-03-28*/
    if @ret_status <> 0
    begin
        raiserror('对原单据进行冲单处理时发生错误。', 16, 1)
        return (@ret_status)
    end

    update RTLBCK set STAT = 3 where NUM = @neg_num


    return(@ret_status)
end
GO
