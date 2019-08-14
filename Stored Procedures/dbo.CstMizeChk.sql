SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CstMizeChk]
  @num char(10),
  @mode smallint = 1,  -- 1=审核；2=批准；4=收款 
  @errmsg varchar(200)='' output
as
begin
	/*
	@oldstat	@mode	action			@newstat
	0		1	审核			1
			3	审核, 批准		11
			7	审核, 批准, 收款	12
	1		2	批准			11
			6	批准, 收款		12
	11		4	收款			12
	*/
	declare 
		@stat smallint, @src int, @store int, @ret_status int, 
		@curdate datetime, @cursettleno int
	
	select @stat=stat, @src=src from CstMize where num=@num
	select @cursettleno = max(NO) from MONTHSETTLE
	select @curdate = convert(datetime, convert(char, getdate(), 102))
        select @store = UserGid from system

	if @stat=0 and @mode=1 
	begin
		execute @ret_status=CstMizeChk_check @num, @curdate, @cursettleno, @errmsg
		if @ret_status<>0 return(@ret_status)
		select @stat = 1
	end	
	else if @stat=0 and @mode=3
	begin
             if @src = @store
             begin
		execute @ret_status=CstMizeChk_check @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
  		execute @ret_status=CstMizeChk_confirm @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
             end
		select @stat = 11
	end 
	else if @stat=0 and @mode=7
	begin
		execute @ret_status=CstMizeChk_check @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
  		execute @ret_status=CstMizeChk_confirm @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
		execute @ret_status=CstMizeChk_Gathering @num, 1, @curdate, @cursettleno, @errmsg
		if @ret_status <> 0 return(@ret_status)
		select @stat = 12
	end else if @stat=1 and @mode=2
	begin
		execute @ret_status=CstMizeChk_confirm @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
		select @stat = 11
	end else if @stat=10 and @mode=2 
	begin
             if @src = @store
             begin
		execute @ret_status=CstMizeChk_confirm @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
             end
		select @stat = 11
	end else if @stat=1 and @mode=6
	begin
		execute @ret_status=CstMizeChk_confirm @num, @curdate, @cursettleno, @errmsg
	  	if @ret_status <> 0 return(@ret_status)
		execute @ret_status=CstMizeChk_Gathering @num, 1, @curdate, @cursettleno, @errmsg
		if @ret_status <> 0 return(@ret_status)
		select @stat = 12
	end else if @stat=11 and @mode=4
	begin
		execute @ret_status=CstMizeChk_Gathering @num, 1, @curdate, @cursettleno, @errmsg
		if @ret_status <> 0 return(@ret_status)
		select @stat = 12
	end else
	begin
		select @errmsg=''
		if (@mode & 1) <> 0 select @errmsg=@errmsg+'审核'
		if @mode & 2 <> 0 
		begin
			if @errmsg <> '' select @errmsg=@errmsg+','
			select @errmsg=@errmsg+'批准'
		end
		if @mode & 4 <> 0 
		begin
			if @errmsg <> '' select @errmsg=@errmsg+','
			select @errmsg=@errmsg+'收款'
		end
		select @errmsg='在状态'+ltrim(rtrim(convert(char,@stat)))+'下不能执行'+@errmsg+'命令.'
		return(1010)
	end
	
	/* 2000-10-16 */
	if (@mode & 1) <> 0 
		update CstMize set CHKDATE = getdate() where NUM = @num
	if (@mode & 2) <> 0 
		update CstMize set CFMDATE = getdate() where NUM = @num
	if (@mode & 4) <> 0 
		update CstMize set GATHDATE = getdate() where NUM = @num
	
	update CstMize set STAT = @stat, SETTLENO = @cursettleno
	where NUM = @num

	return(0)
end
GO
