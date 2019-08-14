SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTAGMSND](
    @p_num char(10),
    @p_frcchk smallint
)as
begin
	declare
		@p_stat int,
		@p_src int,
		@p_usergid int,
		@p_storegid int,
		@p_netbillid int,
		@p_settleno smallint,
		@p_vendor int,
		@p_fildate datetime,
		@p_filler int,
		@p_checker int,
		@p_reccnt int,
		@p_note varchar(255),
		@p_date datetime
		
		
	select @p_usergid = USERGID from SYSTEM(nolock)
	select
		@p_stat = STAT,
		@p_src	= SRC,
		@p_settleno = SETTLENO,
		@p_vendor = VENDOR,
		@p_fildate = FILDATE,
		@p_filler = FILLER,
		@p_checker = CHECKER,
		@p_reccnt = RECCNT,
		@p_note = NOTE		
	from GFTAGM(nolock) where NUM = @p_num
	select @p_date = getdate()
	
	if @p_stat <> 1
    begin
        raiserror('待发送协议不是已审核协议。', 16, 1)
        return(1)
    end
    if @p_src <> @p_usergid and @p_src <> 1
    begin
        raiserror('待发送协议不是本单位产生的协议。', 16, 1)
        return(2)
    end
    
    if object_id('c_gift') is not null deallocate c_gift
    declare c_gift cursor for
    	select storegid from GFTAGMLACDTL(nolock)
    	where NUM = @p_num
    	for read only
    open c_gift
    fetch next from c_gift into @p_storegid
    while @@fetch_status = 0
    begin
        execute GetNetBillId @p_netbillid output
        
        insert into NGFTAGM(ID, NUM, SETTLENO, VENDOR, FILDATE, FILLER, CHECKER,
        	RECCNT, NSTAT, NOTE, SRC, SNDTIME, RCV, FRCCHK, TYPE)
        values(@p_netbillid, @p_num, @p_settleno, @p_vendor, @p_fildate, @p_filler,
        	@p_checker, @p_reccnt, 0, @p_note, @p_usergid, @p_date, @p_storegid,
        	@p_frcchk, 0)       	
        	
        insert into NGFTAGMDTL(SRC, ID, NUM, LINE, START, FINISH, GDGID, INQTY, GFTGID,
        	GFTQTY, GFTLINE, STAT, LSTID, GFTWRH)
        select @p_usergid, @p_netbillid, @p_num, LINE, START, FINISH, GDGID, INQTY, GFTGID,
        	GFTQTY, GFTLINE, STAT, LSTID, GFTWRH
        from GFTAGMDTL(nolock) where NUM = @p_num
        
        update GFTAGM set SNDTIME = @p_date where num = @p_num
    	
	    fetch next from c_gift into @p_storegid
    end
    close c_gift
    deallocate c_gift
    
    return (0)
end
GO
