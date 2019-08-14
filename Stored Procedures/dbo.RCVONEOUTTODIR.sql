SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCVONEOUTTODIR](
	@new_num char(10),
	@bill_id int,
	@src_id int,
	@operator int,
	@errmsg varchar(255) = '' output
) as
begin
	declare
		@ret int, @cur_settleno int, @nm_num char(10),
		@nm_checker int, @m_checker int, @nm_stat smallint,
		@m_total money, @m_tax money, @usergid int,
		@m_wrh int, @d_line smallint, @d_gdgid int,
		@d_cases money, @d_qty money, @d_price money,
		@d_total money, @d_tax money, @d_validdate datetime,
		@d_wrh int, @lgid int, @rstwrh smallint,
		@d_inprc money, @d_rtlprc money, @d_wsprc money,
		@g_saletax money, @d_outtax money, @m_outtax money
	
	set @ret = 0
	select @cur_settleno = max(NO) from MONTHSETTLE
	select @usergid = USERGID, @rstwrh = RSTWRH from SYSTEM
	select @nm_num = NUM, @nm_checker = CHECKER, @nm_stat = STAT
		from NSTKOUT where SRC = @src_id and ID = @bill_id
	if @nm_stat not in (1, 2, 6)
	begin
		set @errmsg = '网络单据' + @nm_num + '是不可接收单据。'
		raiserror(@errmsg, 16, 1)
		return(1)
	end
	if not exists (select GID from STORE where GID = @src_id)
	begin
		set @errmsg = '网络单据' + @nm_num + '的来源单位的资料尚未转入。'
		raiserror(@errmsg, 16, 1)
		return(1)
	end
	select @m_checker = b.GID from EMPXLATE a, EMPLOYEEH b
		where a.NGID = @nm_checker and a.LGID = b.GID
	if @@rowcount = 0 or @m_checker is null
	begin
		set @errmsg = '网络单据' + @nm_num + '的审核人的员工资料尚未转入。'
		raiserror(@errmsg, 16, 1)
		return(1)
	end
	
	set @m_total = 0
	set @m_tax = 0
	set @m_outtax = 0
	declare c_otd cursor for
		select LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH
		from NSTKOUTDTL
		where ID = @bill_id and SRC = @src_id
	open c_otd
	fetch next from c_otd into @d_line, @d_gdgid, @d_cases, @d_qty, @d_price, 
		@d_total, @d_tax, @d_validdate, @d_wrh
	while @@fetch_status = 0
	begin
		set @lgid = null
		select @d_inprc = INPRC, @d_rtlprc = RTLPRC, @lgid = a.GID, 
			@d_wsprc = WHSPRC, @g_saletax = SALETAX
			from GOODSH a, GDXLATE b
			where b.NGID = @d_gdgid and b.LGID = a.GID
		if @@rowcount = 0 or @lgid is null
		begin
			set @errmsg = '网络单据' + @nm_num + '中第'
				+ convert(varchar, @d_line) + '行的商品资料尚未转入。'
			raiserror(@errmsg, 16, 1)
			set @ret = 1
			break      
		end
		
		if @d_wrh = 1 select @d_wrh = WRH from GOODS where GID = @lgid
		
		if not exists (select 1 from VDRGD
			where VDRGID = @src_id and GDGID = @lgid and WRH = @d_wrh)
		begin
			/* 如果VDRGD中不存在对应的关系 */
			if @rstwrh = 1
			begin
				/* 当SYSTEM.RSTWRH=1时,拒绝接收 */
				set @errmsg = '网络单据' + @nm_num + '中第' + convert(varchar, @d_line) +
					'行的商品不是该单据的供应商提供或不属于指定的仓位。'
				raiserror(@errmsg, 16, 1)
				set @ret = 1
				break
			end
			else
				/* 当SYSTEM.RSTWRH=0时,加入VDRGD */
				insert into VDRGD(VDRGID, GDGID, WRH)
					values (@src_id, @lgid, @d_wrh)
		end
		
		set @d_outtax = @d_total * @g_saletax / (100 + @g_saletax)
		
		insert into DIRALCDTL (CLS, NUM, LINE, SETTLENO, GDGID,
			WRH, CASES, QTY, LOSS, PRICE,
			TOTAL, TAX, ALCPRC, ALCAMT, WSPRC,
			INPRC, RTLPRC, VALIDDATE, BCKQTY, PAYQTY,
			BCKAMT, PAYAMT, BNUM, SUBWRH, OUTTAX,
			RCPQTY, RCPAMT, NOTE)
			values ('直配出', @new_num, @d_line, @cur_settleno, @lgid,
			@d_wrh, @d_cases, @d_qty, 0, @d_price,
			@d_total, @d_tax, @d_price, @d_total, @d_wsprc,
			@d_inprc, @d_rtlprc, @d_validdate, 0, 0,
			0, 0, null, null, @d_outtax,
			0, 0, null)
		set @m_total = @m_total + @d_total
		set @m_tax = @m_tax + @d_tax
		set @m_outtax = @m_outtax + @d_outtax
		
		fetch next from c_otd into @d_line, @d_gdgid, @d_cases, @d_qty, @d_price, 
			@d_total, @d_tax, @d_validdate, @d_wrh
	end
	close c_otd
	deallocate c_otd
	
	if @ret = 0
	begin
		set @m_wrh = 1
		if @rstwrh = 1
		begin
			if (select count(distinct WRH) from DIRALCDTL 
				where CLS = '直配出' and NUM = @new_num) > 1
			begin
				set @errmsg = '网络单据' + @nm_num + '中存在不同仓位的商品。'
				raiserror(@errmsg, 16, 1)
				return(1)
			end
			select @m_wrh = min(WRH) from DIRALCDTL where CLS = '直配出' and NUM = @new_num
		end
		insert into DIRALC (CLS, NUM, ORDNUM, SETTLENO, VENDOR,
			SENDER, RECEIVER, OCRDATE, PSR, TOTAL,
			TAX, ALCTOTAL, STAT, SRC, SRCNUM,
			SRCORDNUM, SNDTIME, NOTE, RECCNT, FILLER,
			CHECKER, MODNUM, VENDORNUM, FILDATE, FINISHED,
			PRNTIME, CHKDATE, WRH, GEN, GENBILL,
			GENCLS, GENNUM, PRECHECKER, PRECHKDATE, SLR,
			OUTTAX, RCPFINISHED, FROMNUM, FROMCLS)
			select '直配出', @new_num, null, @cur_settleno, @src_id,
			BILLTO, CLIENT, OCRDATE, @operator, @m_total,
			@m_tax, @m_total, 0, @usergid, null, 
			null, null, NOTE, RECCNT, @m_checker, 
			@operator, null, NUM, FILDATE, 0,
			null, null, @m_wrh, @src_id, 'STKOUT',
			CLS, NUM, null, null, @operator,
			@m_outtax, 0, null, null
			from NSTKOUT
			where SRC = @src_id and ID = @bill_id
	end
	
	return(@ret)
end
GO
