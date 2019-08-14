SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[DSPRCV](
	@src_gid int,
	@id int,
	@new_oper int
) as
begin
	declare
        	@return_status int,         @src_num char(10),
                @src_stat smallint,         @src_fildate datetime,
                @max_num char(10),
		@neg_num char(10),
                @local_num char(10),
                @src_cls char(10),
                @src_posnocls char(10),
                @src_flowno char(12)          

        if not exists(select * from NDSP where ID = @id and SRC = @src_gid)
	begin
		raiserror('单据已被接收或删除', 16, 1)
		return(1)
	end

        if (@src_gid = (select USERGID from SYSTEM)) or (@src_gid = 1)
	begin
		raiserror('不能接收本单位生成的单据', 16, 1)
		return(1)
	end

	select
		@src_num = NUM,
                @src_stat = STAT,
                @src_fildate = FILDATE,
                @src_cls = CLS,
                @src_posnocls = POSNOCLS,
                @src_flowno = FLOWNO
	from NDSP where ID = @id and SRC = @src_gid
	

        if exists(select * from NBILLAPDX
	        where ID = @id and SRC = @src_gid and BILL = 'NDSP')
        begin
		delete from BILLAPDX where BILL = @src_cls and CLS = @src_posnocls and NUM = @src_flowno

		insert into BILLAPDX(BILL, CLS, NUM, FILDATE, DSPMODE, DSPDATE,
			OUTCTR, OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE)
		select @src_cls, @src_posnocls, @src_flowno, FILDATE, DSPMODE, DSPDATE,
	       		OUTCTR, OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE
	       	from NBILLAPDX
		where ID = @id and SRC = @src_gid and BILL = 'NDSP'

		delete from NBILLAPDX
        	where ID = @id and SRC = @src_gid and BILL = 'NDSP'
        end

        /*不能根据来源单号判断已接收过*/
	if exists(select * from DSP
        	where SRC = @src_gid
                and CLS = @src_cls
                and POSNOCLS = @src_posnocls
                and FLOWNO = @src_flowno)
        begin
                select @local_num = NUM from DSP
                where SRC = @src_gid
                and CLS = @src_cls
                and POSNOCLS = @src_posnocls
                and FLOWNO = @src_flowno

               	update DSP set STAT = @src_stat, FILDATE = @src_fildate,
                	SRCNUM = @src_num
                where SRC = @src_gid
                and NUM = @local_num

		delete from NDSPDTL where ID = @id and SRC = @src_gid
		delete from NDSP where ID = @id and SRC = @src_gid
		
		return(0)
	end

	--//下面处理第一次接收此单据的情况
	execute @return_status = DSPINSLOCBILL @src_gid, @id, @new_oper, @neg_num output
	if @return_status = 1
	begin
		raiserror('本单位没有此单据中的员工资料', 16, 1)
		return(1)
	end
	else if @return_status = 2
	begin
		raiserror('本单位没有此单据中的商品资料', 16, 1)
		return(1)
	end
end

GO
