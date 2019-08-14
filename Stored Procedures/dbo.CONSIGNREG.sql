SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[CONSIGNREG](
	@num char(10),
	@dspnum char(10)
)as
begin
	declare
	@return_status int,
	@wrh int,
	@usergid int,
	@gdgid int,
	@qty money,
	@dspqty money,
	@dspline int,
	@subwrh int,
	@acptime datetime,
	@acpemp int

	/*select @usergid = (select usergid from system)*/
	if not exists(select * from DSPREG where NUM = @num)
	begin
		raiserror('要处理的单据不存在!', 16, 1)
		return(1)
	end
	if not exists(select * from DSP where NUM = @dspnum)
	begin
		raiserror('要处理的提货单不存在!', 16, 1)
		return(1)
	end

        if (select STAT from DSP where NUM = @dspnum) = 3
        begin
        	raiserror('已作废的提货单不能再提货!', 16, 1)
		return(1)
	end

	select @wrh = WRH, @acptime = ACPTIME, @acpemp = ACPEMP
	from DSPREG where NUM = @num

	update DSP set LSTDSPTIME = @acptime, LSTDSPEMP = @acpemp
	where NUM = @dspnum

	declare c_dsp cursor for
	select GDGID, QTY, DSPLINE, SUBWRH
	from DSPREGDTL
	where NUM = @num
	and qty <> 0

	open c_dsp
	fetch next from c_dsp into
		@gdgid, @qty, @dspline, @subwrh
	while @@fetch_status = 0
	begin
		exec @return_status = DecDspQty @wrh, @gdgid, @qty, /* 00-3-3 */ @subwrh
		if @return_status <> 0 break
	        /* 00-3-3 */
		/* 2000-8-17 
		提货登记时对于货位库存的处理，目前有两种模式：
		1、装潢总汇：(-)可用库存. 虽然也-未提库存(上面5行), 但是货位的未提库存不使用
		2、华联家电（SYSTEM.BATCHFLAG=1）：(-)未提库存 */
		if ((SELECT BATCHFLAG FROM SYSTEM) <> 1) AND @subwrh is not null
		begin
			execute @return_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @qty
			if @return_status <> 0 break
		end

		update DSPDTL set
			DSPTOTAL = DSPTOTAL + (SALETOTAL - DSPTOTAL) / (SALEQTY - DSPQTY) *  @qty
		where NUM = @dspnum and LINE = @dspline

		update DSPDTL set DSPQTY = DSPQTY + @qty
		where NUM = @dspnum and LINE = @dspline

		fetch next from c_dsp into
			@gdgid, @qty, @dspline, @subwrh
	end
	close c_dsp
	deallocate c_dsp

	select @qty = sum(SALEQTY), @dspqty = sum(DSPQTY)
	from DSPDTL
	where NUM = @dspnum

	if @dspqty > 0
	begin
		if @qty > @dspqty 
			update DSP set STAT = 1
			where NUM = @dspnum
		else if @qty = @dspqty 
			update DSP set STAT = 2
			where NUM = @dspnum	
	end
	if @return_status <> 0 
	begin
		raiserror('处理单据时发生错误.', 16, 1)
		return (@return_status)
	end
end

GO
