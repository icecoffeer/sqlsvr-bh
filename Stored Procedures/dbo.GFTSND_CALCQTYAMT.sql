SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_CALCQTYAMT]
(
  @piGdGid int,  --商品代码
  @piGdCond varchar(8000),  --商品条件, 与@piGdGid只能有一个，另一个为null
  @poQty money output,
  @poAmt money output
)
as
begin
  if @piGdGid is not null
  begin
    select @poQty = isnull(sum(QTY), 0), @poAmt = isnull(sum(AMT), 0)
    from TMPGFTSNDGOODS where spid = @@spid and GDGID = @piGdGid
  end else if @piGdCond is not null
  begin
    set @poQty = 0
    set @poAmt = 0
    declare @vSQL varchar(8000)
    exec HDDEALLOCCURSOR 'c_temp' --确保游标被释放
    set @vSQL = 'declare c_temp cursor for select isnull(sum(QTY), 0), isnull(sum(AMT), 0) from TMPGFTSNDGOODS where spid = @@spid and GDGID in (select GID from GOODS where ' + @piGdCond + ')';
    exec(@vSQL)
    open c_temp
    fetch next from c_temp into @poQty, @poAmt
    close c_temp
    deallocate c_temp
  end else
  begin
    select @poQty = isnull(sum(QTY), 0), @poAmt = isnull(sum(AMT), 0)
    from TMPGFTSNDGOODS where spid = @@spid
  end
end
GO
