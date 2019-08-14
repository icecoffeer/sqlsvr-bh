SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Fifocost](
    @settleno int,
    @date datetime,
    @intrecal smallint = 0	-- 0:正常,1:重算多天,2:重算昨天
) as
begin
	declare
		@gdgid int,	   @costqty money,	@t_invadjtotal money,
		@maxbnum char(30), @qty money,		@t_costtotal money,
		@price money,	   @bnum char(30),	@invadjqty money,
		@inprc money, 	@ret int
	set nocount on
	select @ret = 0
	if @intrecal <> 2 exec @ret = GenStkinv @date
    if @ret <> 0 return 1
	exec @ret = FifocostInit @settleno, @date, @intrecal
    if @ret <> 0 return 1

	declare c_in cursor for
	select gdgid, costqty, invadjqty, fifocostcheck.inprc
	from fifocostcheck, goodsh
	where adate = @date
	and fifocostcheck.gdgid = goodsh.gid
	and fifocostcheck.costqty > 0
	and goodsh.sale = 1
	for update
	open c_in
	fetch next from c_in into @gdgid, @costqty, @invadjqty, @inprc
	while @@fetch_status = 0
	begin
    		select @maxbnum = max(dateid) from fifo_stkinv
		where gdgid = @gdgid and OcrDate <= @date
    		if @maxbnum is null 
			select @t_costTotal = round(@costqty * @inprc,2), @t_invadjtotal = round(@invadjqty * @inprc, 2)
		else begin
         		select @bnum = dateid, @t_costtotal = 0, @t_invadjtotal = 0, @qty = Qty, @price = Price
         		from fifo_stkinv where gdgid = @gdgid and dateid = @maxbnum
                	while @qty < @costQty
         		begin
                		select @t_costTotal = @t_costTotal + round(@qty * @Price, 2),
						@costQty = @costQty - @qty
                    		select @maxbnum = max(dateid) from fifo_stkinv
				where gdgid = @gdgid and dateid < @bnum
				if @maxbnum is null
				begin
					select @t_costtotal = @t_costtotal + round(@costqty * @inprc,2),
						@t_invadjtotal = round(@invadjqty * @inprc, 2)
					break
				end
                		select @bnum = dateid, @qty = Qty, @price = Price from fifo_stkinv
                		where gdgid = @gdgid and dateid = @maxbnum
            		end
			if @maxbnum is not null
			begin
				--deal with 盈亏损益
         			select @t_costTotal = @t_costTotal + round(@costQty * @price, 2), @qty = @qty - @costqty
				if @invadjqty >= 0
                    			select @t_invadjtotal = round(@invadjqty * @price, 2)
				else if @invadjqty < 0
			     	begin
					select @invadjqty = - @invadjqty
                        		while @qty < @invadjqty
         				begin
                        			select @t_invadjTotal = @t_invadjTotal + round(@qty * @Price, 2),
							@invadjQty = @invadjqty - @qty
						select @maxbnum = max(dateid) from fifo_stkinv
						where gdgid = @gdgid and dateid < @bnum
						if @maxbnum is null
						begin
							select @t_invadjtotal = -(@t_invadjtotal + round(@invadjqty * @inprc,2))
							break
						end
                            			select @bnum = dateid, @qty = Qty, @price = Price from fifo_stkinv
                            			where gdgid = @gdgid and dateid = @maxbnum
         				end
         				if @maxbnum is not null
						select @t_invadjTotal = -(@t_invadjTotal + round(@invadjQty * @price, 2))
                    		end
			end
    		end

    		update fifocostcheck set
			costtotal = @t_costTotal, invadjtotal = @t_invadjtotal,
			outcost = lastcosttotal + zjtotal - zjttotal + @t_invadjtotal - @t_costtotal
    		where current of c_in

		fetch next from c_in into @gdgid, @costqty, @invadjqty, @inprc
	end
	close c_in
	deallocate c_in
end
GO
