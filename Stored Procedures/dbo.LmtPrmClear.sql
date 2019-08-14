SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LmtPrmClear]
as
BEGIN
  declare 
  	@p_lstid		char(16),
  	@p_storegid		int

  declare c_lmtprice cursor for
  select LSTID, STOREGID from LMTPRICE where AFINISH < getdate()
  for update
  open c_lmtprice
  fetch next from c_lmtprice into @p_lstid, @p_storegid
  while @@fetch_status = 0
  begin
  	if not exists(select 1 from LMTPRICEHST where LSTID = @p_lstid and STOREGID = @p_storegid)
  	begin
		insert into LMTPRICEHST(LSTID, STOREGID, LMTCLS, GDGID, ASTART, AFINISH, QTYLMT, PRICE, SRCNUM, CANCELDATE)
		select LSTID, STOREGID, LMTCLS, GDGID, ASTART, AFINISH, QTYLMT, PRICE, SRCNUM, getdate()
			from LMTPRICE where LSTID = @p_lstid and STOREGID = @p_storegid
	end
	delete from LMTPRICE where current of c_lmtprice
	if @@error <> 0
	begin
		close c_lmtprice
		deallocate c_lmtprice
		return @@error
	end
  		
 	fetch next from c_lmtprice into @p_lstid, @p_storegid
  end
  close c_lmtprice
  deallocate c_lmtprice
END
GO
