SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHECKPO_TO100](
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
	@line smallint,           --2001.7.12
	@flowno char(12),
	@posno char(10),
	@ordqty money,
	@realamt money,
	@count int,
	@ret int,
	@mstPsr int,
	@psr int,
	@mstWrh int

    select @usergid = usergid from system

    select @mstPsr = PSR, @mstWRh = WRH from PURCHASEORDER where NUM = @num and CLS = @cls

	declare I_ord cursor for
	select LINE,GDGID,ORDQTY, RTLTOTAL, FLOWNO, POSNO from PURCHASEORDERDTL where NUM = @num and CLS = @cls

	open I_ord
	fetch next from I_ord into
		@line, @gdgid,@ordqty, @realamt, @flowno, @posno
	while @@fetch_status = 0
	begin
	    select @qty = PREORDQTY from preordpooldtl(nolock) where FLOWNO = @flowno and POSNO = @posno and gdgid = @gdgid
	    if @@rowcount = 0
	    begin
	        select @Msg = '销售定货单明细商品已经生成销售定货记录，不允许审核'
	        select @ret = 1
	        break
	    end

        if not exists(select 1 from goods where GID = @gdgid)
        begin
          set @Msg = '销售定货单明细商品不存在,不允许审核'
          set @ret = 1
          break
        end

	    select @psr = PSR, @wrh = WRH from GOODS(nolock) where GID = @gdgid
	    if @mstpsr <> @psr
	    begin
	      select @Msg = '销售定货单明细商品的采购员与当前销售定货单中的采购员不一致，请重新排单'
	      select @ret = 1
	      break;
	    end

	    if @mstWrh <> @wrh
	    begin
	      set @Msg = '销售定货单明细商品的仓位与当前销售定货单中的仓位不一致，请重新排单'
	      set @ret = 1
	      break;
	    end

	    if @qty = @ordqty
	    begin
	      delete from preordpooldtl where FLOWNO = @flowno and POSNO = @posno and gdgid = @gdgid
	    end
	    else
	    begin
	      update preordpooldtl set PREORDQTY = @qty - @ordqty, REALAMT = REALAMT - @realamt
	        where POSNO = @POSNO and FLOWNO = @FLOWNO and gdgid = @GDGID
	    end
	    select @count = count(1) from preordpooldtl(nolock) where FLOWNO = @flowno and POSNO = @posno
	    if @count = 0
	      delete from preordpool where FLOWNO = @flowno and POSNO = @posno
		fetch next from I_ord into
			@line, @gdgid, @ordqty, @realamt, @flowno, @posno
	end
	close I_ord
	deallocate I_ord

	if @ret <> 0
	  return(@ret)
	update PURCHASEORDER set STAT = 100, CHECKER = @oper, CHECKDATE = getdate() where NUM = @num and CLS = @cls
	exec PURCHASEORDADDLOG @NUM, @CLS, @TOSTAT, '', @OPER
	return (0)
end
GO
