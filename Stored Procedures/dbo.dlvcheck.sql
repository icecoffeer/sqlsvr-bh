SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[dlvcheck](
  @num char(10),
  @filler int
) as
begin
  declare
    @return_status int,
    @cur_settleno int,
    @stat   smallint,
    @posno  char(10),
    @flowno char(12),
    @itemno smallint,
    @srcqty money,
    @dlvqty money,
    @qty    money,
    @relaqty    money,
    @line       int,
    @gdgid      int,
    @qpcgid     int,
    @cls    char(10),
    @qpcqty	money,
    @qpccode	varchar(20),
    @qpcname	varchar(40),
    @msg	varchar(255),
    @bckqty	money,
    @dspwrh     int,        --提货仓位
    @invnum     int,
    @usergid    int,
    @preordqty money

    select @line = 1,@dspwrh = 1
    select @return_status = 0
    select @cur_settleno = max(no) from monthsettle
    select @usergid = usergid from system
    select @stat = stat from dlv where num = @num
    if @stat <> 0 begin
        raiserror('审核的不是未审核的单据', 16, 1)
        return(1)
    end

    declare c_dlvdtl cursor for
    select posno, flowno, itemno, qty, gdgid, qpcgid, qpcqty, cls
        from dlvdtl
        where num = @num
        order by line
    for update of qty,line,qpcqty
    open c_dlvdtl
    fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
    while @@fetch_status = 0
    begin
        if @cls = '零售'
        begin
            select @srcqty = isnull(sum(qty),0)
            from buy2(nolock)
            where buy2.qty>0 and posno = @posno and flowno = @flowno and itemno = @itemno

	    select @dlvqty = isnull(sum(qty),0)
    	    from dlv,dlvdtl
            where dlv.stat in (1,2) and dlv.num = dlvdtl.num
        		and posno = @posno and flowno = @flowno and itemno = @itemno

	    select @bckqty = isnull(sum(stkoutbckdtl.qty), 0) from stkoutbckdtl(nolock), stkoutbck(nolock)
			where stkoutbck.cls = '零售' and stkoutbck.genbill = 'buy1'
			and stkoutbck.num = stkoutbckdtl.num and stkoutbck.cls = stkoutbckdtl.cls
			and stkoutbck.gencls = @posno
			and stkoutbck.gennum = @flowno
			and stkoutbckdtl.itemno = @itemno
			and stkoutbck.stat = 1
	    --gph
	    select @dspwrh = isnull(wrh,1) from buy2(nolock) where posno=@posno and flowno=@flowno and itemno = @itemno

	    select @srcqty = @srcqty - @bckqty

        if exists(select 1 from PREORDPOOLDTL where POSNO = @posno and FLOWNO = @flowno
	  	      and gdgid = @gdgid)
  	    begin
  	      select @preordqty = PREORDQTY from PREORDPOOLDTL(NOLOCK) where POSNO = @posno and FLOWNO = @flowno
  	        and GDGID = @gdgid
  	      if @qty < @preordqty
  	      begin
  	        update PREORDPOOLDTL set PREORDQTY = PREORDQTY - @qty
  	          where POSNO = @posno and FLOWNO = @flowno and gdgid = @gdgid
  	      end
  	      else if @qty = @preordqty
  	      begin
  	        delete from PREORDPOOLDTL where POSNO = @posno and FLOWNO = @flowno and GDGID = @gdgid
  	        if not exists(select 1 from PREORDPOOLDTL where POSNO = @posno and FLOWNO = @flowno)
  	          delete from PREORDPOOL where POSNO = @posno and FLOWNO = @flowno
  	      end
  	      else if @qty > @preordqty
  	      begin
  	        close c_dlvdtl
  	        deallocate c_dlvdtl
  	        select @qpccode = code, @qpcname = name from goods(nolock) where gid = @qpcgid
  	        set @msg = '存在数量大于可送货数量的商品'
			if @qpccode is not null
			  set @msg = @msg + '：商品代码：' + @qpccode + '，商品名称：' + @qpcname
			raiserror(@msg, 16, 1)
			return 1
  	      end

  	    end
	    if @dlvqty >= @srcqty
    	    begin
            	delete dlvdtl where current of c_dlvdtl
            	fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
            	continue
            end

            select @relaqty = 1
            if @qpcgid <> @gdgid
            	select @relaqty = isnull(qty,1) from pkg where pgid=@qpcgid and egid=@gdgid
            if @relaqty is null or @relaqty = 0
            	select @relaqty = 1

            if @qty > @srcqty - @dlvqty
            begin
			close c_dlvdtl
    			deallocate c_dlvdtl
				select @qpccode = code, @qpcname = name from goods(nolock) where gid = @qpcgid
				set @msg = '存在数量大于可送货数量的商品'
				if @qpccode is not null
					set @msg = @msg + '：商品代码：' + @qpccode + '，商品名称：' + @qpcname
				raiserror(@msg, 16, 1)
				return 1
	    end
            else
            	        update dlvdtl set qpcqty = qty/@relaqty,line = @line  where current of c_dlvdtl
        end
	else if @cls = '批发'
	begin
              select @srcqty = isnull(sum(qty),0)
              from stkoutdtl(nolock)
              where cls = '批发' and num = @flowno and line = @itemno

	      --gph
	      select @dspwrh = isnull(wrh,1) from stkoutdtl(nolock) where cls = '批发' and num=@flowno and line = @itemno

	      select @dlvqty = isnull(sum(qty),0)
    	      from dlv,dlvdtl
              where dlv.stat in (1,2) and dlv.num = dlvdtl.num
        		and posno = @posno and flowno = @flowno and itemno = @itemno

	      if @dlvqty >= @srcqty
    	      begin
            	delete dlvdtl where current of c_dlvdtl
            	fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
            	continue
              end

             select @relaqty = 1
             if @qpcgid <> @gdgid
            	select @relaqty = isnull(qty,1) from pkg where pgid=@qpcgid and egid=@gdgid
             if @relaqty is null or @relaqty = 0
                select @relaqty = 1

             if @qty > @srcqty - @dlvqty
            	update dlvdtl set qpcqty = qty/@relaqty,line = @line,qty = @srcqty - @dlvqty where current of c_dlvdtl
             else
            	update dlvdtl set qpcqty = qty/@relaqty,line = @line  where current of c_dlvdtl
	end
	else /*2002.08.04*/
	begin /*裁剪*/
			/*裁剪单考虑到从裁剪销售单退货的情况*/
	     select @srcqty = isnull(iqty, 0) - isnull(bckiqty, 0)
			from cutbuy2(nolock)
			where iqty > 0 and num = @flowno and line = @itemno

	     select @dlvqty = isnull(sum(qpcqty),0)
    	        from dlv,dlvdtl
        	where dlv.stat in (1,2) and dlv.num = dlvdtl.num
        		and posno = @posno and flowno = @flowno and itemno = @itemno

	     if @dlvqty >= @srcqty
    	     begin
            	delete dlvdtl where current of c_dlvdtl
            	fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
            	continue
             end

	     --gph 取商品缺省仓位
	     select @dspwrh = isnull(wrh,1) from goodsh where gid = @gdgid

	     select @relaqty = 1
             if @qpcgid <> @gdgid
            	select @relaqty = isnull(qty,1) from pkg where pgid=@qpcgid and egid=@gdgid
             if @relaqty is null or @relaqty = 0
            	select @relaqty = 1

             if @qpcqty > @srcqty - @dlvqty
	     begin
	                    close c_dlvdtl
    			    deallocate c_dlvdtl
				select @qpccode = code, @qpcname = name from goods(nolock) where gid = @qpcgid
				set @msg = '存在数量大于可送货数量的商品'
				if @qpccode is not null
					set @msg = @msg + '：商品代码：' + @qpccode + '，商品名称：' + @qpcname
				raiserror(@msg, 16, 1)
				return 1
	     end
             else
            	update dlvdtl set qty = qpcqty * @relaqty,line = @line  where current of c_dlvdtl
        end
        --added by GuPeihua 2003.06.03 for generating dspqty
	if (select optionvalue from hdoption where optioncaption = 'DlvDsp' and moduleno = 384 ) = '1'
	begin
	     if not exists (select 1 from inv where gdgid = @gdgid and wrh = @dspwrh and store=@usergid)
	     begin
	          insert into inv(wrh, gdgid, qty, total, ordqty, validdate,store,dspqty,bckqty)
		     values(@dspwrh, @gdgid, 0,0,0,null,@usergid,@qty,0)
	     end
	     else begin
	         update inv
	             set dspqty = dspqty + @qty
	             where gdgid = @gdgid and wrh = @dspwrh and store=@usergid
             end
	end
        --end adding
        select @line = @line+1
        fetch next from c_dlvdtl into @posno, @flowno, @itemno, @qty, @gdgid, @qpcgid, @qpcqty, @cls
    end
    close c_dlvdtl
    deallocate c_dlvdtl
    if @line=1
        return(2)

    --added by jinlei 2006-5-22 13:28
    if (select optionvalue from hdoption where optioncaption = 'DlvToPod' and moduleno = 384 ) = '1'
    begin
      if exists(select 1 from dlv where num = @num and cls = '零售' and FROMCLS = '销售定货进货')
      begin
        declare @podnum char(14), @OPER varchar(50)
        select @podnum = fromnum from dlv where num = @num and cls = '零售'
        select @OPER = rtrim(name) + '[' + rtrim(code) + ']' from employee(nolock) where gid = @filler
        EXEC PURCHASEORDER_CHECK_100TO3200 @podnum, @OPER, '销售进货', 3200, @MSG
      end
    end

    update dlv set stat=1, LSTUPDTIME=getdate(), filler=@filler, settleno=@cur_settleno where num = @num
    return(@@error)
end
GO
