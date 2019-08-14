SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ICBuySnd]
  @posno varchar(10),
  @flowno char(12),
  @Rcv int
as
begin
	declare @id int
	declare @store int
	
	select @store = usergid from system(nolock)
	execute GETNETBILLID @id output	

	insert into nicbuy1(Store,Flowno,Posno,settleno,fildate,cashier,wrh,assistant,total,realamt,prevamt,
		guest,reccnt,memo,invno,score,cardcode,src,ID,Rcv,sndtime,sender,ntype,nstat)
	select Store,Flowno,Posno,settleno,fildate,cashier,wrh,assistant,total,realamt,prevamt,
		guest,reccnt,memo,invno,score,cardcode, @store, @ID, @rcv ,getdate(),1,0,0
		from icbuy1(nolock)
		where store = @store and flowno = @Flowno and posno = @Posno


	insert into NICBuy11(store,Flowno,posno,itemno,settleno,currency,amount,cardcode,Src,ID)
	select @store,Flowno,posno,itemno,settleno,currency,amount,cardcode, @Store, @ID
		from icbuy11 (nolock)
		where posno = @posno and flowno = @flowno and Store = @store


	insert into nICBuy2(store,Flowno,posno,itemno,settleno,gid,qty,inprc,price,realamt,favamt,PrmTag,
		assistant,wrh,invno,SRC,ID)
	select @store,Flowno,posno,itemno,settleno,gid,qty,inprc,price,realamt,favamt,PrmTag,
		assistant,wrh,invno, @Store, @ID
		from icbuy2 (nolock)
		where  posno = @posno and flowno = @flowno and store = @store


	update icbuy1 set sendtime = GetDate(),Sender = 1
		where posno = @posno and flowno = @flowno and store = @store

end

GO
