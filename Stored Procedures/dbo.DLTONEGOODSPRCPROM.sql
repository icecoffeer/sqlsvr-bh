SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DLTONEGOODSPRCPROM](
  @piGDGid int,
  @piStoreGid int,
  @piStart datetime,
  @piFinish datetime,
  @poErrMsg varchar(255) output
) --with encryption
as
begin
  declare @DltGdPrcPromStyle int
  EXEC OPTREADINT 0, 'DltGdPrcPromStyle', 0, @DltGdPrcPromStyle OUTPUT

  --更新Price
  if @DltGdPrcPromStyle = 0  --原来的方式
  update Price set Finish = @piStart
  where GDGid = @piGDGid and StoreGid = @piStoreGid
    and (not ((Start > @piFinish) or (Finish < @piStart)))
 else    --覆盖的方式
   begin
    --开始时间小于 + 结束时间大于:k < k1 and j > j1 3段有效值
    if exists (select 1 from PRICE where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START < @piStart and FINISH > @piFinish)
     begin
      if @piStart > getdate() --后面单据的开始时间大于当前时间
       insert into  PRICE(STOREGID, GDGID, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT,
         INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE, PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM)
       select STOREGID, GDGID, START, @piStart, CYCLE, CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT,
         INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE, PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM
       from PRICE(nolock) where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
         and START < @piStart and FINISH > @piFinish
      --开始时间修改为后一单的结束时间
      update PRICE set START = @piFinish where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
       and START < @piStart and FINISH > @piFinish
     end

     --开始时间小于 + 结束时间小于结束时间 + 结束时间大于原开始时间:k < k1 and j < j1 and j > k1
     if exists (select 1 from PRICE where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START < @piStart and FINISH < @piFinish and FINISH > @piStart)
     update PRICE set FINISH = @piStart where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START < @piStart and FINISH < @piFinish and FINISH > @piStart

     --开始时间大于 + 结束时间大于 + 原结束时间大于现开始时间:k > k1 and j > j1 and j1 > k
     if exists (select 1 from PRICE where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START > @piStart and FINISH > @piFinish and START < @piFinish)
     update PRICE set START = @piFinish where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START > @piStart and FINISH > @piFinish and START < @piFinish

     --开始时间大于 + 结束时间小于:k >= k1 and j <= j1(以现有时间为主语)
     if exists (select 1 from PRICE where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START >= @piStart and FINISH <= @piFinish)
     delete from PRICE where GDGID = @piGDGid and STOREGID = @piStoreGid and QPCSTR = '1*1'
      and START >= @piStart and FINISH <= @piFinish
   end

  if @@error <> 0
  begin
    set @poErrMsg = '更新价格出错'
    return(1)
  end
  ---对商品的Promote 和各店商品的Promote的处理会在日结中进行
end
GO
