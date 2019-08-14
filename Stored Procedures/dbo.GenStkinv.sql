SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GenStkinv](
	@date datetime
) as begin

	insert fifo_stkinv(gdgid, Ocrdate, qty, price, Cls, Num, dateid)
	select b.gdgid, a.Ocrdate, b.qty, b.price, a.cls, a.num,
		convert(char(8), a.ocrdate, 112) + rtrim(b.cls) + rtrim(b.num)
		+ right('0000' + rtrim(convert(char(4), b.line)),4)
	from stkin a(NOLOCK), stkindtl b(NOLOCK), goodsh c(nolock)
	where a.cls = b.cls
		and a.num = b.num
		and b.gdgid = c.gid
		and a.stat in (1, 2, 6)
		and a.fildate >= @date
		and a.Fildate < DateAdd(day, 1, @date)
    if @@error <> 0 return 1

	insert fifo_stkinv(gdgid, Ocrdate, qty, price, Cls, Num, dateid)
	select b.gdgid, a.Ocrdate, b.qty, b.price, a.cls, a.num,
		convert(char(8), a.ocrdate, 112) + rtrim(b.cls) + rtrim(b.num)
		+ right('0000' + rtrim(convert(char(4), b.line)),4)
	from diralc a(NOLOCK), diralcdtl b(NOLOCK), goodsh c(nolock)
	where a.cls = b.cls
		and a.num = b.num
		and a.cls = '直配进'
		and b.gdgid = c.gid
		and a.stat in (1, 2, 6)
		and a.fildate >= @date
		and a.Fildate < DateAdd(day, 1, @date)
    if @@error <> 0 return 1

	delete from fifo_Stkinv
	from stkin
	where fifo_stkinv.cls = stkin.cls and fifo_stkinv.num = stkin.modnum
	and stkin.fildate >= @date and stkin.fildate < dateadd(day, 1, @date)
	and stkin.stat in (1,2,4,6) and stkin.modnum is not null
    if @@error <> 0 return 1

	delete from fifo_Stkinv
	from diralc
	where fifo_stkinv.cls = diralc.cls and fifo_stkinv.num = diralc.modnum and diralc.cls = '直配进'
	and diralc.fildate >= @date and diralc.fildate < dateadd(day, 1, @date)
	and diralc.stat in (1,2,4,6) and diralc.modnum is not null
    if @@error <> 0 return 1
    return 0
end
GO
