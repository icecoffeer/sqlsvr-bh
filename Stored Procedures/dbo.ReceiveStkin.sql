SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[ReceiveStkin](
	   @bill_id int,
	   @src_id int,
	   @operator int
) with encryption as
begin
	declare
		@return_status smallint,
		@cur_settleno int,
		@stat smallint,
		@cls char(10),
		@num char(10),
		@max_num char(10),
		@next_num char(10),
		@rcv_gid int,
		@net_cls char(10),
		@net_stat smallint,
		@net_frcchk smallint,
		@net_type smallint,
		@net_num char(10),
		@net_modnum char(10),
		@pre_num char(10),
		@net_billid int,
		@net_billto int,	--2001.12.10
		@net_client int,
		@errmsg varchar(255),
       @useCurrTime int

	select  @rcv_gid = RCV, @net_cls = CLS, @net_stat = STAT, @net_frcchk = FRCCHK,
			@net_type = TYPE, @net_num = NUM, @net_modnum = MODNUM,
			@net_billto = BILLTO, @net_client = CLIENT
	from NSTKOUT where ID = @bill_id and SRC = @src_id
  
	if @@rowcount = 0 or @net_num is null 
	begin
		raiserror('该单据不存在', 16, 1)
		return(1)
	end

  exec OptReadInt 0, 'StkinUseCurrentDateAsFillDate', 0, @useCurrTime output 
  if @useCurrTime is null set @useCurrTime = 0

	if (select max(USERGID) from SYSTEM ) <>  @rcv_gid
	begin
			raiserror('该单据的接收单位不是本单位', 16, 1)
			return(1)
	end

	if @net_type <> 1
	begin
		raiserror('该单据不在接收缓冲区中', 16, 1)
		return(1)
	end

	if @net_stat not in (1, 4, 6)
	begin
		raiserror('该单据不是已审核、已复核或负单(冲单)，不能接收', 16, 1)
		return(1)
	end
	
	-- 2001.12.10
	if @net_billto <> @net_client and 
		(select USERPROPERTY from SYSTEM) & 24 <> 0 
	begin
		exec @return_status = RCVOUTTODIR @bill_id, @src_id, @operator, @errmsg output
		if @return_status <> 0
			raiserror(@errmsg, 16, 1)
		return(@return_status)
	end

	if @net_cls = '批发' select @cls = '自营'
			else if @net_cls = '调出' select @cls = '调入'
					else if @net_cls = '配货' select @cls = '配货'
							 else  return(1)

	select @cur_settleno = max(NO) from MONTHSETTLE

	if @net_stat = 1 or @net_stat = 6
	begin
		select @stat = STAT, @num = NUM from STKIN
		where SRC = @src_id and CLS = @cls and SRCNUM = @net_num

		if @@rowcount > 0 and @stat is not null
		begin
			if (@stat = 0 or @stat = 7/*2001-11-05*/) and @net_frcchk = 1
			begin
				update STKIN
					set CHECKER = @operator, FILDATE = (case @useCurrTime when 0 then getdate() when 1 then FilDate end), SETTLENO = @cur_settleno
					where CLS = @cls and NUM = @num
				update STKINDTL
					set SETTLENO = @cur_settleno
					where CLS = @cls and NUM = @num
				execute @return_status = STKINCHK @cls, @num, 0
				if @return_status <> 0 return(@return_status)
			end 
			else if @stat = 0 and @net_frcchk = 7
			begin
				update STKIN
					set CHECKER = @operator, FILDATE = (case @useCurrTime when 0 then getdate() when 1 then FilDate end), SETTLENO = @cur_settleno, STAT = 7
					where CLS = @cls and NUM = @num
				update STKINDTL
					set SETTLENO = @cur_settleno
					where CLS = @cls and NUM = @num
			end else
			begin
				raiserror('单据已被接收过', 16, 1)
              -- Q6402: 网络单据接收时被拒绝自动删除单据
              IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
              BEGIN
                select  @net_billid = @bill_id, @net_modnum = MODNUM 
                		from NSTKOUT where ID = @bill_id and SRC = @src_id
                	while (1=1)
                	begin
                		delete from NSTKOUT where ID = @net_billid and SRC = @src_id
                		delete from NSTKOUTDTL where ID = @net_billid and SRC = @src_id
                		if (select BATCHFLAG from SYSTEM) = 2
                		    delete from NSTKOUTDTL2 where ID = @net_billid and SRC = @src_id
                		select @net_billid = max(ID), @net_modnum = max(MODNUM) from NSTKOUT
                			where SRC = @src_id and CLS = @net_cls and NUM = @net_modnum and STAT = 2
                		if @net_billid is null break
                	end
              END
				return(1)
			end

			select  @net_billid = @bill_id, @net_modnum = MODNUM 
				from NSTKOUT where ID = @bill_id and SRC = @src_id
			while (1=1)
			begin
				delete from NSTKOUT where ID = @net_billid and SRC = @src_id
				delete from NSTKOUTDTL where ID = @net_billid and SRC = @src_id
				if (select BATCHFLAG from SYSTEM) = 2 
				    delete from NSTKOUTDTL2 where ID = @net_billid and SRC = @src_id
				select @net_billid = max(ID), @net_modnum = max(MODNUM) from NSTKOUT
				where SRC = @src_id and CLS = @net_cls and NUM = @net_modnum and STAT = 2
				if @net_billid is null break
			end
			return(0)
		end

		select @max_num = MAX(NUM) from STKIN  where CLS = @cls
		if @max_num is null select @next_num = '0000000001'
			else execute NEXTBN @max_num, @next_num output
		execute @return_status = RCVONESTKIN @cls, @next_num, @bill_id, @src_id, @operator
		if @return_status <> 0 return(@return_status)
		if @net_frcchk = 7 
		begin
			UPDATE STKIN set STAT =  7 where CLS = @cls and NUM = @next_num
			GOTO Next_Exit
		end
		else if (@net_frcchk = 1) or (@net_modnum is not null)  begin
			execute @return_status = STKINCHK @cls, @next_num, 0
			if @return_status <> 0 return(@return_status)
		end
			select @pre_num = @next_num
	end

	if  @net_stat = 4
	begin
		select @stat = STAT, @num = NUM from STKIN
		where SRC = @src_id and CLS = @cls and SRCNUM = @net_modnum

		if @@RowCount > 0 
			if @stat = 2
			begin
				raiserror('该单据已经被修正，不能再冲单', 16, 1)
				return(1)
			end 
			else if @stat in (0, 7)
			begin
				if (select BATCHFLAG from SYSTEM) = 2
				     delete from STKINDTL2 where CLS = @cls and NUM = @num
				delete from STKINDTL where CLS = @cls and NUM = @num
				delete from STKIN where CLS = @cls and NUM = @num
				GOTO Next_Exit
			end
			select @pre_num = ''
	end

	while @net_modnum <> '' and @net_modnum is not null
	begin
		if @net_modnum = @net_num  break
		
		select @net_billid = max(ID), @net_num = max(NUM), @net_modnum = max(MODNUM) 
		from NSTKOUT where SRC = @src_id and NUM = @net_modnum and CLS = @net_cls
			
        if @net_billid is null
		begin
		  raiserror('接收缓冲区中以该单据开始的修正链不完整，无法接收', 16, 1)
		  return(1)
		end

		/*select @net_modnum = max(MODNUM), @net_num = max(NUM), @net_billid = max(ID)
			from NSTKOUT
			where SRC = @src_id and CLS = @net_cls and NUM = @net_modnum and STAT = 2
		if @net_num is null break*/

		select @stat = STAT, @num = NUM  from STKIN
		where CLS = @cls and SRCNUM = @net_num and SRC = @src_id

		if @@rowcount > 0
		begin
			if (@stat = 0 or @stat = 7)/*2001-11-05*/
			begin
				update STKIN
					set CHECKER = @operator, FILDATE = (case @useCurrTime when 0 then getdate() when 1 then FilDate end), SETTLENO = @cur_settleno
					where CLS = @cls and NUM = @num
				update STKINDTL
					set SETTLENO = @cur_settleno
					where CLS = @cls and NUM = @num
				execute @return_status = STKINCHK @cls, @num, 0
				if @return_status <> 0 return(@return_status)
				execute @return_status = STKINDLT @cls, @num, @operator
				if @return_status <> 0 return(@return_status)
			end
			if @stat = 1 or @stat = 6 
			begin
				execute @return_status = STKINDLT @cls, @num, @operator
				if @return_status <> 0 return(@return_status)
			end
			if @pre_num <> ''
			begin
				update STKIN
					set STAT = 3
					where CLS = @cls and NUM =
						(select max(NUM) from STKIN where STAT = 4 and MODNUM = @num)

				update STKIN
					set MODNUM = @num
					where CLS = @cls and NUM = @pre_num
			end
			break
		end

		select @max_num = MAX(NUM) from STKIN  where CLS = @cls
		if @max_num is null select @next_num = '0000000001'
			else execute NEXTBN @max_num, @next_num output
		execute @return_status = RCVONESTKIN @cls, @next_num, @net_billid, @src_id, @operator
		if @return_status <> 0 return(@return_status)
		execute @return_status = STKINCHK @cls, @next_num, 0
		if @return_status <> 0 return(@return_status)
		execute @return_status = STKINDLT @cls, @next_num, @operator
		if @return_status <> 0 return(@return_status)
		if @pre_num <> ''
		begin
			update STKIN
				set STAT = 3
				where CLS = @cls and NUM =
					(select max(NUM) from STKIN where STAT = 4 and MODNUM = @next_num)

			update STKIN
				set MODNUM = @next_num
				where CLS = @cls and NUM = @pre_num
		end

		select @pre_num = @next_num
	end
Next_Exit:
	select  @net_billid = @bill_id, @net_modnum = MODNUM 
		from NSTKOUT where ID = @bill_id and SRC = @src_id
	while (1=1)
	begin
		delete from NSTKOUT where ID = @net_billid and SRC = @src_id
		delete from NSTKOUTDTL where ID = @net_billid and SRC = @src_id
		if (select BATCHFLAG from SYSTEM) = 2
		    delete from NSTKOUTDTL2 where ID = @net_billid and SRC = @src_id
		select @net_billid = max(ID), @net_modnum = max(MODNUM) from NSTKOUT
			where SRC = @src_id and CLS = @net_cls and NUM = @net_modnum and STAT = 2
		if @net_billid is null break
	end
	return(0)
end
GO
