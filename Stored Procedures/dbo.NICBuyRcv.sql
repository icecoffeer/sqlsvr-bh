SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[NICBuyRcv]
  @ID int,
  @Src int,
  @Msg varchar(200) output
as
begin
  declare @store int , @Flowno varchar(12) , @Posno varchar(10)
  declare @count int
  select @store = store, @Flowno = Flowno , @PosNO = Posno from nicbuy1
    where ID = @ID and Src = @Src
  if @@Rowcount = 0 
  begin
	select @msg = '对应记录已经被接收或删除，不能接收。'
	return -1
  end
  if exists (select 1 from icbuy1 where store = @store and flowno = @flowno 
	and posno = @posno)
  begin
	delete from nicbuy1 where src = @src and id= @id
	delete from nicbuy11 where src = @src and id= @id
	delete from nicbuy2 where src = @src and id= @id
	return 0
/*	deleted by hxs 2002.04.22
	select @msg = '对应记录已经被接收，不能重新接收。'
	update nicbuy1 set nnote = @msg 
		where src = @src and id = @id
	return -1
*/
  end
  select @count = count(*) from nicbuy2 where src = @src and id=@id
  if isnull(@count,0) = 0
  begin

	select @msg = '网络记录不完整，在NICBUY2表中没有对应记录，不能重新接收。'
	update nicbuy1 set nnote = @msg 
		where src = @src and id = @id
	return -1
  end
  insert into icbuy2(store,flowno,posno,itemno,settleno,gid,qty,inprc,price,
	realamt,favamt,prmtag,assistant,wrh,invno)
    select store,flowno,posno,itemno,settleno,gid,qty,inprc,price,
	realamt,favamt,prmtag,assistant,wrh,invno
	from nicbuy2 where src = @src and id = @ID
   if @@error <> 0 
   begin
	select @msg = '接收ICBUY2记录时出错。'
	update nicbuy1 set nnote = @msg 
		where src = @src and id = @id
	return -1
   end
  insert into icbuy11(store,flowno,posno,itemno,settleno,currency,amount,cardcode)
    select store,flowno,posno,itemno,settleno,currency,amount,cardcode
	from nicbuy11 where src = @src and id = @ID
   if @@error <> 0 
   begin
	select @msg = '接收ICBUY11记录时出错。'
	update nicbuy1 set nnote = @msg 
		where src = @src and id = @id
--	delete from icbuy2 where store = @store and flowno = @flowno and posno = @posno
	return -1
   end
  insert into icbuy1(store,flowno,posno,settleno,fildate,cashier,wrh,assistant,total,realamt,
	prevamt,guest,reccnt,memo,tag,invno,score,sender,rcvtime,cardcode)
    select store,flowno,posno,settleno,fildate,cashier,wrh,assistant,total,realamt,
	prevamt,guest,reccnt,memo,tag,invno,score,sender,getdate(),cardcode
	from nicbuy1 where src = @src and id = @ID
   if @@error <> 0 
   begin
	select @msg = '接收ICBUY1记录时出错。'
	update nicbuy1 set nnote = @msg 
		where src = @src and id = @id
--	delete from icbuy2 where store = @store and flowno = @flowno and posno = @posno
--	delete from icbuy11 where store = @store and flowno = @flowno and posno = @posno
	return -1
   end
   delete from nicbuy1 where src = @src and id= @id
   delete from nicbuy11 where src = @src and id= @id
   delete from nicbuy2 where src = @src and id= @id

	

   return 0
end
GO
