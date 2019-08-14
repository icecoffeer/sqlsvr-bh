SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrdUpdAlcPool](
	@num char(10) 
) with encryption as
begin
	declare
	@return_status int,
	@stat smallint,
	@finish smallint,
	@line int,
	@ordline int,
	@usergid int,	
	@gdgid int,
	@wrh int,
	@qty money,
	@price money,
	@ordsrc int, 
	@usealcpool int,
	@allocordonly int,
	@property int,
	@vendor int,
	@receiver int,
	@ifusezero int,
	@HQOrderInAlcPool int
	
	exec OPTREADINT 0, 'UseAlcPool', 0, @usealcpool output
	if @usealcpool = 0 return(0)

	select @usergid = USERGID from SYSTEM
	select @ordsrc = SRC, @vendor = vendor, @receiver = receiver from ORD where num = @num
	select @property = property from store(nolock) where gid = @usergid

	if (@property & 8 <> 8) and (@property & 16 <> 16) return 0  --本单位非总部或配货中心则不处理定单

	if @ordsrc = @usergid --如果是本单位的定单，则由选项决定是否进佩货池
	begin
		exec OptReadInt 0, 'HQOrderInAlcPool', 0, @HQOrderInAlcPool output
		if @HQOrderInAlcPool = 0 return 0  --配货池处理总部统配定单
	end
    
	exec OptReadInt 0, 'AllocOrdOnly', 0, @allocordonly output	/*2002.05.19是否只处理统配定单*/
	if @allocordonly = 1
	begin
		if (@vendor <> @usergid) or (@receiver = @usergid) or ((@property & 8) <> 8)
		  return 0
	end
	
	select @stat=STAT, @finish = FINISHED from ORD where NUM = @num		
	
	if (@stat = 1 ) and (@finish = 0)
	begin
	    declare ord_alc cursor for
	        select LINE,GDGID, QTY from ORDDTL where NUM = @num and FLAG = 0	
	    open ord_alc
	    fetch next from ord_alc into 
		@ordline, @gdgid, @qty
	    while @@fetch_status = 0
	    begin
	        select @line = max(line) from ALCPOOL(nolock) where STOREGID = @receiver and GDGID = @gdgid
	        if @line is null 
	            select @line = 1
	        else 
	            select @line = @line + 1
	        
		exec OptReadInt 499, 'OrdUpdQty', 0, @ifusezero output
		if @ifusezero = 0 
		    	insert into ALCPOOL (STOREGID, GDGID, LINE, QTY, SRCQTY, DMDDATE, SRCGRP, 
			    SRCBILL, SRCCLS, SRCNUM, SRCLINE, ORDTIME)
		    	values (@receiver, @gdgid, @line, @qty, @qty, convert(char(10), getdate(), 102), 2, 
		    	'连锁定单', null, @num, @ordline, GETDATE())
		else
		    	insert into ALCPOOL (STOREGID, GDGID, LINE, QTY, SRCQTY, DMDDATE, SRCGRP, 
			    SRCBILL, SRCCLS, SRCNUM, SRCLINE, ORDTIME)
		    	values (@receiver, @gdgid, @line, 0, @qty, convert(char(10), getdate(), 102), 2, 
		    	'连锁定单', null, @num, @ordline, GETDATE())
	        fetch next from ord_alc into 
		    @ordline, @gdgid, @qty
	    end
	    close ord_alc
	    deallocate ord_alc
	    return(0)
	end
	if (@stat = 1) and (@finish = 1)
	begin
	    if exists(select * from ALCPOOL where SRCNUM = @num and SRCCLS is null 
	    	and SRCBILL = '连锁定单' and SRCGRP = 2 and STOREGID = @receiver)/*2003.07.15*/
	    begin
	    	delete from ALCPOOL where SRCNUM = @num and SRCCLS is null 
	    	and SRCBILL = '连锁定单' and SRCGRP = 2 and STOREGID = @receiver/*2003.07.15*/
	    end
	end
	if (@stat = 2)
	begin
	    if exists(select * from ALCPOOL where SRCNUM = @num and SRCCLS is null 
	    	and SRCBILL = '连锁定单' and SRCGRP = 2 and STOREGID = @receiver)/*2003.07.15*/
	    begin
	    	delete from ALCPOOL where SRCNUM = @num and SRCCLS is null 
	    	and SRCBILL = '连锁定单' and SRCGRP = 2 and STOREGID = @receiver/*2003.07.15*/
	    end
	end
end
GO
