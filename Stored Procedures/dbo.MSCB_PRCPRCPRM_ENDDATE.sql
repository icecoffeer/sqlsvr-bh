SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_PRCPRCPRM_ENDDATE]   
as  
begin  
  --63 促销单(明细) PRICE   PRCPRM    
  ----432 进价促销单(明细) INPRICE  INPRCPRM  
  --462 限量促销单（明细）LMTPRICE LMTPRM  
  --568 赠品促销单(明细)  PROMOTEGFT  PROMOTEGFT GFTPRM  
  --677 组合促销单(明细)  PROMBGOODS PROMB   
  --683 捆绑促销单(明细)   PromGoods Prom     
  --684 联销率促销单(明细) PAYRATEPRICE PAYRATEPRM  
  --708 客单价促销单(明细) PromGoods prom  
  --710 客单量促销单(明细) PromGoods prom      
  
  declare @Day_Range int  
  set @Day_Range = 31  
      
  declare c_goods cursor for  
    select GOODS.gid,   
      Convert(Datetime, Max(ISNULL(PRICE.Finish, '1899-12-30 00:00:00.000'))) as PriceDate,  
      --Convert(Datetime, Max(ISNULL(INPRICE.AFinish, '1899-12-30 00:00:00.000'))) as InPriceDate,  
      Convert(Datetime, Max(ISNULL(LMTPRICE.AFinish, '1899-12-30 00:00:00.000'))) as LmtPriceDate,  
      Convert(Datetime, Max(ISNULL(PAYRATEPRICE.AFinish, '1899-12-30 00:00:00.000'))) as PayRatePriceDate,  
      Convert(Datetime, Max(ISNULL(Prom.AFinish, '1899-12-30 00:00:00.000'))) as PromDate  
      from GOODS  
      left join PRICE on GOODS.gid=PRICE.GDGID and DATEDIFF(day, PRICE.Finish, getdate()) < @Day_Range  
      --left join INPRICE on GOODS.gid=INPRICE.GDGID and DATEDIFF(day, INPRICE.AFinish, getdate()) < @Day_Range  
      left join LMTPRICE on GOODS.gid=LMTPRICE.GDGID and DATEDIFF(day, LMTPRICE.AFinish, getdate()) < @Day_Range  
      left join PAYRATEPRICE on GOODS.gid=PAYRATEPRICE.GDGID and DATEDIFF(day, PAYRATEPRICE.AFinish, getdate()) < @Day_Range  
      left join PromGoods on GOODS.gid=PromGoods.GDGID  
      left join prom on PromGoods.NUM=prom.NUM and PromGoods.CLS=prom.CLS and DATEDIFF(day, prom.AFinish, getdate()) < @Day_Range  
      where (PRICE.FINISH is not null) or (LMTPRICE.AFINISH is not null) or (PAYRATEPRICE.AFINISH is not null) or (prom.AFINISH is not NULL) --or (INPRICE.AFINISH is not null)   
      group by GOODS.GID  
  declare @gid int,  
          @pricedate DateTime,  
          --@inpricedate DateTime,  
          @lmtpricedate DateTime,  
          @payratepricedate DateTime,  
          @promdate DateTime,  
          @maxdate DateTime,  
          @days int  
  open c_goods  
    fetch next from c_goods into @gid, @pricedate, @lmtpricedate, @payratepricedate, @promdate  
    
  while @@fetch_status = 0  
  begin  
    set @maxdate = @pricedate  
    --if (@maxdate < @inpricedate) set @maxdate=@inpricedate  
    if (@maxdate < @lmtpricedate) set @maxdate=@lmtpricedate  
    if (@maxdate < @payratepricedate) set @maxdate=@payratepricedate  
    if (@maxdate < @promdate) set @maxdate=@promdate  
    set @days = DATEDIFF(day, @maxdate, getdate())   
    if (Abs(@days) <= @Day_Range)  
      execute MSCB_GOODS_ENDDATE @gid, '售价', @days     
    fetch next from c_goods into @gid, @pricedate, @lmtpricedate, @payratepricedate, @promdate  
  end  
  close c_goods  
  deallocate c_goods  
end  

GO
