SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCVOUTTODIR](
	@bill_id int,
	@src_id int,
	@operator int,
	@errmsg varchar(255) = '' output
) as
begin
	declare
		@ret int, @usergid int, @nm_billto int, @nm_client int,
		@cur_settleno int, @m_stat smallint, @m_num char(10),
		@nm_cls char(10), @nm_num char(10), @nm_stat smallint,
		@nm_frcchk smallint, @max_num char(10), @next_num char(10),
		@nm_modnum char(10), @prev_num char(10)
	
	set @ret = 0
	select @nm_billto = BILLTO, @nm_client = CLIENT, @nm_cls = CLS,
		@nm_num = NUM, @nm_stat = STAT, @nm_frcchk = FRCCHK,
		@nm_modnum = MODNUM
		from NSTKOUT
		where ID = @bill_id and SRC = @src_id
	select @usergid = USERGID from SYSTEM
	select @cur_settleno = max(NO) from MONTHSETTLE
	if @nm_billto <> @usergid
	begin
		set @errmsg = '不是发给本店的单据。'
		raiserror(@errmsg, 16, 1)
		return(1)
	end
	if @nm_billto = @nm_client
	begin
		set @errmsg = '本网络出货单不应被接收为直配出货单。'
		raiserror(@errmsg, 16, 1)
		return(1)
	end
	
	if @nm_stat in (1, 6)
	begin
		
		select @m_stat = STAT, @m_num = NUM from DIRALC
			where GEN = @src_id and GENBILL = 'STKOUT' and GENCLS = @nm_cls 
			and GENNUM = @nm_num and CLS = '直配出'
		if @@rowcount > 0 and @m_stat is not null
		begin
			if @m_stat in (0, 7) and @nm_frcchk = 1
			begin
				update DIRALC set 
					CHECKER = @operator, FILDATE = getdate(), SETTLENO = @cur_settleno
					where CLS = '直配出' and NUM = @m_num
				update DIRALCDTL set SETTLENO = @cur_settleno
					where CLS = '直配出' and NUM = @m_num
				exec @ret = DIRCHK '直配出', @m_num, 0, 0, @errmsg output
				if @ret <> 0 return(@ret)
			end
			else if @m_stat = 0 and @nm_frcchk = 7
			begin
				update DIRALC set 
					PRECHECKER = @operator, PRECHKDATE = getdate(), SETTLENO = @cur_settleno, STAT = 7
					where CLS = '直配出' and NUM = @m_num
				update DIRALCDTL set SETTLENO = @cur_settleno
					where CLS = '直配出' and NUM = @m_num
			end
			else
			begin
				set @errmsg = '单据已被接收过'
				raiserror(@errmsg, 16, 1)
				return(1)
			end
			
			exec DLTNSTKOUT @bill_id, @src_id
			
			return(0)
		end
		
		select @max_num = max(NUM) from DIRALC where CLS = '直配出'
		if @max_num is null 
			set @next_num = '0000000001'
		else
			exec NEXTBN @max_num, @next_num output
		exec @ret = RCVONEOUTTODIR @next_num, @bill_id, @src_id, @operator, @errmsg output
		if @ret <> 0 return(@ret)
		if @nm_frcchk = 7
		begin
			update DIRALC set 
				PRECHECKER = @operator, PRECHKDATE = getdate(), SETTLENO = @cur_settleno, STAT = 7
				where CLS = '直配出' and NUM = @next_num
			exec DLTNSTKOUT @bill_id, @src_id
			return(0)
		end
		else if @nm_frcchk = 1 or @nm_modnum is not null
		begin
			exec @ret = DIRCHK '直配出', @next_num, 0, 0, @errmsg output
			if @ret <> 0 return(@ret)
		end
		else
			set @prev_num = @next_num
		
	end
	else if @nm_stat = 4
	begin

		select @m_stat = STAT, @m_num = NUM from DIRALC
			where GEN = @src_id and GENBILL = 'STKOUT' and GENCLS = @nm_cls 
			and GENNUM = @nm_modnum and CLS = '直配出'
		if @@rowcount > 0
		begin
			if @m_stat = 2
			begin
				set @errmsg = '该单据已经被修正，不能再冲单。'
				raiserror(@errmsg, 16, 1)
				return(1)
			end
			else if @m_stat in (0, 7)
			begin
				delete from DIRALCDTL where CLS = '直配出' and NUM = @m_num
				delete from DIRALC where CLS = '直配出' and NUM = @m_num
				exec DLTNSTKOUT @bill_id, @src_id
				return(0)
			end
		end
		set @prev_num = ''

	end

	while @nm_modnum <> '' and @nm_modnum is not null
	begin
		if @nm_modnum = @nm_num break
		
		select @nm_modnum = max(MODNUM), @nm_num = max(NUM)
			from NSTKOUT
			where SRC = @src_id and CLS = @nm_cls and NUM = @nm_modnum and STAT = 2
		if @nm_num is null break
		select @m_stat = STAT, @m_num = NUM from DIRALC
			where GEN = @src_id and GENBILL = 'STKOUT' and GENCLS = @nm_cls 
			and GENNUM = @nm_num and CLS = '直配出'
		if @@rowcount > 0
		begin
			if @m_stat in (0, 7)
			begin
				update DIRALC set 
					CHECKER = @operator, FILDATE = getdate(), SETTLENO = @cur_settleno
					where CLS = '直配出' and NUM = @m_num
				update DIRALCDTL set SETTLENO = @cur_settleno
					where CLS = '直配出' and NUM = @m_num
				exec @ret = DIRCHK '直配出', @m_num, 0, 0, @errmsg output
				if @ret <> 0 return(@ret)
				exec @ret = DIRDLT '直配出', @m_num, @operator, @errmsg output
				if @ret <> 0 return(@ret)
			end
			if @m_stat in (1, 6)
			begin
				exec @ret = DIRDLT '直配出', @m_num, @operator, @errmsg output
				if @ret <> 0 return(@ret)
			end
			if @prev_num <> ''
			begin
				update DIRALC set STAT = 3
					where CLS = '直配出' and NUM =
						(select max(NUM) from DIRALC where STAT = 4 and MODNUM = @m_num)
				update DIRALC set MODNUM = @m_num
					where CLS = '直配出' and NUM = @prev_num
			end
			break
		end
		
		select @max_num = max(NUM) from DIRALC where CLS = '直配出'
		if @max_num is null 
			set @next_num = '0000000001'
		else
			exec NEXTBN @max_num, @next_num output
		exec @ret = RCVONEOUTTODIR @next_num, @bill_id, @src_id, @operator, @errmsg output
		if @ret <> 0 return(@ret)
		exec @ret = DIRCHK '直配出', @next_num, 0, 0, @errmsg output
		if @ret <> 0 return(@ret)
		exec @ret = DIRDLT '直配出', @next_num, @operator, @errmsg output
		if @ret <> 0 return(@ret)
			if @prev_num <> ''
			begin
				update DIRALC set STAT = 3
					where CLS = '直配出' and NUM =
						(select max(NUM) from DIRALC where STAT = 4 and MODNUM = @next_num)
				update DIRALC set MODNUM = @next_num
					where CLS = '直配出' and NUM = @prev_num
			end
			
		set @prev_num = @next_num
	end	
	
	exec DLTNSTKOUT @bill_id, @src_id 
	
	return(@ret) 
end
GO
