SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CntrCheckBill]
(
  @BillType VarChar(32),
  @BillNUM  VarChar(16),
  @MSG VarChar(1000)=null Output
) AS
begin
  declare @Rtn Int,
          @CNum VarChar(16),
          @CNumList VarChar(1000),
          @RecCount Int,
          @ShenpiVisible Int
          
  EXEC OPTREADINT 0,'ShenpiVisible', 0, @ShenpiVisible OUTPUT

  Declare cntr_cs cursor for 
          select  b.Num NUM from cntrPAYCASHDTL a(nolock), CNTRPAYCASH b(nolock)
            where a.Num = b.Num
              and a.chgType=@BillType  
              and a.ivccode =@BillNUM
              and b.stat in (0,100)

  Open cntr_cs
  Fetch next from cntr_cs into @CNum 
  if @@fetch_status = 0
  begin
    while @@fetch_status = 0
    begin
      select @CNumList = @CNumList + @CNum 
      Fetch next from cntr_cs into @CNum
      if @@fetch_status = 0
          select @CNumList = @CNumList + ',' 
    end
    close cntr_cs
    deallocate cntr_cs 
    select @MSG = @BillType + @BillNUM  + '已被付款单' + @CNumList +  '引用' 
    Return(1)
  end
  else
  begin
    close cntr_cs 
    deallocate cntr_cs 
  end

  Declare cntr_cs1 cursor for
            select b.Num NUM from cntrPAYCASHDTL a(nolock), CNTRPAYCASH b(nolock)
               where a.Num = b.Num
                 and a.chgType=@BillType  
                 and a.ivccode =@BillNUM
                 and b.stat = 900
  
  select @CNumList = ''
  Open cntr_cs1 
  Fetch next from cntr_cs1 into @CNum 
  if @@fetch_status <> 0
    select @Rtn = 0
  else
  begin 
    if @BillType = '费用单'
      select @RecCount = Count(1) from CHGBOOK(NOLOCK) where NUM = @BillNUM and REALAMT <> PAYTOTAL
    else if @BillType = '预付款单'
      select @RecCount = Count(1) from CNTRPREPAY(NOLOCK) where NUM = @BillNUM and TOTAL <> TOTALOFF and STAT = 900
    else if @BillType = '供应商结算单' and @ShenpiVisible = 0
      select @RecCount = Count(1) from PAY(NOLOCK) where NUM = @BillNUM and AMT <> PYTOTAL and STAT = 1
    else if @BillType = '供应商结算单' and @ShenpiVisible = 1
      select @RecCount = Count(1) from PAY(NOLOCK) where NUM = @BillNUM and AMT <> PYTOTAL and STAT = 4100        
    else if @BillType = '代销结算单'
      select @RecCount = Count(1) from SVI(NOLOCK) where NUM = @BillNUM and AMT <> PAYTOTAL and STAT = 1 and CLS = '代销'
    else if @BillType = '联销结算单'
      select @RecCount = Count(1) from SVI(NOLOCK) where NUM = @BillNUM and AMT <> PAYTOTAL and STAT = 1 and CLS = '联销'
    else if @BillType = '抵扣货款单'
      select @RecCount = Count(1) from PGFBOOK(NOLOCK) where NUM = @BillNUM and REALAMT <> PAYTOTAL
    if @RecCount > 0 
      select @Rtn = 0
    else
    begin 
      while @@fetch_status = 0
      begin
        select @CNumList = @CNumList + @CNum
        Fetch next from cntr_cs1 into @CNum
        if @@fetch_status = 0
          select @CNumList = @CNumList + ','  
      end
      select @Rtn = 2
      select @MSG = @BillType + @BillNUM + '已经由付款单' + @CNumList + '付清'
    end
  end   
  close cntr_cs1 
  deallocate cntr_cs1 

  Return(@Rtn)

end
GO
