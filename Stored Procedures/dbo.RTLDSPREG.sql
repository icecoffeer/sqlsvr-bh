SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLDSPREG](
    @p_num char(10),
    @p_oper int
)as
begin
	declare 
		@oper int,	@max_num char(10),	@settleno int,
		@dspline int,	@gdgid int,		@qty money,	
		@subwrh int,	@invqty money,		@subqty money,	
		@wrh int,	@invnum char(10),	@reccnt int,
		@store int,	@return_status int

	if not exists(select * from DSP where NUM = @p_num)
	begin
		raiserror('要处理的提货单不存在!', 16, 1)
		return(1)
	end

        if (select STAT from DSP where NUM = @p_num) in (2, 3)
        begin
        	raiserror('已全部提货或已作废的提货单不能再提货!', 16, 1)
		return(1)
	end

	select @store = USERGID from SYSTEM
	select @settleno = max(NO) from MONTHSETTLE

        select @max_num = max(NUM) from DSPREG
        if @max_num is null
            select @max_num = '0000000001'
        else
            execute NEXTBN @max_num, @max_num output

	select @oper = LGID from EMPXLATE where NGID = @p_oper
	if @oper is null select @oper = @p_oper

	select @wrh = WRH, @invnum = INVNUM, @reccnt = RECCNT 
	from DSP where NUM = @p_num

	insert into DSPREG (NUM, SETTLENO, FILDATE, FILLER, WRH, INVNUM, ACPTIME, ACPEMP, OPER, RECCNT, DSPNUM, NOTE)
	values( @max_num, @settleno, getdate(), @oper, @wrh, @invnum, getdate(), @oper, @oper, @reccnt, @p_num, null)

	declare c_dspregdtl cursor for 
	select LINE, GDGID, SALEQTY - DSPQTY QTY, SUBWRH
	from DSPDTL where NUM = @p_num

	open c_dspregdtl
	fetch next from c_dspregdtl into 
		@dspline, @gdgid, @qty, @subwrh
	while @@fetch_status = 0
	begin
		select @invqty = isnull(sum(QTY + isnull(DSPQTY, 0) + isnull(BCKQTY, 0)),0) from INV
		where WRH = @wrh and GDGID = @gdgid and STORE = @store

		select @subqty = null
		select @subqty = QTY + isnull(DSPQTY, 0) + isnull(BCKQTY, 0) from SUBWRHINV
		where GDGID = @gdgid and SUBWRH = @subwrh
		if @subqty is null select @subqtY = 0

		insert into DSPREGDTL (NUM, LINE, SETTLENO, DSPLINE, GDGID, AVAQTY, 
			QTY, SUBWRH, NOTE, INVQTY, SUBQTY)
		values (@max_num, @dspline, @settleno, @dspline, @gdgid, @qty, 
			@qty, @subwrh, null, @invqty, @subqty)

		fetch next from c_dspregdtl into 
			@dspline, @gdgid, @qty, @subwrh
	end
	close c_dspregdtl
	deallocate c_dspregdtl

	exec @return_status = CONSIGNREG @max_num, @p_num
	if @return_status <> 0 
	begin
		raiserror('调用提货登记 CONSIGNREG 存储过程返回失败.', 16, 1)
		return (@return_status)
	end
	
	/* 2000-10-14 */
	update DSP set LSTDSPTIME = getdate(), LSTDSPEMP = @p_oper
	  where NUM = @p_num

	return (0)
end
GO
