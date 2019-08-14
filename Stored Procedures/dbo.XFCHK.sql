SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[XFCHK]
  @num char(10),
  @chgwrh smallint = 0, -- 0 = 不改默认仓位,1=更改默认仓位为调入仓位
  @mode smallint = 1,  -- 2000-08-31 1=审核；2=发货；4=收货
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200)='' output
as
begin
	/*
	@oldstat	@mode	action			@newstat
	0			1		审核				1
				3		审核, 发货		8
				7		审核, 发货, 收货	9
	1			2		发货				8
				6		发货, 收货		9
	8			4		收货				9
	*/
	declare
		@stat smallint, @return_status int,
		@curdate datetime, @cursettleno int, @batchflag smallint,
		@stat_str char(6),
		@FromWrh int, @ToWrh int  --ShenMin

	select @stat=stat, @FromWrh = FROMWRH, @ToWrh = TOWRH from xf where num=@num
	select @cursettleno = max(NO) from MONTHSETTLE
	select @curdate = convert(datetime, convert(char, getdate(), 102))
	select @batchflag=batchflag from system

  --ShenMin
  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'XF', @piCls = '', @piNum = @num, @piToStat = 1, @piOper = @Oper, @piWrh = @FromWrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return(1)
    end
  exec @return_status = WMSFILTER 'XF', @piCls = '', @piNum = @num, @piToStat = 1, @piOper = @Oper, @piWrh = @ToWrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return(1)
    end

	if @stat=0 and @mode=1
	begin
		execute @return_status=xfchk_check @num, @curdate, @cursettleno, @batchflag, @errmsg
		if @return_status<>0 return(@return_status)
		select @stat = 1
	end	else if @stat=0 and @mode=3
	begin
		execute @return_status=xfchk_check @num, @curdate, @cursettleno, @batchflag, @errmsg
	  	if @return_status <> 0 return(@return_status)
  		execute @return_status=xfchk_deliver @num
	  	if @return_status <> 0 return(@return_status)
		select @stat = 8
	end else if @stat=0 and @mode=7
	begin
		execute @return_status=xfchk_check @num, @curdate, @cursettleno, @batchflag, @errmsg
	  	if @return_status <> 0 return(@return_status)
  		execute @return_status=xfchk_deliver @num
	  	if @return_status <> 0 return(@return_status)
		execute @return_status=xfchk_receive @num, @chgwrh, @curdate, @cursettleno, @batchflag, @errmsg
		if @return_status <> 0 return(@return_status)
		select @stat = 9
	end else if @stat=1 and @mode=2
	begin
		execute @return_status=xfchk_deliver @num
	  	if @return_status <> 0 return(@return_status)
		select @stat = 8
	end else if @stat=1 and @mode=6
	begin
		execute @return_status=xfchk_deliver @num
	  	if @return_status <> 0 return(@return_status)
		execute @return_status=xfchk_receive @num, @chgwrh, @curdate, @cursettleno, @batchflag, @errmsg
		if @return_status <> 0 return(@return_status)
		select @stat = 9
	end else if @stat=8 and @mode=4
	begin
		execute @return_status=xfchk_receive @num, @chgwrh, @curdate, @cursettleno, @batchflag, @errmsg
		if @return_status <> 0 return(@return_status)
		select @stat = 9
	end else
	begin
		select @errmsg=''
		if (@mode & 1) <> 0 select @errmsg=@errmsg+'审核'
		if @mode & 2 <> 0
		begin
			if @errmsg <> '' select @errmsg=@errmsg+','
			select @errmsg=@errmsg+'发货'
		end
		if @mode & 4 <> 0
		begin
			if @errmsg <> '' select @errmsg=@errmsg+','
			select @errmsg=@errmsg+'收货'
		end
		select @stat_str = case
		                      when @stat = 9 then '已收货'
		                      when @stat = 8 then '已发货'
		                      when @stat = 1 then '已审核'
		                      else ''
		                   end
		                  --Added by Jianweicheng 2002.09.16 任务单:2002091638323
		select @errmsg='在'+@stat_str+'状态下不能执行'+@errmsg+'命令.'
		return(1030)
	end

	/* 2000-10-16 */
	if (@mode & 1) <> 0
		update XF set FILDATE = getdate() where NUM = @num
	if (@mode & 2) <> 0
		update XF set OUTDATE = getdate() where NUM = @num
	if (@mode & 4) <> 0
		update XF set INDATE = getdate() where NUM = @num

	update XF set STAT = @stat, SETTLENO = @cursettleno
	where NUM = @num

	return(0)
end
GO
