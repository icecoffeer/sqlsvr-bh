SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PSCPRCVUPD](
    @p_src int,
    @p_id int,
    @p_l_gid int
) with encryption as
begin
    declare
    		 @gdgid int,
    		 @lgid int,
    		 @lline int,
    		 @filler int,
    		 @modifier int,
    		 @Errmsg varchar(255)

    select @filler = FILLER, @modifier = MODIFIER from NPSCP
    	where  ID = @p_id and SRC = @p_src

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

    update PSCP
        set
            Code = N.Code, /*2001-06-09*/
            Name = N.Name,
            RawReccnt = N.RawReccnt,
            PdtReccnt = N.PdtReccnt,
            CreateDate = N.CreateDate,
            Modifier = N.Modifier,
            Filler = N.Filler,
            NOte = N.Note,
            PSCPTYPE = N.PSCPTYPE, --ShenMin
            CYCLE = N.CYCLE,
            STAT = N.STAT,
            Src = @p_src, SndTime = null, LstUpdTime = getdate()
        from PSCP P, NPSCP N
        where P.Gid = @p_l_gid
            and N.Src = @p_src
            and N.Id = @p_Id

    delete from PSCPDTL
    where GID = @p_l_gid

    insert into PSCPDTL (GID,RAW,LINE,GDGID,QTY )
    select GID, RAW, LINE, GDGID, QTY from NPSCPDTL ND
    where ND.Src = @p_src
    	  and ND.Id = @p_Id
    return(0)
end
GO
