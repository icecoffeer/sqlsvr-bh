SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ShouldExchgDataRcv](
    @SendDate    datetime,
    @src         int,
    @tgt	 int,
    @ErrMsg	 varchar(255) output
) with encryption as
begin
	declare 
		@usergid int,@ZBGID int,@rcv int
		,@reccnt int

	select @usergid = usergid ,@ZBGID = ZBGID from system
	if (select reccnt from nshouldexchgdata 
		where senddate = @SendDate and src = @src and tgt = @tgt and ntype = 1)
		<> (select count(*) from nshouldexchgdatadtl 
		where senddate = @SendDate and src = @src and tgt = @tgt )
        begin
		select @ErrMsg = '应收清单汇总记录中的记录数与应收清单明细记录的汇总数不一致。'
		return -1
	end
	select @rcv = rcv from NShouldExchgData
		where senddate = @SendDate and src = @src and tgt = @tgt and ntype = 1
	if @@RowCount = 0
	begin
		select @ErrMsg = '应收清单在网络缓冲中不存在。'
		return -1
	end

	if @usergid <> @rcv 
	begin
		select @ErrMsg = '不能接收[交换数据清单]的接收方不是本单位的记录。'
		return -1
	end
	select @reccnt = reccnt from ShouldExchgData where senddate = @SendDate 
		and src = @src and tgt = @tgt
	if @@RowCount <> 0
	begin
		if @Reccnt = (select reccnt from NShouldExchgData 
			where senddate = @senddate and src = @src and tgt = @tgt and ntype = 1)
		begin
		     delete from nShouldExchgDataDtl 
			     where senddate = @SendDate and rcv = @usergid and src = @src and tgt = @tgt
		     delete from nshouldExchgData 
			where senddate = @senddate and rcv = @usergid and src = @src and tgt = @tgt and ntype = 1
		     return 0
		end
		else
		begin
		     delete from ShouldExchgDataDtl 
		     where senddate = @SendDate and src = @src and tgt = @tgt
		     delete from shouldExchgData 
			where senddate = @senddate and src = @src and tgt = @tgt
		end
	end

	insert into ShouldExchgDataDtl(senddate,cls,num,src,tgt,checkint1,checkint2,checkint3,checkdata1,checkdata2,checkdata3)
	select senddate,cls,num,src,tgt,checkint1,checkint2,checkint3,checkdata1,checkdata2,checkdata3 
		from NShouldExchgDataDtl
		where senddate = @SendDate and src = @src and tgt = @tgt and rcv = @usergid
	insert into ShouldExchgData(Senddate,src,tgt,reccnt)
	select senddate,src,tgt,reccnt from NShouldExchgData 
		where  senddate = @SendDate and src = @src and tgt = @tgt and rcv = @usergid and ntype = 1
	if @@error <> 0
	begin
		select @Errmsg ='插入明细纪录出错'
		return -1
	end

        delete from nShouldExchgDataDtl 
	     where senddate = @SendDate and rcv = @usergid and src = @src and tgt = @tgt
	delete from nshouldExchgData 
		where senddate = @senddate and rcv = @usergid and src = @src and tgt = @tgt and ntype = 1
	return(0)

end
GO
