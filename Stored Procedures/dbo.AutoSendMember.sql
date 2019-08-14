SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendMember] 
	@SendedDate DateTime,
	@Receiver integer,
	@ErrMessage varchar(100) output
as
begin

	declare @begin datetime,@end datetime
	declare @usergid int,@RowCount int

	select @usergid = usergid from system

	select @begin = @sendeddate,@end = dateadd(dd,1,@sendeddate)
	
	exec Memberwholesnd @begin,@end,@receiver

	select @RowCount= Count(1) from Member(nolock)
		where src in (1,@Usergid) and lstupdtime >= @begin and lstupdtime< @end

	Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)
		Values ('会员资料',@Receiver,GetDate(),@SendedDate,@RowCount)

end
GO
