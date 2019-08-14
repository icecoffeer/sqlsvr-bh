SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_INPRCPRM_ENDDATE]   
as  
begin  
  --432 进价促销单(明细) INPRICE  INPRCPRM  
  
  declare @Day_Range int  
  set @Day_Range = 31  
      
  declare c_goods cursor for  
    select GOODS.gid,   
      Convert(Datetime, Max(ISNULL(INPRICE.AFinish, '1899-12-30 00:00:00.000'))) as InPriceDate  
      from GOODS  
      left join INPRICE on GOODS.gid=INPRICE.GDGID and DATEDIFF(day, INPRICE.AFinish, getdate()) < @Day_Range  
      where (INPRICE.AFINISH is not null)   
      group by GOODS.GID  
  declare @gid int,  
          @inpricedate DateTime,  
          @maxdate DateTime,  
          @days int  
  open c_goods  
    fetch next from c_goods into @gid, @inpricedate  
    
  while @@fetch_status = 0  
  begin  
    set @maxdate = @inpricedate  
    set @days = DATEDIFF(day, @maxdate, getdate())   
    if (Abs(@days) <= @Day_Range)  
      execute MSCB_GOODS_ENDDATE @gid, '进价', @days     
    fetch next from c_goods into @gid, @inpricedate  
  end  
  close c_goods  
  deallocate c_goods  
end  

GO
