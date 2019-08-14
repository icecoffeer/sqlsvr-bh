SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[GOODSRECEIPT_ON_MODIFY]
(
  @Num varchar(14),            --单号
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)   --------------------------------------------------------
as
begin
  declare @vRet int, @FromStat int, @gdgid int, @srcordnum char(10);
  select @FromStat = STAT from GOODSRECEIPT(nolock) where NUM = @Num;
  if @FromStat = 0
  begin
    select @srcordnum = srcordnum from goodsreceipt where num = @num
    declare c_inuse cursor for
      select gdgid from goodsreceiptdtl where num = @num
    open c_inuse
    fetch next from c_inuse into @gdgid
    while @@fetch_status = 0
    begin
    	update orddtl set inuse = 1 where num = @srcordnum and gdgid = @gdgid
    	fetch next from c_inuse into @gdgid
    end
    close c_inuse
    deallocate c_inuse
  end
  --增加预审状态调度
  if @ToStat = 1600
  begin
    exec @vRet = GOODSRECEIPT_CHKTO1600 @Num, @Oper, @Msg output
    return(@vRet)
  end
  else if @ToStat = 100
  begin
   --状态调度
    exec @vRet = GOODSRECEIPT_CHECK @Num, @Oper, @ToStat, @Msg output
    return(@vRet)
  end
  else begin
    if @FromStat = 0
      exec GOODSRECEIPT_ADD_LOG @Num, @ToStat, '修改', @Oper
    else if @FromStat = 1600
      exec GOODSRECEIPT_ADD_LOG @Num, @FromStat, '预审', @Oper
    else
      exec GOODSRECEIPT_ADD_LOG @Num, @FromStat, '', @Oper
  end
  update GOODSRECEIPT set LSTUPDOPER = @Oper, LstUpdTime = getdate() where Num = @Num
  return(0)
end
GO
