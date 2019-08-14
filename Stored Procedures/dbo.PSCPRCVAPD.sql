SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PSCPRCVAPD](
    @p_src int,
    @p_id int
) with encryption as
begin
    declare
    		 @n_gid int,
    		 @gdgid int,
    		 @lgid int,
    		 @lline int,
    		 @filler int,
    		 @modifier int,
    		 @Errmsg varchar(255)


    select @filler = FILLER, @modifier = MODIFIER from NPSCP
    	where ID = @p_id and SRC = @p_src

    if not exists (select E.Gid from EMPXLATE X, EMPLOYEE E
	    where X.NGid = @modifier and X.LGid *= E.Gid)
        begin
            raiserror('配方对应的修改人未被转入。', 16, 1)
            return(1)
        end
    if not exists (select E.Gid from EMPXLATE X, EMPLOYEE E
	    where X.NGid = @filler and X.LGid *= E.Gid)
        begin
            raiserror('配方对应的创建人未被转入。', 16, 1)
            return(1)
        end


   declare c_PscpDtl cursor for
   	select GDGID, LINE from NPSCPDTL where ID = @p_id and SRC = @p_src
   open c_PscpDtl
   fetch next from c_PscpDtl into @gdgid, @lline
   while @@fetch_status = 0
     begin
     	select @lgid
     	from GOODSH a, GDXLATE b
	where b.NGID = @gdgid and b.LGID = a.GID
        if @@rowcount = 0 or @lgid is null
        begin
                select @Errmsg = '网络配方第'
                       + convert(varchar, @lline) + '行的商品资料尚未转入'
                raiserror(@Errmsg, 16, 1)
                break
         end
     end
   close c_PscpDtl
   deallocate c_PscpDtl

    select @n_gid = Gid
        from NPSCP
        where Src = @p_src and Id = @p_id
    if exists (select * from PSCPH where Gid = @n_gid)
        delete from PSCPH where Gid = @n_gid
    insert into PSCP(
        Gid, Code, Name, CreateDate,Filler,Modifier,
        Note, PSCPTYPE, STAT, RawReccnt, PdtReccnt, --ShenMin
        Src, SndTime, LstUpdTime, CYCLE)
        select
            Gid, Code, Name, CreateDate,Filler,Modifier,
            Note, PSCPTYPE, STAT, RawReccnt, PdtReccnt,  --ShenMin
            Src, null, getdate(),CYCLE
            from NPSCP
            where Src = @p_src and Id = @p_id
   insert into PSCPDTL(
   	Gid, Raw, Line, GdGid, Qty)
   	select
   		Gid, Raw, Line, GdGid, Qty
   		from NPSCPDTL
   		where Src = @p_src and Id = @p_id
    return(0)
end
GO
