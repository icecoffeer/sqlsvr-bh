SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DMDPRMRCV](
    @p_src int,
    @P_id int
) as
begin
    declare
      @ret_status int,
      @user_gid int,
      @ratifystore int,
      @n_eon smallint,
      @s_eon smallint,
      @n_type smallint,
      @n_filler int,
      @n_submitter int,
      @cnt int,
      @curr_settleno int,
      @n_num char(10),
      @l_num char(10),
      @l_newnum char(10),
      @stat int,
      @srcnum varchar(14),
      @Topic varchar(10)

    select @ret_status = 0
    select @user_gid = UserGid from System
    select @n_type = Type, @n_filler=filler,@n_submitter=submitter,@s_eon=eon,@ratifystore=ratifystore, @stat = stat, @srcnum = srcnum, @Topic = Topic
        from NDMDPRM
        where Src = @p_src and Id = @p_id
    if @@RowCount < 1
    begin
        raiserror('未找到指定网络促销申请单', 16, 1)
        return(1)
    end
    if (@n_type = 0) or ((@p_src = @user_gid) and (@stat not in (2,3))) or ((@ratifystore = @user_gid) and (@stat <> 1))
    begin
        raiserror('不是可接收单据', 16, 1)
        return(2)
    end

    select @n_filler = LGid from EMPXLATE where NGid = @n_filler
    if @@RowCount < 1
    begin
        raiserror('本地未包含填单人资料', 16, 1)
        return(3)
    end

    select @n_submitter = LGid from EMPXLATE where NGid = @n_submitter
    if @@RowCount < 1
    begin
        raiserror('本地未包含提交人资料', 16, 1)
        return(4)
    end

    select @cnt = sum(case when X.LGid is null then 1 else 0 end)
        from NDMDPRMDTL N, GDXLATE X
        where N.Src = @p_src and N.Id = @p_id and N.GdGid *= X.NGid
    if @cnt > 0
    begin
        raiserror('本地未包含商品资料', 16, 1)
        return(5)
    end

    select @cnt = sum(case when X.LGid is null then 1 else 0 end)
        from NDMDPRMDTLDTL N, GDXLATE X
        where N.Src = @p_src and N.Id = @p_id and N.GftGid is not null and N.GftGid *= X.NGid
    if @cnt > 0
    begin
        raiserror('本地未包含商品资料', 16, 1)
        return(5)
    end

    select 1 from PrmTopic(nolock) where CODE = @Topic
    if @@RowCount < 1
    begin
        raiserror('本地未包含该促销申请单的促销主题', 16, 1)
        return(6)
    end

    select @n_num = Num
        from NDMDPRM
        where Src = @p_src and Id = @p_id
    select @l_num = max(Num) from DMDPRM
    if @l_num is not null
        execute NEXTBN @l_num, @l_newnum output
    else
        select @l_newnum = '0000000000'

    if exists (select * from DMDPRM where Src = @p_src and SrcNum = @n_num)
    begin
        raiserror('本单据已经接收过', 16, 1)
        -- Q6402: 网络单据接收时被拒绝自动删除单据
        IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
        BEGIN
           delete from NDMDPRMDTLDTL where Src = @p_src and Id = @p_id
          delete from NDMDPRMDTL    where Src = @p_src and Id = @p_id
          delete from NDMDPRMLACDTL where Src = @p_src and Id = @p_id
          delete from NDMDPRM       where Src = @p_src and Id = @p_id
        END

        return(6)
    end

    select @curr_settleno = max(No) from MONTHSETTLE
    if @p_src = @user_gid
      begin
        delete from DMDPRM where NUM = @srcnum;
        delete from DMDPRMDTL where NUM = @srcnum;
        delete from DMDPRMDTLDTL where NUM = @srcnum;
        delete from DMDPRMLACDTL where NUM = @srcnum;
        insert into DMDPRMDTLDTL(
                Num, Line, Item, SettleNo,
                Start, Finish, Cycle, CStart, CFinish,
                CSpec, QtyLo, QtyHi, Price, Discount,
                InPrc, MbrPrc, GftGid, GftQty, GftPer,
                GftType, PrmTag,PRMLWTPRC, CONFIRM)
                select
                    @srcnum, N.Line, N.Item, @curr_settleno,
                    N.Start, N.Finish, N.Cycle, N.CStart, N.CFinish,
                    N.CSpec, N.QtyLo, N.QtyHi, N.Price, N.Discount,
                    N.InPrc, N.MbrPrc, X.LGid, N.GftQty, N.GftPer,
                    N.GftType, N.PrmTag, N.PRMLWTPRC, N.CONFIRM
                from NDMDPRMDTLDTL N, GDXLATE X
                where N.Src = @p_src and N.Id = @p_id and N.GftGid *= X.NGid
        insert into DMDPRMDTL(Num, Line, SettleNo,GdGid, PrmType, CanGft, Qpc, QpcStr)
                select   @srcnum, N.Line, @curr_settleno,X.LGid, N.PrmType, N.CanGft, N.Qpc, N.QpcStr
                from NDMDPRMDTL N, GDXLATE X
                where N.Src = @p_src and N.Id = @p_id and N.GdGid = X.NGid
        insert into DmdPrmLacDtl(Num,StoreGid)
                select @srcnum,StoreGid
                  from NDmdPrmLacDtl
                  where Src = @p_src and Id = @p_id and StoreGid <> @user_gid
        if @s_eon = 1
            insert into DmdPrmLacDtl(Num,StoreGid) values(@srcnum,@p_src)
        if exists (select * from NDmdPrmLacDtl where Src=@p_src and Id=@p_id and StoreGid=@user_gid)
            select @n_eon = 1
        else
            select @n_eon = 0
        insert into DMDPRM(Num, SettleNo, FilDate, Filler, SubmitDate,Submitter,RatifyStore,
                           RecCnt, Stat, Note, Src, SrcNum, Eon,Launch,Topic,RATIFYDATE,RATIFIER, CancelDate, Canceler)
         select @srcnum, @curr_settleno, FilDate, @n_filler, SubmitDate, @n_submitter, RatifyStore,
                RecCnt, STAT, Note, Src, NULL, @n_eon, Launch,Topic,RATIFYDATE,RATIFIER, CancelDate, Canceler
            from NDMDPRM
            where Src = @p_src and Id = @p_id
      end
    else
    	begin
        insert into DMDPRMDTLDTL(
                Num, Line, Item, SettleNo,
                Start, Finish, Cycle, CStart, CFinish,
                CSpec, QtyLo, QtyHi, Price, Discount,
                InPrc, MbrPrc, GftGid, GftQty, GftPer,
                GftType, PrmTag,PRMLWTPRC, CONFIRM)
                select
                    @l_newnum, N.Line, N.Item, @curr_settleno,
                    N.Start, N.Finish, N.Cycle, N.CStart, N.CFinish,
                    N.CSpec, N.QtyLo, N.QtyHi, N.Price, N.Discount,
                    N.InPrc, N.MbrPrc, X.LGid, N.GftQty, N.GftPer,
                    N.GftType, N.PrmTag, N.PRMLWTPRC, N.CONFIRM
                from NDMDPRMDTLDTL N, GDXLATE X
                where N.Src = @p_src and N.Id = @p_id and N.GftGid *= X.NGid
        insert into DMDPRMDTL(Num, Line, SettleNo,GdGid, PrmType, CanGft, Qpc, QpcStr)
                select   @l_newnum, N.Line, @curr_settleno,X.LGid, N.PrmType, N.CanGft, N.Qpc, N.QpcStr
                from NDMDPRMDTL N, GDXLATE X
                where N.Src = @p_src and N.Id = @p_id and N.GdGid = X.NGid
        insert into DmdPrmLacDtl(Num,StoreGid)
                select @l_newnum,StoreGid
                  from NDmdPrmLacDtl
                  where Src = @p_src and Id = @p_id and StoreGid <> @user_gid
        if @s_eon = 1
            insert into DmdPrmLacDtl(Num,StoreGid) values(@l_newnum,@p_src)
        if exists (select * from NDmdPrmLacDtl where Src=@p_src and Id=@p_id and StoreGid=@user_gid)
            select @n_eon = 1
        else
            select @n_eon = 0
        insert into DMDPRM(Num, SettleNo, FilDate, Filler, SubmitDate,Submitter,RatifyStore,
                           RecCnt, Stat, Note, Src, SrcNum,Eon,Launch,Topic,RATIFYDATE,RATIFIER, CancelDate, Canceler)
         select @l_newnum,@curr_settleno, FilDate, @n_filler, SubmitDate,@n_submitter,RatifyStore,
                RecCnt, STAT, Note, Src, Num,@n_eon,Launch,Topic,RATIFYDATE,RATIFIER, CancelDate, Canceler
            from NDMDPRM
            where Src = @p_src and Id = @p_id
    	end;
    delete from NDMDPRMDTLDTL where Src = @p_src and Id = @p_id
    delete from NDMDPRMDTL    where Src = @p_src and Id = @p_id
    delete from NDMDPRMLACDTL where Src = @p_src and Id = @p_id
    delete from NDMDPRM       where Src = @p_src and Id = @p_id

    return(@ret_status)
end
GO
