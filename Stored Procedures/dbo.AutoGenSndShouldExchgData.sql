SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoGenSndShouldExchgData](
    @SendedDate    datetime,
    @receiver        int,
    @ErrMessage varchar(100) output
)  as
begin
  declare @useDate datetime,  @ret int, @userproperty int
  select @userproperty = userproperty from system
  --set @useDate = @SendedDate --dateadd(day, -1, @SendedDate) --在客户端已经减了
  exec @ret = GenShouldExchgData @SendedDate, @SendedDate
  if @userproperty & 16 <> 16 --总部不执行发送
     exec @ret = ShouldExchgDataSnd @SendedDate, @receiver, @Errmessage output
  Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)
     Values ('应收清单',@Receiver,GetDate(),@SendedDate,-1)
  return @ret
end
/************************************/
print 'create procedure GenShouldExchgData...'
GO
