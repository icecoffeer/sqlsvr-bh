SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RealExchgDataSnd](
    @SendedDate    datetime,
    @receiver        int,
    @ErrMessage varchar(100) output
) as
begin
	declare @zbgid int,
		@usergid int
	select @usergid = usergid,@ZBGID = zbgid from system

	delete from NRealExchgData 
		where RecvDate = @SendedDate and Rcv = @Receiver and tgt = @usergid and ntype = 0
        
	delete from NRealExchgDataDtl 
		where RecvDate = @Sendeddate and rcv = @receiver and tgt = @Usergid
        
	update RealExchgData
		set lstSndTime = getdate()
		where RecvDate = @SendedDate and src = @receiver and tgt = @usergid
        
	insert into NRealExchgDataDtl(RecvDate,cls,num,rcv, src, tgt, Checkint1,
		Checkint2 , Checkint3, Checkdata1, Checkdata2,
		Checkdata3)
	select RecvDate,cls,num,@receiver, src, tgt, Checkint1,
		Checkint2 , Checkint3, Checkdata1, Checkdata2,
		Checkdata3  from RealExchgDataDtl
		 where RecvDate = @SendedDate and src = @receiver and tgt = @usergid
        
	insert into NRealExchgData(RecvDate,src,Tgt,rcv,reccnt,ntype,sendtime)
		select RecvDate,src,tgt,@receiver,reccnt,0,getdate() 
			from RealExchgData 
			where RecvDate = @sendedDate and tgt = @usergid and src = @receiver
	if (@receiver <> @ZBGID) and (@usergid <> @ZBGID)
	begin
		delete from NRealExchgData 
			where RecvDate = @SendedDate and Rcv = @ZBGID and src = @receiver and tgt = @usergid and ntype = 0
        
		delete from NRealExchgDataDtl 
			where RecvDate = @Sendeddate and rcv = @ZBGID and src = @receiver and tgt = @Usergid
        
		insert into NRealExchgDataDtl(RecvDate,cls,num, rcv, src, tgt, Checkint1,
			Checkint2 , Checkint3, Checkdata1, Checkdata2,
			Checkdata3)
		select RecvDate,cls,num,@ZBGID, src, tgt, Checkint1,
			Checkint2 , Checkint3, Checkdata1, Checkdata2,
			Checkdata3 from RealExchgDataDtl
			 where RecvDate = @SendedDate and src = @receiver and tgt = @usergid
        
		insert into NRealExchgData(RecvDate,src,Tgt,rcv,reccnt,ntype,sendtime)
			select RecvDate,src,tgt,@ZBGID,reccnt,0,getdate() 
				from RealExchgData 
				where RecvDate = @sendedDate and tgt = @usergid and src = @receiver
	end
	return 0
end
GO
