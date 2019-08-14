SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[DSPSND](
	@num char(10),
        @sendto int
) as
begin
	declare @max_id int,      @src_gid int,
        	@cls char(10),    @posnocls char(10),
                @flowno char(10)

	if not exists(select * from DSP where NUM = @num)
	begin
		raiserror('此单据不存在,不能发送', 16, 1)
		return(1)
	end

        select @src_gid = USERGID from SYSTEM

        if not exists(select * from DSP
        	where ((SRC = @src_gid) or (src = 1))
                and NUM = @num)
	begin
		raiserror('此单据不是本单位生成,不能发送', 16, 1)
		return(1)
	end

	execute  GETNETBILLID @max_id OUTPUT
	if @max_id is null
		select @max_id = 1


	insert into NDSP(SRC, ID, NUM, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER,
        		OPENER, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO, SRCNUM, RCV,
                        SNDTIME, RCVTIME, TYPE, NSTAT, NNOTE)
	select @src_gid, @max_id, NUM, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER,
        		OPENER, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO, SRCNUM, @sendto,
			getdate(), getdate(), 0, 0, null
        from DSP
	where NUM = @num

	insert into NDSPDTL(SRC, ID, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY, SALETOTAL, NOTE)
	select @src_gid, @max_id, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY, SALETOTAL, NOTE
	from DSPDTL
	where NUM = @num

	update DSP set SNDTIME = getdate() where NUM = @num

        select @cls = CLS, @posnocls = POSNOCLS, @flowno = FLOWNO
        from DSP
        where NUM = @num

        insert into NBILLAPDX(SRC, BILL, ID, FILDATE, DSPMODE, DSPDATE, OUTCTR,
			OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, TYPE, RCV)
	select @src_gid, 'NDSP', @max_id, FILDATE, DSPMODE, DSPDATE, OUTCTR,
			OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, 0, @sendto
        from BILLAPDX
        where BILL = @cls
        and CLS = @posnocls
        and NUM = @flowno

	return (0)
end

GO
