SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCADJRCVGO](
    @p_src int,
    @p_id int,
    @p_l_filler int,
    @p_l_checker int
) with encryption as
begin
    declare
    @ret_status int,
    @curr_settleno int,
    @n_cls char(8),
    @n_num char(10),
    @n_frcchk smallint,
    @l_num char(10),
    @l_newnum char(10),
    @lm_adjamt money,
    @nd_line smallint,
    @nd_lgid int,
    @nd_oldprc money,
    @nd_newprc money,
    @l_oldprc money,
    @l_qty money,
    @nd_qty money,
    @nd_Qpc money,
    @nd_QpcStr CHAR(15)

    select @ret_status = 0
    select @n_cls = Cls, @n_num = Num, @n_frcchk = FrcChk
        from NPRCADJ where Src = @p_src and Id = @p_id
    select @l_num = Max(Num) from PRCADJ where Cls = @n_cls
    if @l_num is not null
        execute NEXTBN @l_num, @l_newnum output
    else
        select @l_newnum = '0000000000'

    if not exists (select * from PRCADJ
        where Cls = @n_cls and Src = @p_src and SrcNum = @n_num)        --单据是否已被接收过
    begin
        select @curr_settleno = max(No) from MONTHSETTLE

        declare c_dtl cursor for
            select N.Line, X.LGid, N.OldPrc, N.NewPrc, N.QTY, N.QPC, N.QPCSTR
            from NPRCADJDTL N, GDXLATE X
            where N.Src = @p_src and N.Id = @p_id and N.GdGid *= X.NGid
        open c_dtl
        fetch next from c_dtl into @nd_line, @nd_lgid, @nd_oldprc, @nd_newprc, @nd_Qty, @nd_Qpc, @nd_QpcStr

    --2005.8.9, Added by ShenMin, Q4706, 调价类单记录日志
        if @@fetch_status = 0
           exec WritePrcAdjLog @n_cls, @l_newnum, '接收'

        while @@fetch_status = 0
        begin
            if @n_cls <> '量贩价' begin
            select @l_oldprc =
                case @n_cls
                    when '核算价' then InPrc
                    when '核算售价' then QpcRtlPrc
                    when '最低售价' then QpcLwtRtlPrc
                    when '批发价' then QpcWhsPrc
                    when '代销价' then DxPrc
                    when '会员价' then QpcMbrprc  --2001.4.2
					when '合同进价' then Cntinprc  --2001.4.2
					else PayRate      --联销率
                end
            from V_QPCGOODS
            where Gid = @nd_lgid and QpcQpcStr = @nd_QpcStr
	    if @n_cls = '积分'
	    select @l_oldprc = score from gdscroe  --2001.4.2
            where gdgid = @nd_lgid
	   if @l_oldprc is null select @l_oldprc = 0
            select @l_qty = sum(qty)
                from Inv
                where GdGid = @nd_lgid
            insert into PRCADJDTL(
                Cls, Num, Line, SettleNo, GdGid,
                OldPrc, NewPrc, Qty, QPC, QPCSTR)
                values(
                @n_cls, @l_newnum, @nd_line, @curr_settleno, @nd_lgid,
                @l_oldprc, @nd_newprc, isnull(@l_qty, 0), @nd_Qpc, @nd_QpcStr)
             end
             else   --Add By Wang xin 2002-05-06
             begin
             	insert into PRCADJDTL(
                Cls, Num, Line, SettleNo, GdGid,
                OldPrc, NewPrc, Qty, QPC, QPCSTR)
                values(
                @n_cls, @l_newnum, @nd_line, @curr_settleno, @nd_lgid,
                @nd_oldprc, @nd_newprc, @nd_Qty, @nd_Qpc, @nd_QpcStr)
             end
            fetch next from c_dtl into @nd_line, @nd_lgid, @nd_oldprc, @nd_newprc, @nd_Qty, @nd_Qpc, @nd_QpcStr
        end
        close c_dtl
        deallocate c_dtl

        select @lm_adjamt = sum((NewPrc - OldPrc) * Qty)
            from PRCADJDTL where Cls = @n_cls and Num = @l_newnum
        insert into PRCADJ(
            Cls, Num, SettleNo, FilDate, Filler,
            Checker, AdjAmt, Stat, Note, RecCnt,
            Launch, Src, SrcNum, SndTime, EON, SrcFilDate)
            select
                Cls, @l_newnum, @curr_settleno, FilDate, @p_l_filler,
                @p_l_checker, @lm_adjamt, 0, Note, RecCnt,
                Launch, Src, Num, null, 1, FilDate
            from NPRCADJ
            where Src = @p_src and Id = @p_id
        if @n_frcchk = 1
        begin
            execute @ret_status = PRCADJCHK @n_cls, @l_newnum
            if @ret_status <> 0
            begin
              raiserror('审核接收的调价单失败.', 16, 1)
              return @ret_status
            end
        end
    end
    delete from NPRCADJDTL
        where Src = @p_src and Id = @p_id
    delete from NPRCADJ
        where Src = @p_src and Id = @p_id

    return(@ret_status)
end
GO
