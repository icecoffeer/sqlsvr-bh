SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdj_To100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
With Encryption
As
Begin
  declare @stat int,
          @eon int,
          @launch datetime,
          @ret int

  set @ret = 0
  select @stat=stat,@launch=launch,@eon=eon from RtlPrcAdj where num =@Num
  if @stat <> 0
  begin
    set @MSG='不能审核不是未审核的单据'
    return 1
  end

  update RtlPrcAdj set stat=100,LstUpdTime=Getdate(),checker=@oper,
  chkdate=getdate() where num=@num

  --2005.10.14, Added by ShenMin, Q5047, 售价调整单促销单记录操作日志
    exec WritePrcAdjLog '售价', @num, '审核'
  
  --2007.12.18, Added by Zhuhaohui, 审核消息提醒
  execute RtlPrcAdjCheck @NUM
  --结束消息提醒

  if (@launch is null or @launch < getdate())
    exec @ret=RtlPrcAdj_To800 @num,@msg output
  --@ret为非本店生效时的错误
  if @ret = 1 set @msg = @msg + ',无法审核生效该单据'
  return @ret
End
GO
