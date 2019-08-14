SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYCHK](
  @num char(10),
  @errmsg varchar(200) = '' output
) --with encryption
as
begin
  declare
    @return_status int,
    @cur_date datetime,
    @cur_settleno int,
    @stat int,
    @fildate datetime,
    @wrh int,
    @billto int,
    @line smallint,
    @gdgid int,
    @qty money,
    @total money,
    @stotal money,
    @inprc money,
    @rtlprc money,
    @bnum char(10),
    @bnumcanbenull smallint,
    @fromcls char(14),
    @fromnum char(14),
    @fromline smallint,
    @money1 money, @money2 money, @string1 varchar(100), @string2 varchar(100),
    @gdcode varchar(20),
    @src_qty money, @src_payqty money

  --Fanduyi 1634 2004.01.30
  declare
    @optusecntr int,
    @genchkbookoutmsg varchar(255),
    @genchkbookout int,
    @IOPER INT,
    @STROPER VARCHAR(30)

  select
    @cur_date = convert(datetime, convert(char,getdate(),102)),
    @cur_settleno = SETTLENO,
    @stat = STAT,
    @fildate = FILDATE,
    @wrh = WRH,
    @billto = BILLTO
    from PAY where NUM = @num
  if @stat <> 0
  begin
    raiserror('审核的不是未审核的单据', 16, 1)
    return(1)
  end
  if exists(select 1 from Vendor(nolock) where gid = @billto and UPay = 1)
  begin
    raiserror('该供应商被限制成统一结算供应商不能继续审核。', 16, 1)
    return(1)
  end
  select @cur_settleno = max(NO) from MONTHSETTLE
  update PAY set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno
  where NUM = @num
  select @return_status = 0
  select @bnumcanbenull = BNUMCANBENULL from SYSTEM

  declare c_pay cursor for
    select LINE, GDGID, QTY, TOTAL, STOTAL, INPRC, RTLPRC, BNUM,
      FROMCLS, FROMNUM, FROMLINE
    from PAYDTL where NUM = @num
  open c_pay
  fetch next from c_pay into @line, @gdgid, @qty, @total, @stotal,
    @inprc, @rtlprc, @bnum, @fromcls, @fromnum, @fromline
  while @@fetch_status = 0 begin
    if @bnum is null and @bnumcanbenull = 0 begin
      raiserror('必须输入批号', 16, 1)
      /* 00-12-8 10:36 */
      select @return_status = 1032
      break
    end
    /* 回填自营进,自营进退,直配出,直配出退,供应商返利 */
    /* 2000-05-22 直销, 直销退*/
    if @fromcls is not null and @fromnum is not null and @fromline is not null
    begin
      if @fromcls = '自营进'
      begin

        /* 2000-1-3 使错误信息更友好:把stkindtl的CONSTRAINT
        付款和退货数必须不大于进货数 CHECK (QTY < 0 OR QTY-BCKQTY-PAYQTY>=0)
        在这里检查 */
        select @money1 = QTY, @money2 = BCKQTY+PAYQTY
        from STKINDTL
        where CLS = '自营' and NUM = @fromnum and LINE = @fromline
        if (@money1 < 0) or (@money1-@money2-@qty >= 0)
          update STKINDTL set PAYQTY = PAYQTY + @qty, PAYAMT = PAYAMT + @total
          where CLS = '自营' and NUM = @fromnum and LINE = @fromline
        else
        begin
          select @return_status = 2,
                 @string1 = ltrim(convert(char,@money1)),
                 @string2 = ltrim(convert(char, @money2))
          select @gdcode = rtrim(CODE) from goods where gid = @gdgid
          raiserror('付款和退货数必须不大于进货数: 第%d行, 商品%s, 进货单号%s, 进货单行号%d, 进货数%s, 已付款数或者已退货数: %s',
            16, 1, @line, @gdcode, @fromnum, @fromline, @string1, @string2)
          /* 00-12-8 10:36 */
          select @return_status = 1033
          break
        end
      end
      else if @fromcls = '自营进退'
      begin

        -- 自营进退审核时检查明细
        /* 2007-10-18 使错误信息更友好:把STKINBCKDTL的CONSTRAINT
        付款和退货数必须<=进货数 CHECK (QTY < 0 OR QTY-PAYQTY>=0)
        在这里检查 */
        select @money1 = QTY, @money2 = PAYQTY
        from STKINBCKDTL
        where CLS = '自营' and NUM = @fromnum and LINE = @fromline
          if (@money1 < 0) or (@money1-@money2+@qty >= 0)
            update STKINBCKDTL set PAYQTY = PAYQTY - @qty, PAYAMT = PAYAMT - @total
            where CLS = '自营' and NUM = @fromnum and LINE = @fromline
          else
          begin
            select @return_status = 2,
                   @string1 = ltrim(convert(char,@money1)),
                   @string2 = ltrim(convert(char, @money2))
            select @gdcode = rtrim(CODE) from goods where gid = @gdgid
            raiserror('付款和退货数必须<=进货数: 第%d行, 商品%s, 进货单号%s, 进货单行号%d, 进货数%s, 已付款数或者已退货数: %s',
              16, 1, @line, @gdcode, @fromnum, @fromline, @string1, @string2)
             /* 00-12-8 10:36 */
             select @return_status = 1033
             break
          end
      end

      else
      if @fromcls = '直配出'
      begin

        --zhangzhen 直配出审核时也要检查明细
        /* 2007-10-15 使错误信息更友好:把diralcdtl的CONSTRAINT
        付款和退货数必须<=进货数 CHECK (QTY < 0 OR QTY-BCKQTY-PAYQTY>=0)
        在这里检查 */
        select @money1 = QTY, @money2 = BCKQTY+PAYQTY
        from DIRALCDTL
        where CLS = '直配出' and NUM = @fromnum and LINE = @fromline
        if (@money1 < 0) or (@money1-@money2-@qty >= 0)
          update DIRALCDTL set PAYQTY = PAYQTY + @qty, PAYAMT = PAYAMT + @total
          where CLS = '直配出' and NUM = @fromnum and LINE = @fromline
        else
        begin
          select @return_status = 2,
                 @string1 = ltrim(convert(char,@money1)),
                 @string2 = ltrim(convert(char, @money2))
          select @gdcode = rtrim(CODE) from goods where gid = @gdgid
          raiserror('付款和退货数必须<=进货数: 第%d行, 商品%s, 进货单号%s, 进货单行号%d, 进货数%s, 已付款数或者已退货数: %s',
            16, 1, @line, @gdcode, @fromnum, @fromline, @string1, @string2)
           /* 00-12-8 10:36 */
           select @return_status = 1033
           break
        end
      end
        --update DIRALCDTL set PAYQTY = PAYQTY + @qty, PAYAMT = PAYAMT + @total
        --where CLS = '直配出' and NUM = @fromnum and LINE = @fromline

      else
      if @fromcls = '直配出退'
      begin

        -- 直配出退审核时检查明细
        /* 2007-10-18 使错误信息更友好:把diralcdtl的CONSTRAINT
        付款和退货数必须<=进货数 CHECK (QTY < 0 OR QTY-PAYQTY>=0)
        在这里检查 */
        select @money1 = QTY, @money2 = PAYQTY
        from DIRALCDTL
        where CLS = '直配出退' and NUM = @fromnum and LINE = @fromline
        if (@money1 < 0) or (@money1-@money2+@qty >= 0)
          update DIRALCDTL set PAYQTY = PAYQTY - @qty, PAYAMT = PAYAMT - @total
          where CLS = '直配出退' and NUM = @fromnum and LINE = @fromline
        else
        begin
          select @return_status = 2,
                 @string1 = ltrim(convert(char,@money1)),
                 @string2 = ltrim(convert(char, @money2))
          select @gdcode = rtrim(CODE) from goods where gid = @gdgid
          raiserror('付款和退货数必须<=进货数: 第%d行, 商品%s, 进货单号%s, 进货单行号%d, 进货数%s, 已付款数或者已退货数: %s',
            16, 1, @line, @gdcode, @fromnum, @fromline, @string1, @string2)
           /* 00-12-8 10:36 */
           select @return_status = 1033
           break
        end
      end

      else if @fromcls = '直销'
      begin
        select @src_qty = QTY, @src_payqty = isnull(PAYQTY,0)
        from DIRALCDTL
        where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
        if abs(@src_payqty + @qty) > abs(@src_qty)
        begin
          select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
              rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' +
              '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) +
              '已结数量' + ltrim(convert(char,@src_payqty)) + char(10) + char(13) +
              '本次结算数量' + ltrim(convert(char,@qty))
          raiserror(@errmsg, 16, 1)
          /* 00-12-8 10:36 */
          select @return_status = 1034
          break
        end
        update DIRALCDTL
        set PAYQTY = ISNULL(PAYQTY,0) + @qty,/*2002-02-25*/
            PAYAMT = ISNULL(PAYAMT,0) + @total
        where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
        if exists (select * from DIRALCDTL where CLS = @fromcls and NUM = @fromnum
        and abs(QTY) > abs(PAYQTY))
          update DIRALC set FINISHED = 0 where CLS = @fromcls and NUM = @fromnum
        else
          update DIRALC set FINISHED = 1 where CLS = @fromcls and NUM = @fromnum
        end
      else if @fromcls = '直销退'
      begin
        select @src_qty = QTY, @src_payqty = isnull(PAYQTY,0)
        from DIRALCDTL
        where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
        if abs(@src_payqty + @qty) > abs(@src_qty)
        begin
          select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
              rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' +
              '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) +
              '已结数量' + ltrim(convert(char,@src_payqty)) + char(10) + char(13) +
              '本次结算数量' + ltrim(convert(char,@qty))
          raiserror(@errmsg, 16, 1)
          /* 00-12-8 10:36 */
          select @return_status = 1034
          break
        end
        update DIRALCDTL
        set PAYQTY = ISNULL(PAYQTY,0) - @qty,/*2002-02-25*/
            PAYAMT = ISNULL(PAYAMT,0) - @total
        where CLS = @fromcls and NUM = @fromnum and LINE = @fromline
        if exists (select * from DIRALCDTL where CLS = @fromcls and NUM = @fromnum
        and abs(QTY) > abs(PAYQTY))
          update DIRALC set FINISHED = 0 where CLS = @fromcls and NUM = @fromnum
        else
          update DIRALC set FINISHED = 1 where CLS = @fromcls and NUM = @fromnum

      end
      else if @fromcls = '批次调整' and (select batchflag from system) = 2  --2003.03.24 wang xin
  begin
            update IPA2SWDTL set PAYAMT = ISNULL(PAYAMT,0) + @total
            where CLS = '批次' and NUM = @fromnum and SUBWRH = @fromline
      if exists(select * from IPA2SWDTL where CLS = '批次' and NUM = @fromnum and abs(ADJCOST) > abs(PAYAMT))
               update IPA2 set FINISHED = 0 where CLS = '批次' and NUM = @fromnum
            else
    update IPA2 set FINISHED = 1 where CLS = '批次' and NUM = @fromnum
  end
      else if @fromcls = '成本调整' and (select batchflag from system) = 2
      begin
     update IPA2SWDTL set PAYAMT = ISNULL(PAYAMT, 0) + @total
           where CLS = '金额' and NUM = @fromnum and SUBWRH = @fromline
           if exists(select * from IPA2SWDTL where CLS = '金额' and NUM = @fromnum and abs(ADJCOST) > abs(PAYAMT))
               update IPA2 set FINISHED = 0 where CLS = '金额' and NUM = @fromnum
           else
               update IPA2 set FINISHED = 1 where CLS ='金额' and NUM = @fromnum
      end
      else if @fromcls = '供应商返利'
      begin
        select @src_qty = QTY, @src_payqty = isnull(PAYQTY,0)
        from INPRCADJNOTIFYBCKDTL
        where NUM = @fromnum and LINE = @fromline
        if abs(@src_payqty + @qty) > abs(@src_qty)
        begin
          select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
              rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' +
              '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) +
              '已结数量' + ltrim(convert(char,@src_payqty)) + char(10) + char(13) +
              '本次结算数量' + ltrim(convert(char,@qty))
          raiserror(@errmsg, 16, 1)
          /* 00-12-8 10:36 */
          select @return_status = 1034
          break
        end
        update INPRCADJNOTIFYBCKDTL
        set PAYQTY = ISNULL(PAYQTY,0) + @qty,
            PAYAMT = ISNULL(PAYAMT,0) + @total
        where NUM = @fromnum and LINE = @fromline
        if exists (select 1 from INPRCADJNOTIFYBCKDTL where NUM = @fromnum
        and abs(QTY) > abs(PAYQTY))
          update INPRCADJNOTIFY set FINISHED = 0 where NUM = @fromnum
        else
          update INPRCADJNOTIFY set FINISHED = 1 where NUM = @fromnum

        set @qty = 0 -- 下面记录报表时,已结数量记为0
      end
      else if @fromcls = '销售定货进货'
      begin
        select @src_qty = ARVQTY, @src_payqty = isnull(PAYQTY, 0)
        from PURCHASEORDERDTL(nolock)
        where NUM = @fromnum and cls = '销售进货' and LINE = @fromline
        if abs(@src_payqty + @qty) > abs(@src_qty)
        begin
          select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
              rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' +
              '单据数量' + ltrim(convert(char,@src_qty))  + char(10) + char(13) +
              '已结数量' + ltrim(convert(char,@src_payqty)) + char(10) + char(13) +
              '本次结算数量' + ltrim(convert(char,@qty))
          raiserror(@errmsg, 16, 1)
          /* 00-12-8 10:36 */
          select @return_status = 1034
          break
        end
        update PURCHASEORDERDTL
        set PAYQTY = ISNULL(PAYQTY, 0) + abs(@qty),
            PAYAMT = ISNULL(PAYAMT, 0) + abs(@total)
        where NUM = @fromnum and cls = '销售进货' and LINE = @fromline
        if exists (select 1 from PURCHASEORDERDTL where NUM = @fromnum and cls = '销售进货'
          and abs(ARVQTY) > abs(PAYQTY))
          update PURCHASEORDER set FINISHED = 0 where NUM = @fromnum and cls = '销售进货'
        else
          update PURCHASEORDER set FINISHED = 1 where NUM = @fromnum and cls = '销售进货'
      end
      else if @fromcls = '促销补差'
      begin
        select @src_qty = P.QTY, @src_payqty = isnull(P.PAYQTY,0)
        from PRMOFFSETDTL P, PRMOFFSET M
        where P.NUM = @fromnum and P.LINE = @fromline and P.NUM = M.NUM
        if abs(@src_payqty) + abs(@qty) > abs(@src_qty)
        begin
          select @errmsg = '结算数超过了单据上的数量: ' + char(10) + char(13) +
              rtrim(@fromcls) + '单' + @fromnum + '第' + ltrim(convert(char,@fromline)) + '行' +
              '单据数量' + ltrim(convert(char,abs(@src_qty)))  + char(10) + char(13) +
              '已结数量' + ltrim(convert(char,abs(@src_payqty))) + char(10) + char(13) +
              '本次结算数量' + ltrim(convert(char,abs(@qty)))
          raiserror(@errmsg, 16, 1)
          select @return_status = 1034
          break
        end
        update PRMOFFSETDTL
        set PAYQTY = ISNULL(PAYQTY, 0) + abs(@qty),
            PAYAMT = ISNULL(PAYAMT, 0) + abs(@total)
        from PRMOFFSET M
        where PRMOFFSETDTL.NUM = @fromnum and PRMOFFSETDTL.LINE = @fromline and PRMOFFSETDTL.Num = M.Num
        if exists (select * from PRMOFFSETDTL where NUM = @fromnum
        and abs(QTY) > abs(PAYQTY))
          update PRMOFFSET set PAYFLAG = 0 where NUM = @fromnum
        else
          update PRMOFFSET set PAYFLAG = 1 where NUM = @fromnum
      end
    end
    /* 写报表 */
    execute @return_status = PAYDTLCHKCRT
      @cur_date, @cur_settleno, @cur_date, @cur_settleno, @billto,
      @gdgid, @wrh, @qty,
      @total, @stotal, @inprc, @rtlprc
    if @return_status <> 0 break
    fetch next from c_pay into @line, @gdgid, @qty, @total, @stotal,
      @inprc, @rtlprc, @bnum, @fromcls, @fromnum, @fromline
  end
  close c_pay
  deallocate c_pay

  if @return_status != 0 return(@return_status)

  /* 置已结标志 */
  declare c_pay cursor for
    select distinct FROMCLS, FROMNUM from PAYDTL
    where NUM = @num
  open c_pay
  fetch next from c_pay into @fromcls, @fromnum
  while @@fetch_status = 0
  begin
    if @fromcls = '自营进'
    begin
      if exists (select * from STKINDTL where CLS = '自营' and NUM = @fromnum
      and abs(QTY) > abs(PAYQTY + BCKQTY))
        update STKIN set FINISHED = 0 where CLS = '自营' and NUM = @fromnum
      else
        update STKIN set FINISHED = 1 where CLS = '自营' and NUM = @fromnum
    end else if @fromcls = '自营进退'
    begin
      if exists (select * from STKINBCKDTL where CLS = '自营' and NUM = @fromnum
      and abs(QTY) > abs(PAYQTY))
        update STKINBCK set FINISHED = 0 where CLS = '自营' and NUM = @fromnum
      else
        update STKINBCK set FINISHED = 1 where CLS = '自营' and NUM = @fromnum
    end else if @fromcls = '直配出'
    begin
      if exists (select * from DIRALCDTL where CLS = '直配出' and NUM = @fromnum
      and abs(QTY) > abs(PAYQTY + BCKQTY))
        update DIRALC set FINISHED = 0 where CLS = '直配出' and NUM = @fromnum
      else
        update DIRALC set FINISHED = 1 where CLS = '直配出' and NUM = @fromnum
    end else if @fromcls = '直配出退'
    begin
      if exists (select * from DIRALCDTL where CLS = '直配出退' and NUM = @fromnum
      and abs(QTY) > abs(PAYQTY))
        update DIRALC set FINISHED = 0 where CLS = '直配出退' and NUM = @fromnum
      else

    update DIRALC set FINISHED = 1 where CLS = '直配出退' and NUM = @fromnum
    end else if @fromcls = '批次调整' --2003.03.24 wang xin
    begin
  if exists(select * from IPA2SWDTL where CLS = '批次' and NUM = @fromnum and ADJCOST > PAYAMT)
            update IPA2 set FINISHED = 0 where CLS = '批次' and NUM = @fromnum
        else
      update IPA2 set FINISHED = 1 where CLS = '批次' and NUM = @fromnum
    end else if @fromcls = '成本调整'
    begin
         if exists(select * from IPA2SWDTL where CLS = '金额' and NUM = @fromnum and ADJCOST > PAYAMT)
             update IPA2 set FINISHED = 0 where CLS = '金额' and NUM = @fromnum
        else
            update IPA2 set FINISHED = 1 where CLS = '金额' and NUM = @fromnum
    end else if @fromcls = '供应商返利'
    begin
         if exists(select 1 from INPRCADJNOTIFYBCKDTL where NUM = @fromnum and AMT > PAYAMT)
             update INPRCADJNOTIFY set FINISHED = 0 where NUM = @fromnum
        else
            update INPRCADJNOTIFY set FINISHED = 1 where NUM = @fromnum
    end
    else if @fromcls = '销售进货'
    begin
         if exists(select 1 from PURCHASEORDERDTL where NUM = @fromnum and cls = '销售进货' and TOTAL > PAYAMT)
             update PURCHASEORDER set FINISHED = 0 where NUM = @fromnum and cls = '销售进货'
        else
            update PURCHASEORDER set FINISHED = 1 where NUM = @fromnum and cls = '销售进货'
    end
    else if @fromcls = '促销补差'
    begin
        if exists (select * from PRMOFFSETDTL where NUM = @fromnum
        and abs(QTY) > abs(PAYQTY))
          update PRMOFFSET set PAYFLAG = 0 where NUM = @fromnum
        else
          update PRMOFFSET set PAYFLAG = 1 where NUM = @fromnum
    end
    fetch next from c_pay into @fromcls, @fromnum
  end
  close c_pay
  deallocate c_pay

  --Fanduoyi 1634 2004.01.30
  EXEC OPTREADINT 0, 'usecntr', 0, @optusecntr OUTPUT
  if @optusecntr = 1
  begin
    Select @stroper = rtrim(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
    Select @ioper = isnull(gid,1) from employee (nolock) where code like @stroper
    execute @genchkbookout = PAYGENCHGBOOK @num, '供应商结算单', @ioper, @genchkbookoutmsg output
    if ISNULL(@genchkbookoutmsg, '') <> '' begin
      raiserror(@genchkbookoutmsg, 16, 1)
      return(1)
    end
  end
--added by zz 审核后自动发送到结算中心
  declare @SRC int
  declare @CLECENT int
  declare @USERGID int

  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SET @CLECENT = NULL
  SELECT @SRC = SRC, @CLECENT = CLECENT FROM PAY(NOLOCK)
    WHERE NUM = @NUM

  IF @SRC IS NULL RETURN 0
  IF @USERGID = @SRC
  BEGIN
    IF @CLECENT IS NULL OR @CLECENT = @USERGID
      RETURN 0
  END
  EXEC @return_status = PAYSND @NUM, @errmsg
   IF @return_status <> 0 RETURN @return_status
--added end
  return @return_status
end
GO
