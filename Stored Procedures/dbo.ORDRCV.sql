SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ORDRCV](
	@src_gid int,
	@id int,
	@new_oper int
) as
begin
	declare
		@return_status int,
		@src_frcchk smallint,
		@src_stat smallint,

		@src_modnum char(10),
		@src_num char(10),

		@local_stat smallint,
		@prior_num char(10),
		@local_num char(10),
		@temp_id int,

		@becorrect_num char(10),
		@max_num char(10),
		@neg_num char(10)

	select
		@src_frcchk = FRCCHK,
		@src_stat = STAT,

		@src_modnum = MODNUM,
		@src_num = NUM
	from NORDER where ID = @id and SRC = @src_gid
	if @@ROWCOUNT <> 1
	begin
		raiserror('单据已被接收或删除', 16, 1)
		return(1)
	end

	if exists (select * from SYSTEM where USERGID = @src_gid)
	begin
		raiserror('不能接收本单位生成的单据', 16, 1)
		return(1)
	end

	if @src_stat <> 1 and @src_stat <> 4
	begin
		update NORDER set NSTAT = 1, NNOTE = '只能接收审核单据或冲单(负单)' where ID = @id and SRC = @src_gid
		return(0)
	end

	select @local_num = NUM, @local_stat = STAT from ORD where SRCNUM = @src_num AND SRC = @src_gid
	if @@ROWCOUNT > 0  --//此单据接收过
	begin
		if @local_stat = 0 and @src_frcchk = 1 and @src_stat = 1
			execute ORDCHK @local_num

		execute ORDDELNETBILL @src_gid, @id
		return(0)
	end
	--//下面处理第一次接收此单据的情况
	if @src_stat = 4
	begin
		select @becorrect_num = NUM, @local_stat = STAT
		from ORD
		where SRC = @src_gid and SRCNUM = @src_modnum
		if @@ROWCOUNT = 0
		begin
			update NORDER set NSTAT = 1, NNOTE = '此冲单(负单)的原单据不存在' where ID = @id and SRC = @src_gid
			return(0)
		end

    -- Added by zhourong, 2006.05.10
    -- Q6669: 增加数据完整性校验
    DECLARE @fromBillRecordCount int
    DECLARE @netBillRecordCount int
    DECLARE @err_msg VARCHAR(50)
    SELECT @fromBillRecordCount = RECCNT FROM ORD WHERE SRCNUM = @src_num AND SRC = @src_gid

    SELECT @netBillRecordCount = Count(1) FROM NORDERDTL WHERE ID = @id

    IF @fromBillRecordCount <> @netBillRecordCount
    BEGIN
      SELECT @err_msg = '发送的来源单据中的明细数与网络表中的明细数不符。'
      RAISERROR (@err_msg, 16, 1)
    END

		if @local_stat = 0
			execute ORDCHK @becorrect_num

		execute ORDDLT @becorrect_num, @new_oper
		--//将生成的冲单的SRCNUM改为接收到的冲单的NUM
		update ORD set SRCNUM = @src_num
		where SRC = @src_gid and SRCNUM = @src_modnum and STAT = 4

		delete from NORDERDTL where ID = @id and SRC = @src_gid
		delete from NORDER where ID = @id and SRC = @src_gid
		return(0)
	end

	--@src_stat = 1
	execute @return_status = ORDINSLOCBILL @src_gid, @id, @new_oper, @neg_num output
	if @return_status = 1
	begin
		raiserror('本单位没有此单据中的员工资料', 16, 1)
		return(1)
	end
	else if @return_status = 2
	begin
		raiserror('本单位没有此单据中的供应商资料', 16, 1)
		return(1)
	end
	else if @return_status = 3
	begin
		raiserror('本单位没有此单据中的商品资料', 16, 1)
		return(1)
	end
	else if @return_status = 4
	begin
		raiserror('商品的缺省仓位不存在', 16, 1)
		return(1)
	end

 -- Added by zhourong, 2006.05.10
  -- Q6669: 增加数据完整性校验
  SELECT @fromBillRecordCount = RECCNT FROM ORD WHERE SRCNUM = @src_num AND SRC = @src_gid

  SELECT @netBillRecordCount = Count(1) FROM NORDERDTL WHERE ID = @id

  IF @fromBillRecordCount <> @netBillRecordCount
  BEGIN
    SELECT @err_msg = '发送的来源单据中的明细数与网络表中的明细数不符。'
    RAISERROR (@err_msg, 16, 1)
  END

	if @src_frcchk = 1
		execute ORDCHK @neg_num

	delete from NORDERDTL where ID = @id and SRC = @src_gid
	delete from NORDER where ID = @id and SRC = @src_gid

	while not @src_modnum is null
	begin
		select @prior_num = @neg_num
		select @local_num = NUM, @local_stat = STAT
		from ORD
		where SRC = @src_gid and SRCNUM = @src_modnum
		if @@ROWCOUNT = 0
		begin
			--//此单据未接收过
			select @temp_id = (select max(ID) from NORDER
				where SRC = @src_gid and NUM = @src_modnum AND STAT = 2)

			--if @@ROWCOUNT = 0
			if @temp_id is null
			begin
				--//这里应该认为'修正单据链'已结束,应该立即返回
				--raiserror('修正单据链不完整,不能接收', 16, 1)
				return(0)
			end

			select @temp_id = ID, @src_frcchk = FRCCHK,
			       @src_modnum = MODNUM
			from NORDER
			where ID = @temp_id and SRC = @src_gid
                        --SRC = @src_gid and NUM = @src_modnum AND STAT = 2

			/*
			execute @return_status = ORDINSLOCBILL @src_gid, @temp_id, @new_oper, @neg_num output
			if @return_status = 1
			begin
				raiserror('本单位没有此单据中的员工资料', 16, 1)
				return(1)
			end
			else if @return_status = 2
			begin
				raiserror('本单位没有此单据中的供应商资料', 16, 1)
				return(1)
			end
			else if @return_status = 3
			begin
				raiserror('本单位没有此单据中的商品资料', 16, 1)
				return(1)
			end
			else if @return_status = 4
			begin
				raiserror('商品的缺省仓位不存在', 16, 1)
				return(1)
			end

			update ORD set MODNUM = @neg_num where NUM = @prior_num
			execute ORDCHK @neg_num
			--//execute ORDDLT @neg_num, @new_oper
			update ORD set STAT = 2 where num = @neg_num
			*/
		end
		else
		begin
			--//此单据接收过
			if @local_stat = 0
			begin
				execute ORDCHK @local_num
				--//execute ORDDLT @local_num, @new_oper
			end
			update ORD set STAT = 2 where NUM = @local_num

			exec OrdUpdAlcPool @local_num--2003.01.09
			--//else if @local_stat = 1
			--//	execute ORDDLT @local_num, @new_oper
			update ORD set MODNUM = @local_num
			where NUM = @prior_num

			select @temp_id = (select MAX(ID) from NORDER
			where SRC = @src_gid and NUM = @src_modnum AND STAT = 2)
			select @src_modnum = (select MODNUM from NORDER
			where ID = @temp_id and SRC = @src_gid)
                        --SRC = @src_gid and NUM = @src_modnum AND STAT = 2)
		end

   -- Added by zhourong, 2006.05.10
    -- Q6669: 增加数据完整性校验
    SELECT @fromBillRecordCount = RECCNT FROM ORD WHERE SRCNUM = @src_num AND SRC = @src_gid

    SELECT @netBillRecordCount = Count(1) FROM NORDERDTL WHERE ID = @id

    IF @fromBillRecordCount <> @netBillRecordCount
    BEGIN
      SELECT @err_msg = '发送的来源单据中的明细数与网络表中的明细数不符。'
      RAISERROR (@err_msg, 16, 1)
    END

		delete from NORDERDTL where ID = @temp_id and SRC = @src_gid
		delete from NORDER where ID = @temp_id and SRC = @src_gid
	end
end
GO
