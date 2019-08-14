SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[DSPREGSND](
	@num char(10),
        @sendto int
) as
begin
	declare @max_id int,      @src_gid int

	if not exists(select * from DSPREG where NUM = @num)
	begin
		raiserror('此单据不存在,不能发送', 16, 1)
		return(1)
	end

        select @src_gid = USERGID from SYSTEM

        if not exists(select * from DSPREG
        	where ((SRC = @src_gid) or (src = 1))
                and NUM = @num)
	begin
		raiserror('此单据不是本单位生成,不能发送', 16, 1)
		return(1)
	end

	execute  GETNETBILLID @max_id OUTPUT
	if @max_id is null
		select @max_id = 1


	insert into NDSPREG(SRC, ID, NUM, SETTLENO, FILDATE, FILLER, INVNUM,
		ACPTIME, ACPEMP, OPER, RECCNT, DSPNUM, NOTE, SRCNUM, NSTAT,
		NNOTE, RCV, SNDTIME, RCVTIME, TYPE)

	select @src_gid, @max_id, NUM, SETTLENO, FILDATE, FILLER, INVNUM,
		        ACPTIME, ACPEMP, OPER, RECCNT, DSPNUM, NOTE, SRCNUM, 0,
        		NULL, @sendto, getdate(), getdate(), 0
        from DSPREG
	where NUM = @num

	insert into NDSPREGDTL(SRC, ID, LINE, SETTLENO, DSPLINE, GDGID,
        		AVAQTY, QTY, NOTE)
	select @src_gid, @max_id, LINE, SETTLENO, DSPLINE, GDGID,
        		AVAQTY, QTY, NOTE
	from DSPREGDTL
	where NUM = @num

	update DSPREG set SNDTIME = getdate() where NUM = @num

	return (0)
end

GO
