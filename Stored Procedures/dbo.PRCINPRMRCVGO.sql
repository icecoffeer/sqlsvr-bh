SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCINPRMRCVGO](
    @p_src int,
    @p_id int,
    @p_l_filler int,
    @p_l_checker int
) with encryption as
begin
    declare
    @ret_status int,
    @curr_settleno int,
    @n_num char(10),
    @n_frcchk smallint,
    @l_num char(10),
    @l_newnum char(10)

    select @ret_status = 0
    select @n_num = Num, @n_frcchk = FrcChk
        from NINPRCPRM where Src = @p_src and Id = @p_id
    select @l_num = max(Num) from INPRCPRM
    if @l_num is not null
        execute NEXTBN @l_num, @l_newnum output
    else
        select @l_newnum = '0000000000'

    if not exists (select * from INPRCPRM where Src = @p_src and SrcNum = @n_num)        --单据是否已被接收过
    begin
        select @curr_settleno = max(No) from MONTHSETTLE
        insert into INPRCPRMDTL(
            Num, Line, SettleNo,
            GdGid, Astart, Afinish, Price)
            select
                @l_newnum, N.Line, @curr_settleno,
                X.LGid, N.Astart, N.AFinish, N.Price
            from NINPRCPRMDTL N, GDXLATE X
            where N.Src = @p_src and N.Id = @p_id and
                N.GdGid = X.NGid
        insert into INPRCPRM(
            Num, SettleNo, VdrGid, FilDate, Filler, Checker,
            RecCnt, Stat, Note, Src, SrcNum,
            SndTime, EON)
            select
                @l_newnum, @curr_settleno, VdrGid, FilDate, @p_l_filler, @p_l_checker,
                RecCnt, 0, Note, Src, Num,
                null, 1
            from NINPRCPRM
            where Src = @p_src and Id = @p_id
        if @n_frcchk = 1
            execute @ret_status = PRCINPRMCHK @l_newnum
    end
    delete from NINPRCPRMDTL
        where Src = @p_src and Id = @p_id
    delete from NINPRCPRM
        where Src = @p_src and Id = @p_id

    return(@ret_status)
end
GO
