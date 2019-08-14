SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcByStoreCheck](
	@num varchar(10),
	@checker int
) as
begin
	declare
	@stat int,
	@gdgid int,
	@storegid int,
	@usergid int,
  @zbgid int,
	@qty money,
	@line int,
	@RET int,
	@opt_ASnd int,
	@dmddate datetime,
	@MSG VARCHAR(255)

	select @usergid = usergid, @zbgid = zbgid
  from system

	if not exists(select 1 from ALCBYSTORE where NUM = @num)
	begin
		raiserror('不存在要审核的单据', 16, 1)
		return(1)
	end
	if not exists(select 1 from ALCBYSTOREDTL where NUM = @num)
	begin
		raiserror('不存在要审核的单据', 16, 1)
		return(1)
	end
	if not exists(select 1 from ALCBYSTOREDTL2 where NUM = @num)
	begin
		raiserror('不存在要审核的单据', 16, 1)
		return(1)
	end

	select @dmddate = dmddate from alcbystore where num = @num
	declare I_AlcByStore cursor for
	select LINE, GDGID, QTY from ALCBYSTOREDTL where NUM = @num
	open I_AlcByStore
	fetch next from I_AlcByStore into @line, @gdgid, @qty
	while @@fetch_status = 0
	begin
		if not exists(select 1 from GOODS where GID = @gdgid)
		begin
			raiserror('单据中的商品不存在', 16, 1)
			return(1)
		end
		declare I_AlcByStore2 cursor for
		select storegid from alcbystoredtl2 where num = @num
		open I_AlcByStore2
		fetch next from I_AlcByStore2 into @storegid
		while @@fetch_status = 0
		begin
			if @usergid = @zbgid
			  exec PsrAlcUpdAlcPool @storegid, @gdgid, @qty, @dmddate, '采配按门店', @num, @line

			fetch next from I_AlcByStore2 into @storegid
		end
		close I_AlcByStore2
		deallocate I_AlcByStore2

		fetch next from I_AlcByStore into @line, @gdgid, @qty
	end
	close I_AlcByStore
	deallocate I_AlcByStore

	UPDATE ALCBYSTORE set STAT = 1, CHECKER = @checker, FILDATE = getdate() where NUM = @num

	exec OPTREADINT 497, 'AutoSnd', 0, @opt_ASnd output
  if @usergid <> @zbgid and @opt_ASnd = 1
	begin
	  exec @RET = AlcByStoreSnd @num, null, 0, 0, @msg output
	  if @RET <> 0
      begin
        raiserror(@msg, 16, 1)
        return(1)
      end
	end

	return 0
end
GO
