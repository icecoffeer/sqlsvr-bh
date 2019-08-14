SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ShouldExchgDataSnd](
    @SendedDate    datetime,
    @receiver        int,
    @ErrMessage varchar(100) output
) with encryption as
begin
	declare @zbgid int,
		@usergid int
	select @usergid = usergid,@ZBGID = zbgid from system

	delete from NShouldExchgData 
		where SendDate = @SendedDate and Rcv = @Receiver and tgt = @receiver and src = @usergid and ntype = 0

	delete from NShouldExchgDataDtl 
		where SendDate = @Sendeddate and rcv = @receiver and tgt = @receiver and src = @Usergid

	update ShouldExchgData
		set lstSndTime = getdate()
		where senddate = @SendedDate and tgt = @receiver and src = @usergid

	insert into NShouldExchgDataDtl(SendDate,cls,num,rcv, src, tgt, Checkint1,
		Checkint2 , Checkint3, Checkdata1, Checkdata2,
		Checkdata3)
	select SendDate,cls,num,@receiver, src, tgt, Checkint1,
		Checkint2 , Checkint3, Checkdata1, Checkdata2,
		Checkdata3  from ShouldExchgDataDtl
		 where senddate = @SendedDate and tgt = @receiver and src = @usergid

	insert into NShouldExchgData(SendDate,src,Tgt,rcv,reccnt,ntype,sendtime)
		select senddate,src,tgt,@receiver,reccnt,0,getdate() 
			from ShouldExchgData 
			where senddate = @sendedDate and src = @usergid and tgt = @receiver
	if (@receiver <> @ZBGID) and (@usergid <> @ZBGID)
	begin
		delete from NShouldExchgData 
			where SendDate = @SendedDate and Rcv = @ZBGID and tgt = @receiver
				and src = @usergid and ntype = 0

		delete from NShouldExchgDataDtl 
			where SendDate = @Sendeddate and rcv = @ZBGID and tgt = @receiver
				and src = @Usergid

		insert into NShouldExchgDataDtl(SendDate,cls,num, rcv, src, tgt, Checkint1,
			Checkint2 , Checkint3, Checkdata1, Checkdata2,
			Checkdata3)
		select SendDate,cls,num,@ZBGID, src, tgt, Checkint1,
			Checkint2 , Checkint3, Checkdata1, Checkdata2,
			Checkdata3 from ShouldExchgDataDtl
			 where senddate = @SendedDate and tgt = @receiver and src = @usergid

		insert into NShouldExchgData(SendDate,src,Tgt,rcv,reccnt,ntype,sendtime)
			select senddate,src,tgt,@ZBGID,reccnt,0,getdate() 
				from ShouldExchgData 
				where senddate = @sendedDate and src = @usergid and tgt = @receiver
	end
	return 0
end
GO
