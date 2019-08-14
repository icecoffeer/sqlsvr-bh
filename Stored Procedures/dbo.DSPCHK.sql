SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DSPCHK](
	@num char(10)
)as
begin
	declare
	@return_status int,
	@wrh int,
	@usergid int,
	@gdgid int,
	@saleqty money,
  @saleprice money,
  /* 00-3-3 */
  @subwrh int


	if not exists(select * from DSP where NUM = @num)
	begin
		raiserror('要处理的单据不存在!', 16, 1)
		return(1)
	end

	select @wrh = WRH from DSP where NUM = @num

	declare c_dsp cursor for
  select GDGID, SALEQTY, SALEPRICE, /* 00-3-3 */SUBWRH
	from DSPDTL
	where NUM = @num

	open c_dsp
	fetch next from c_dsp into
	@gdgid, @saleqty, @saleprice, /* 00-3-3 */@subwrh

	while @@fetch_status = 0
	begin
	  execute IncDspQty @wrh, @gdgid, @saleqty, /* 00-3-3 */ @subwrh
--		execute @return_status = UNLOAD @wrh, @gdgid, @saleqty, @saleprice, null/*2003.04.29*/
--		if @return_status <> 0 break

    /* 00-3-3 */
--    if @subwrh is not null
--      execute @return_status = UNLOADSUBWRH @WRH, @subwrh, @gdgid, @saleqty
--    if @return_status <> 0 break

		fetch next from c_dsp into
		@gdgid, @saleqty, @saleprice, /* 00-3-3 */@subwrh
	end
	close c_dsp
	deallocate c_dsp

  if @return_status <> 0
	begin
		raiserror('处理单据时发生错误.', 16, 1)
		return (@return_status)
	end
end
GO
