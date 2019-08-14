SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsPrmPrcEx](
        @storegid       int,
        @gdgid  int,
        @adate  datetime,
        @qty    money,
        @QpcStr varchar(20),
        @prmprc money   output,
        @prmstart datetime output,
        @prmfinish datetime output
)
with encryption as
begin
        declare
                @promote        smallint,
                @rtlprc money,
                @t      money,
                @m      datetime,
                @start  datetime,
                @finish datetime,
                @cycle  datetime,
                @cstart datetime,
                @cfinish        datetime,
                @qtylo  money,
                @qtyhi  money,
                @price  money,
                @discount       money

        if @storegid = (select usergid from system(nolock))
                select @promote = QPCPROMOTE, @rtlprc = QPCRTLPRC from V_QPCGOODS(nolock)
                where gid = @gdgid and QPCQPCSTR = @QpcStr
        else begin
                select @promote = QPCPROMOTE, @rtlprc = QPCRTLPRC from V_QPCGDSTORE(nolock)
                where storegid = @storegid and gdgid = @gdgid and QPCQPCSTR = @QpcStr
                if @@rowcount = 0
                        select @promote = QPCPROMOTE, @rtlprc = QPCRTLPRC from V_QPCGOODS(nolock)
                        where gid = @gdgid and QPCQPCSTR = @QpcStr
        end
        set @prmprc = @rtlprc

        if object_id('c_price') is not null deallocate c_price
        declare c_price cursor for
        select start, finish, cycle, cstart, cfinish, qtylo,
                qtyhi, price, discount
        from price(nolock)
        where storegid = @storegid and gdgid = @gdgid and QPCSTR = @QpcStr
        open c_price
        fetch next from c_price into @start, @finish, @cycle,
                @cstart, @cfinish, @qtylo, @qtyhi, @price, @discount
        while @@fetch_status = 0
        begin
                if @promote & 1 = 1
                begin
                        if (@adate < @start) or (@adate > @finish)
                                goto L0
                        if @promote & 2 = 2
                        begin
                                if @cycle <= 0
                                        goto L0
                                set @t = convert(money, @adate - @start)
                                set @t = @t - floor(convert(money, @t) / convert(money, @cycle))
                                        * convert(money, @cycle)
                                set @m = convert(datetime, @t)
                                if (@m < @cstart) and (@m < @cfinish)
                                        goto L0
                                if (@m > @cstart) and (@m > @cfinish)
                                        goto L0
                        end
                end

                if @promote & 4 = 4
                begin
                        if (@qty < @qtylo) or (@qty > @qtyhi)
                                goto L0
                end

                if @price is not null
                        set @prmprc = @price
                if @discount is not null
                        set @prmprc = @prmprc * 100 / @discount
                if @start is not null
                				set @prmstart = @start
                if @finish is not null
                        set @prmfinish = @finish
                break

L0:
                fetch next from c_price into @start, @finish, @cycle,
                        @cstart, @cfinish, @qtylo, @qtyhi, @price, @discount
        end
        close c_price
        deallocate c_price

        return (0)
end
GO
