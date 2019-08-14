SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RcpFillBack]
  @fromcls char(10),
  @fromnum char(10),
  @fromline int,
  @qty money,
  @total money,
  @errmsg varchar(100) = '' output
as
begin
  declare @src_qty money, @src_rcpqty money
  
  if @fromcls = '批发' begin
    
    /* 2000-05-16 */
    select @src_qty = QTY, @src_rcpqty = isnull(RCPQTY,0)
    from STKOUTDTL
    where CLS = '批发' and NUM = @fromnum and LINE = @fromline
    if abs(@src_rcpqty + @qty) > abs(@src_qty)
    begin
      select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
          '批发单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' + 
          '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) + 
          '已结数量' + ltrim(convert(char,@src_rcpqty)) + char(10) + char(13) +
          '本次结算数量' + ltrim(convert(char,@qty))
      return 1024
    end
    
    update STKOUTDTL
    set RCPQTY = ISNULL(RCPQTY,0) + @qty,
        RCPAMT = ISNULL(RCPAMT,0) + @total
    where CLS = '批发' and NUM = @fromnum and LINE = @fromline
    if exists (select * from STKOUTDTL where CLS = '批发' and NUM = @fromnum
    and QTY > RCPQTY)
      update STKOUT set FINISHED = 0 where CLS = '批发' and NUM = @fromnum
    else
      update STKOUT set FINISHED = 1 where CLS = '批发' and NUM = @fromnum
  end
  else if @fromcls = '批发退' begin

    /* 2000-05-16 */
    select @src_qty = QTY, @src_rcpqty = isnull(RCPQTY,0)
    from STKOUTBCKDTL
    where CLS = '批发退' and NUM = @fromnum and LINE = @fromline
    if abs(@src_rcpqty + @qty) > abs(@src_qty)
    begin
      select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
          '批发退货单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' + 
          '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) + 
          '已结数量' + ltrim(convert(char,@src_rcpqty)) + char(10) + char(13) +
          '本次结算数量' + ltrim(convert(char,@qty))
      return 1024
    end

    update STKOUTBCKDTL
    set RCPQTY = ISNULL(RCPQTY,0) - @qty,
        RCPAMT = ISNULL(RCPAMT,0) - @total
    where CLS = '批发' and NUM = @fromnum and LINE = @fromline
    if exists (select * from STKOUTBCKDTL where CLS = '批发' and NUM = @fromnum
    and QTY > RCPQTY)
      update STKOUTBCK set FINISHED = 0 where CLS = '批发' and NUM = @fromnum
    else
      update STKOUTBCK set FINISHED = 1 where CLS = '批发' and NUM = @fromnum
  end
  else if @fromcls in ('实物退', '销售退', '仓库退', '提单退') begin

    /* 2000-05-16 */
    select @src_qty = QTY, @src_rcpqty = isnull(RCPQTY,0)
    from SALEBCKDTL
    where NUM = @fromnum and LINE = @fromline
    if abs(@src_rcpqty + @qty) > abs(@src_qty)
    begin
      select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
          '批发退货单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' + 
          '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) + 
          '已结数量' + ltrim(convert(char,@src_rcpqty)) + char(10) + char(13) +
          '本次结算数量' + ltrim(convert(char,@qty))
      return 1024
    end

    update SALEBCKDTL
    set RCPQTY = ISNULL(RCPQTY,0) - @qty,
        RCPAMT = ISNULL(RCPAMT,0) - @total
    where NUM = @fromnum and LINE = @fromline
    if exists (select * from SALEBCKDTL where NUM = @fromnum and QTY > RCPQTY)
      update SALEBCK set FINISHED = 0 where NUM = @fromnum
    else
      update SALEBCK set FINISHED = 1 where NUM = @fromnum
  end
  /* 2000-05-22 */
  else if @fromcls = '直销' begin
    select @src_qty = QTY, @src_rcpqty = isnull(RCPQTY,0)
    from DIRALCDTL
    where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
    if abs(@src_rcpqty + @qty) > abs(@src_qty)
    begin
      select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
          rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' + 
          '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) + 
          '已结数量' + ltrim(convert(char,@src_rcpqty)) + char(10) + char(13) +
          '本次结算数量' + ltrim(convert(char,@qty))
      return 1024
    end
    update DIRALCDTL
    set RCPQTY = ISNULL(RCPQTY,0) + @qty,
        RCPAMT = ISNULL(RCPAMT,0) + @total
    where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
    if exists (select * from DIRALCDTL where CLS = @fromcls and NUM = @fromnum
    and QTY > RCPQTY)
      update DIRALC set RCPFINISHED = 0 where CLS = @fromcls and NUM = @fromnum
    else
      update DIRALC set RCPFINISHED = 1 where CLS = @fromcls and NUM = @fromnum
  end
  else if @fromcls = '直销退' begin
    select @src_qty = QTY, @src_rcpqty = isnull(RCPQTY,0)
    from DIRALCDTL
    where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
    if abs(@src_rcpqty + @qty) > abs(@src_qty)
    begin
      select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
          rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' + 
          '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) + 
          '已结数量' + ltrim(convert(char,@src_rcpqty)) + char(10) + char(13) +
          '本次结算数量' + ltrim(convert(char,@qty))
      return 1024
    end
    update DIRALCDTL
    set RCPQTY = ISNULL(RCPQTY,0) - @qty,
        RCPAMT = ISNULL(RCPAMT,0) - @total
    where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
    if exists (select * from DIRALCDTL where CLS = @fromcls and NUM = @fromnum
    and QTY > RCPQTY)
      update DIRALC set RCPFINISHED = 0 where CLS = @fromcls and NUM = @fromnum
    else
      update DIRALC set RCPFINISHED = 1 where CLS = @fromcls and NUM = @fromnum
  end
  return 0
end

GO
