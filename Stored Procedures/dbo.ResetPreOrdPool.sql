SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ResetPreOrdPool](
  @num char(10)
) as
begin
  declare
    @return_status int,
    @posno  char(10),
    @flowno char(12),
    @itemno smallint,
    @qty    money,
    @relaqty    money,
    @vreccnt       int,
    @gdgid      int,
    @qpcgid     int,
    @cls    char(10),
    @qpcqty	money,
    @qpccode	varchar(20),
    @qpcname	varchar(40),
    @msg	varchar(255),
    @ordqty money,
    @rtlprc money,
    @preordqty money,
    @rtltotal money,
    @rtlqty money

    select @return_status = 0
    declare c_dlvdtl cursor for
    select posno, flowno, itemno, qty, gdgid, qpcgid, qpcqty, cls
        from dlvdtl
        where num = @num
        order by line
    open c_dlvdtl
    fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
    while @@fetch_status = 0
    begin
        if @cls = '零售'
        begin
          if exists(select 1 from PreOrdPool(nolock) where PosNo = @posno and Flowno = @flowno)
          begin
            select @rtlprc = price, @rtltotal = price * @qty from buy2(nolock) where posno = @posno and flowno = @flowno and
              itemno = @itemno
            if exists(select 1 from PREORDPOOLDTL(nolock) where POSNO = @posno and FLOWNO = @flowno and
                 GDGID = @gdgid)
              update PREORDPOOLDTL set REALAMT = REALAMT + @rtltotal,
                PREORDQTY = PREORDQTY + @qty
                where POSNO = @posno and @FLOWNO = @flowno and GDGID = @gdgid
            else
              insert into PREORDPOOLDTL(FLOWNO,POSNO,GDGID,RTLQTY,PRICE,
                REALAMT,RTLBACKQTY,PREORDQTY)
              values(@flowno,@posno,@gdgid,@qty,@rtlprc, @rtltotal, 0, @qty)
            end
            else
            begin
              select @rtlprc = price,@rtlqty=qty, @rtltotal = price * @qty from buy2(nolock) where posno = @posno and flowno = @flowno and itemno =
                @itemno
              insert into PREORDPOOLDTL(FLOWNO,POSNO,GDGID,RTLQTY,PRICE,
                  REALAMT,RTLBACKQTY,PREORDQTY)
                values(@flowno,@posno,@gdgid,@rtlqty,@rtlprc, @rtltotal, 0, @qty)
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
        end
        fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
    end
    close c_dlvdtl
    deallocate c_dlvdtl
    return(0)
end
GO
