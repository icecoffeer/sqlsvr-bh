SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RealExchgDataRcv](
    @SendDate    datetime,
    @src         int,
    @tgt	 int,
    @ErrMsg	 varchar(255) output
)  as
begin
	declare 
		@usergid int,@ZBGID int,@rcv int


	select @usergid = usergid ,@ZBGID = ZBGID from system

	if (select reccnt from nRealexchgdata 
		where Recvdate = @SendDate and src = @src and tgt = @tgt and ntype = 1)
		<> (select count(*) from nRealexchgdatadtl 
		where Recvdate = @SendDate and src = @src and tgt = @tgt )
        begin
		select @ErrMsg = '实收清单汇总记录中的记录数与实收清单明细记录的汇总数不一致。'
		return -1
	end;

	select @rcv = rcv from NRealExchgData
		where RecvDate = @SendDate and src = @src and tgt = @tgt and ntype = 1
	if @@RowCount = 0
	begin
		select @ErrMsg = '实收清单在网络缓冲中不存在。'
		return -1
	end

	if @usergid <> @rcv 
	begin
		select @ErrMsg = '不能接收[交换数据清单]的接收方不是本单位的记录。'
		return -1
	end

	if exists ( select 1 from  RealExchgData where RecvDate = @SendDate 
		and src = @src and tgt = @tgt)
	begin
	     delete from RealExchgDataDtl 
	     where RecvDate = @SendDate and src = @src and tgt = @tgt
	     delete from RealExchgData 
		where RecvDate = @senddate and src = @src and tgt = @tgt
	end

	insert into RealExchgDataDtl(RecvDate,cls,num,src,tgt,checkint1,checkint2,checkint3,checkdata1,checkdata2,checkdata3)
	select RecvDate,cls,num,src,tgt,checkint1,checkint2,checkint3,checkdata1,checkdata2,checkdata3 
		from NRealExchgDataDtl
		where RecvDate = @SendDate and src = @src and tgt = @tgt and rcv = @usergid
	insert into RealExchgData(RecvDate,src,tgt,reccnt)
	select RecvDate,src,tgt,reccnt from NRealExchgData 
		where  RecvDate = @SendDate and src = @src and tgt = @tgt and rcv = @usergid and ntype = 1
	if @@error <> 0
	begin
		select @Errmsg ='插入明细纪录出错'
		return -1
	end

	delete from nRealExchgDataDtl 
		where RecvDate = @SendDate and rcv = @usergid and src = @src and tgt = @tgt
	delete from nRealExchgData 
	--	where RecvDate = @senddate and @rcv = @usergid and src = @src and tgt = @tgt and ntype = 1
	        where RecvDate = @senddate and  rcv = @usergid and src = @src and tgt = @tgt and ntype = 1
	return(0)

end
GO
