SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHECKPO_TO110](
  @num char(14),
  @cls char(10),
  @oper varchar(30),
  @ToStat smallInt,
  @Msg varchar(200) output
) with encryption as
begin
    declare
    @stat int,
	@usergid int,
	@gdgid int,
	@wrh int,
	@qty money,
	@price money,
	@rtlprc money,
	@rtltotal money,
	@line smallint,           --2001.7.12
	@flowno char(12),
	@posno char(10),
	@ordqty money,
	@count int,
	@ret int,
	@mstPsr int,
	@psr int,
	@mstWrh int,
	@rtlqty money

    select @usergid = usergid from system

	declare I_ord cursor for
	select LINE,GDGID,ORDQTY, FLOWNO, POSNO, RTLPRC, RTLTOTAL
	  from PURCHASEORDERDTL where NUM = @num and CLS = @cls

	open I_ord
	fetch next from I_ord into
		@line, @gdgid,@ordqty, @flowno, @posno, @rtlprc, @rtltotal
	while @@fetch_status = 0
	begin
      declare @vret int,@vreccnt int,@vqty decimal(24, 4)
      select @vret = flag from buy1(nolock)
       where PosNo = @posno and Flowno = @flowno
      if @@rowcount = 0 break
      if @vret = 0 break

      if exists(select 1 from PreOrdPool(nolock)
      where PosNo = @posno and Flowno = @flowno)
      begin
        if exists(select 1 from PREORDPOOLDTL(nolock) where POSNO = @posno and FLOWNO = @flowno and
            GDGID = @gdgid)
          update PREORDPOOLDTL set REALAMT = REALAMT + @rtltotal,
            PREORDQTY = PREORDQTY + @ordqty
          where POSNO = @posno and @FLOWNO = @flowno and GDGID = @gdgid
        else
          insert into PREORDPOOLDTL(FLOWNO,POSNO,GDGID,RTLQTY,PRICE,
            REALAMT,RTLBACKQTY,PREORDQTY)
          values(@flowno,@posno,@gdgid,@ordqty,@rtlprc, @rtltotal, 0, @ordqty)
      end
      else
      begin
        select @rtlqty=sum(qty) from buy2(nolock) where posno = @posno and flowno = @flowno and gid=@gdgid
        insert into PREORDPOOLDTL(FLOWNO,POSNO,GDGID,RTLQTY,PRICE,
            REALAMT,RTLBACKQTY,PREORDQTY)
          values(@flowno,@posno,@gdgid,@rtlqty,@rtlprc, @rtltotal, 0, @ordqty)
        select @ordqty = sum(qty), @vreccnt = count(*), @rtltotal = sum(realamt) from buy2(nolock)
          where posno = @posno and flowno = @flowno
          group by posno,flowno,gid
        insert into PREORDPOOL(FLOWNO,POSNO,FILDATE,CASHIER,
          ASSISTANT,TOTAL,GUEST,RECCNT,QTY,MEMO,CARDCODE)
        select flowno,posno,fildate,cashier,assistant,
            @rtltotal,guest,@vreccnt,@ordqty,memo,cardcode
          from buy1(nolock)
         where posno = @posno and flowno = @flowno
      end
	  fetch next from I_ord into
	    @line, @gdgid, @ordqty, @flowno, @posno, @rtlprc, @rtltotal
	end
	close I_ord
	deallocate I_ord

	if @ret <> 0
	  return(@ret)
	update PURCHASEORDER set STAT = 110, CONFIRMER = @oper, CONFIRMDATE = getdate() where NUM = @num and CLS = @cls
	exec PURCHASEORDADDLOG @NUM, @CLS, 110, '', @OPER
	return (0)
end
GO
