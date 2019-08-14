SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoGenSndRealExchgData](
    @SendedDate    datetime,
    @receiver        int,
    @ErrMessage varchar(100) output
) as
begin
  declare @userproperty int
  declare @useDate datetime,  @ret int
  select @userproperty = userproperty from system
  --set @useDate = @SendedDate --dateadd(day, -1, @SendedDate) --在客户端已经减了
  exec @ret = GenRealExchgData @SendedDate, @SendedDate
 if @userproperty & 16 <> 16 --总部不执行发送
     exec @ret = RealExchgDataSnd @SendedDate, @receiver, @Errmessage output
  Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)
     Values ('实收清单',@Receiver,GetDate(),@SendedDate,-1)
  return @ret
end

--call by autosenddefine by NETFTP 总部使用自动生成应收数据
print 'create procedure AutoGenSndShouldExchgData...'
GO
