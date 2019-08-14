SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[COPYTOPREORDPOOL](
  @posno varchar(10),
  @flowno char(12)
) with encryption as
begin
  declare @vret int,@vreccnt int,@vqty decimal(24, 4)

  select @vret = 1 from PreOrdPool(nolock)
   where PosNo = @posno and Flowno = @flowno
  if @@rowcount > 0 return
  select @vret = flag from buy1(nolock)
   where PosNo = @posno and Flowno = @flowno
  if @@rowcount = 0 return
  if @vret = 0 return

  insert into PREORDPOOLDTL(FLOWNO,POSNO,GDGID,RTLQTY,PRICE,
      REALAMT,RTLBACKQTY,PREORDQTY)
    select flowno,posno,gid,sum(qty),avg(price),sum(realamt),0,sum(qty)
      from buy2(nolock)
     where posno = @posno and flowno = @flowno
     group by posno,flowno,gid
  select @vqty = sum(RTLQTY),@vreccnt = count(*)
    from PREORDPOOLDTL(nolock)
   where posno = @posno and flowno = @flowno
  insert into PREORDPOOL(FLOWNO,POSNO,FILDATE,CASHIER,
      ASSISTANT,TOTAL,GUEST,RECCNT,QTY,MEMO,CARDCODE)
    select flowno,posno,fildate,cashier,assistant,
        total,guest,@vreccnt,@vqty,memo,cardcode
      from buy1(nolock)
     where posno = @posno and flowno = @flowno
end
GO
