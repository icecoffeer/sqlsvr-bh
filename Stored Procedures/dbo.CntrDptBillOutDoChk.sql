SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrDptBillOutDoChk] (
  @num char(14)
)
as
begin
  declare @vendor int,
    @total money,
    @oldtotal money,
    @srcnum varchar(14),
    @ThisTotal money,
    @outTotal money,
    @totaloff money
  select @vendor = vendor, @total = total from cntrdptbill(nolock)
  where cls = '付' and num = @num
  
  select @oldtotal = total from cntrdpt(nolock)
  where vendor = @vendor
  if @oldtotal is null
  begin
    raiserror('当前该供应商无压库金额', 16, 1)
    return 1
  end else if @total > @oldtotal
  begin
    raiserror('当前该供应商的压库金额值不足', 16, 1)
    return 2
  end else begin
    update cntrdpt set 
      total = total - @total,
      lstupdtime = getdate(),
      lstupdcls = '压库金额付款单',
      lstupdnum = @num
    where vendor = @vendor
    
    --将引用的压库金额收款单变成已退款
    declare c cursor for
      select srcnum, total from CNTRDPTOUTSRCDTL where num = @num and srccls = 'DSPIN'
    open c
    fetch next from c into @srcnum, @ThisTotal
    while @@fetch_status = 0
    begin      
      select @outTotal = Total, @totaloff = totaloff from CNTRDPTBILL(nolock) where cls = '收' and num = @srcnum
      if @outTotal < @totaloff + @ThisTotal 
      begin
        raiserror('付款金额超过压库金额收款单%s剩余应退金额', 16, 1, @srcnum)
        return 3
      end else if @outTotal = @totaloff + @ThisTotal 
      begin
        update CNTRDPTBILL set totaloff = @outTotal, stat = 2400 where cls = '收' and num = @srcnum
      end else 
      begin
        update CNTRDPTBILL set totaloff = totaloff + @ThisTotal where cls = '收' and num = @srcnum
      end  
        
      fetch next from c into @srcnum, @ThisTotal
    end
    close c
    deallocate c
  end
end
GO
