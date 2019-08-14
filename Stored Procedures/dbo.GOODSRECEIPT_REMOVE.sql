SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[GOODSRECEIPT_REMOVE]
(
  @Num varchar(14),         --单号
  @Oper varchar(30),        --操作人
  @Msg varchar(255) output  --错误信息
)
as
begin
  declare  @Stat int, @gdgid int, @srcordnum char(10)
  select @Stat = STAT from GOODSRECEIPT(nolock) where NUM = @NUM
  if (@Stat <> 0) and (@Stat <>1600)
  begin
    set @Msg = '收货单(' + @Num + ')不是未审核状态，不允许删除!';
    return(1);
  end
  select @srcordnum = srcordnum from goodsreceipt where num = @num
  declare c_inuse cursor for
    select gdgid from goodsreceiptdtl where num = @num
  open c_inuse
  fetch next from c_inuse into @gdgid
  while @@fetch_status = 0
  begin
    update orddtl set inuse = 0, LOCKNUM = NULL, LOCKCLS = NULL where num = @srcordnum and gdgid = @gdgid
    fetch next from c_inuse into @gdgid
  end
  close c_inuse
  deallocate c_inuse
  delete from GOODSRECEIPT where NUM = @Num;
  delete from GOODSRECEIPTDTL where NUM = @Num;
  delete from GOODSRECEIPTLOG where NUM = @Num;
  delete from RFEMPLOCKORD where ORDNUM = @srcordnum;
  exec GOODSRECEIPT_ADD_LOG @Num, 0, '删除', @Oper;
  return(0)
end
GO
