SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLUPD](
    @p_n_num char(10)
) with encryption as
begin
    declare
	@sysnum char(2),
        @ret_status int,        @n_stat smallint,       @o_num char(10),
        @max_num char(10),      @neg_num char(10),      @conflict smallint,
        @n_filler int,          @old_dsp_num char(10),  @old_invnum char(10),
        @new_dsp_num char(10),  @style smallint,        @n_provider int,
        @in_num char(10),       @dir_num char(10),      @usergid int,
        @o_in_num char(10),     @o_dir_num char(10)

    select @ret_status = 0
    select @usergid = USERGID, @sysnum = right(rtrim(convert(char, floor(USERGID / 1000000) + 100)), 2) from SYSTEM
    select @n_stat = STAT, @o_num = MODNUM, @n_filler = FILLER,
        @n_provider = PROVIDER
        from RTL where NUM = @p_n_num
    if @n_stat <> 0
    begin
        raiserror('修改单不是未审核的单据。', 16, 1)
        return(1)
    end
    if (select STAT from RTL where NUM = @o_num) <> 1
    begin
        raiserror('被修改的不是已审核的单据。', 16, 1)
        return(1)
    end

    /* 按照供货单位确定原单据类型，@style:
        1   本店
        2   配供
        3   供应商    */
    if @n_provider = @usergid
        select @style = 1
    else
    begin
        if not exists(select 1 from STORE where GID = @n_provider)
            select @style = 3
        else
            select @style = 2
    end

    select @conflict = 1, @max_num = @p_n_num
    while @conflict = 1
    begin
        execute NEXTBN @max_num, @neg_num output
        if exists (select * from RTL where NUM = @neg_num)
            select @max_num = @neg_num, @conflict = 1
        else
            select @conflict = 0
    end
    if substring(@neg_num, 1, 2) <> @sysnum
    begin
        raiserror('取下一单号超出范围', 16, 1)
        return (1)
    end

    execute @ret_status = RTLDLTNUM @o_num, @n_filler, @neg_num
    if @ret_status <> 0
    begin
        raiserror('对原单据进行冲单处理时发生错误。', 16, 1)
        return (@ret_status)
    end

    update RTL set STAT = 3 where NUM = @neg_num

    /* 单据附件 */
    update BILLAPDX set NUM = @p_n_num
        where BILL = 'RTL' and CLS = '' and NUM = @neg_num

    execute @ret_status = RTLCHK @p_n_num
    if @ret_status <> 0
    begin
        raiserror('审核新的单据时发生错误。', 16, 1)
        return (@ret_status)
    end

    if @ret_status = 0
    begin
        if @style = 2
        begin
            /* 修正，配货进货单 */
            select @in_num = NUM from STKIN
                where GEN = @usergid and GENBILL = 'RTL'
                and GENCLS is null and GENNUM = @p_n_num
            select @o_in_num = NUM from STKIN
                where GEN = @usergid and GENBILL = 'RTL'
                and GENCLS is null and GENNUM = @o_num
            update STKIN set STAT = 0, MODNUM = @o_in_num
                where CLS = '配货' and NUM = @in_num
            delete from BILLAPDX
                where BILL = 'STKIN' and CLS = '配货' and NUM = @in_num
            execute @ret_status = STKINUPD '配货', @in_num
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货单修正失败。', 16, 1)
                return (@ret_status)
            end
        end
        if @style = 3
        begin
            /* 修正，直配进货单 */
            select @dir_num = NUM from DIRALC
                where GEN = @usergid and GENBILL = 'RTL'
                and GENCLS is null and GENNUM = @p_n_num
            select @o_dir_num = NUM from DIRALC
                where GEN = @usergid and GENBILL = 'RTL'
                and GENCLS is null and GENNUM = @o_num
            update DIRALC set STAT = 0, MODNUM = @o_dir_num
                where CLS = '直配进' and NUM = @dir_num
            delete from BILLAPDX
                where BILL = 'DIRALC' and CLS = '直配进' and NUM = @dir_num
            execute @ret_status = DIRALCUPD '直配进', @dir_num
            if @ret_status <> 0
            begin
                raiserror('对应的直配进货单修正失败。', 16, 1)
                return (@ret_status)
            end
        end
    end

    /* 2000-1-8 李希明：删除原来已经作废的提货单，修改新的提货单为原来的单号。 */
    if @ret_status = 0
        and exists (select 1 from DSP
        where CLS = 'RTL' and POSNOCLS = '' and FLOWNO = @o_num)
    begin
        select @old_dsp_num = NUM, @old_invnum = INVNUM
            from DSP
            where CLS = 'RTL' and POSNOCLS = '' and FLOWNO = @o_num
        delete from DSPDTL where NUM = @old_dsp_num
        delete from DSP where NUM = @old_dsp_num
        select @new_dsp_num = NUM
            from DSP
            where CLS = 'RTL' and POSNOCLS = '' and FLOWNO = @p_n_num
        update DSPDTL set NUM = @old_dsp_num
            where NUM = @new_dsp_num
        update DSP set
            NUM = @old_dsp_num, INVNUM = @old_invnum
            where NUM = @new_dsp_num
    end

    return(@ret_status)
end
GO
