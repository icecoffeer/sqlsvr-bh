SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendICCardhst] 
	@SendedDate DateTime,
	@Receiver integer,
	@ErrMessage varchar(100) output
as
begin
	declare @usergid int,@RowCount int,@endtime datetime
	select @usergid = usergid from system
        select @endtime = dateadd(d,1,@sendeddate)
	exec iccardhstwholesnd @receiver,@endtime,@RowCount output
	Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)
		Values ('IC卡历史记录',@Receiver,GetDate(),@SendedDate,@RowCount)
end
GO
