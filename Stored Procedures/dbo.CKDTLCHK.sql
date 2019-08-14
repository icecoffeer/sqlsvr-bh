SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CKDTLCHK](
  @p_num char(10),
  @p_line int,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200) = '' output
) --with encryption
as
begin
  /*
  99-5-17: 对没有盘点盈亏的不写库存和库存报表(HLJ)
  */
  declare
    @cur_date datetime,
    @cur_settleno int,

    @m_num char(10),
    @m_settleno int,
    @m_cls smallint,
    @d_gdgid int,
    @d_wrh int,
    @d_wrh_saved int,
    @d_acntqty money,
    @d_qty money,
    @d_acnttl money,
    @d_total money,
    @d_ovfamt money,
    @d_losamt money,
    @d_inprc money,
    @d_rtlprc money,
    @d_line int,
    @i_qty money,
    @i_total money,
    @g_chkvd smallint,
    @w_chkvd smallint,
    @g_inprc money,
    @g_rtlprc money,
    @g_lstinprc money,
    @store int,
    @ysettleno int,
    @d_subwrh int,
    @return_status int,
    /*2002-10-11*/
    @d_cost money, @money1 money, @d_invprc money, @d_invcost money,
    @d_invadj money,
    @sale smallint/*2003-06-13*/

  select
    @m_num = NUM,
    @m_settleno = SETTLENO,
    @m_cls = CLS,
    @cur_date = convert(datetime, convert(char, CKDATE, 102)),
    @cur_settleno = SETTLENO
    from CK(nolock) where NUM = @p_num
  select
    @d_gdgid = GDGID,
    @d_wrh = WRH,
    @d_wrh_saved = WRH,
    @d_acntqty = ACNTQTY,
    @d_qty = QTY,
    @d_acnttl = ACNTTL,
    @d_total = TOTAL,
    @d_ovfamt = OVFAMT,
    @d_losamt = LOSAMT,
    @d_inprc = INPRC,
    @d_rtlprc = RTLPRC,
    @d_subwrh = subwrh
    from PCKS(nolock) where LINE = @p_line
  if @@rowcount = 0 begin
    raiserror('没有该盘点汇总记录.', 16, 1)
    return(1)
  end

  --ShenMin
  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'PCKS', @piCls = '', @piNum = @p_num, @piToStat = 1, @piOper = @Oper, @piWrh = @d_wrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
      raiserror(@errmsg, 16, 1)
      return(1)
    end

  /* 如果这个仓位是一个门店 */
  select @store = null
  select @store = GID from STORE(nolock) where GID = @d_wrh
  if @store is null select @store = USERGID from SYSTEM(nolock)
  else select @d_wrh = 1

/* 2001-03-01 将后面的 SELECT 语句移到这里 */
  select @g_inprc = INPRC, @g_rtlprc = RTLPRC, @sale = SALE/*2003-06-13*/ from GOODS(nolock) where GID = @d_gdgid

/* 2001-04-19 同时盘点金额也要等于数量乘当前商品的核算售价 */
  select @d_Total = convert(decimal(20,2), @d_Qty * @g_rtlprc)
  select @d_acnttl = convert(decimal(20,2), @d_acntqty * @g_rtlprc)
  select @d_ovfamt = 0, @d_losamt = 0
  if @d_Total>@d_acnttl
  select @d_ovfamt = @d_total - @d_acnttl
  else
  select @d_losamt = @d_acnttl - @d_total
/*---- end by hxs ---*/

  select @d_line = max(LINE) + 1 from CKDTL(nolock) where NUM = @p_num
  if @d_line is null select @d_line = 1
  if @m_cls = 2 begin
    update PCKDTL set
      CKNUM = @p_num,
      CKLINE = @d_line,
      STAT = 2
      where CKNUM is null and LINE = @p_line
    delete from PCKS where LINE = @p_line
  end else begin
    if @store <> (select usergid from system(nolock)) or (select ISPKG from GOODS(nolock) where GID = @d_gdgid) = 0 /* Modified by qyx 2002-4-15 */
    begin
      select @i_qty = null
      if @d_subwrh = 0
        select
          @i_qty = sum(QTY),
          @i_total = sum(TOTAL)
          from INV(nolock) where WRH = @d_wrh and GDGID = @d_gdgid and STORE = @store
      else
        select @i_qty =sum(qty), @i_total = sum(total) from subwrhinv(nolock)
         where wrh =@d_wrh and gdgid = @d_gdgid and subwrh =@d_subwrh
      if @i_qty is null
      begin
        select @i_qty = 0, @i_total = 0
        select @w_chkvd = CHKVD from WAREHOUSE(nolock) where GID = @d_wrh_saved
        select @g_chkvd = CHKVD from GOODS(nolock) where GID = @d_gdgid

        /* 2000-06-26 批次货位 */
        if (select batchflag from system(nolock)) = 1 begin
          if @d_subwrh = 0 begin
            execute @return_status = GetSubWrhBatch @d_wrh, @d_subwrh output, @errmsg output
            if @return_status <> 0 return @return_status
          end
          select @g_lstinprc = LSTINPRC from GOODS(NOLOCK)
        end

        if @d_subwrh = 0  begin
          if @w_chkvd = 1 and @g_chkvd = 1
            insert into INV(STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
            values (@store, @d_wrh, @d_gdgid, 0, 0, getdate())
          else
            insert into INV(STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
             values (@store, @d_wrh, @d_gdgid, 0, 0, NULL)
           select @i_qty = 0, @i_total = 0
        end else begin
           insert into subwrhinv(wrh ,subwrh, gdgid, qty, total, lstinprc)
                 values(@d_wrh,@d_subwrh, @d_gdgid, 0, 0, /* 2000-06-26 */@g_lstinprc )
           insert into INV(STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
             values (@store, @d_wrh, @d_gdgid, 0, 0, NULL)
           select @i_qty = 0, @i_total = 0
        end
      end

      if @sale =1 begin/*2003-06-13*/
      /*2002-10-11*/
      select @d_invprc = INVPRC, @d_invcost = INVCOST
        from CKINV(nolock) where WRH = @d_wrh_saved and GDGID = @d_gdgid
      select @money1 = @d_qty - @d_acntqty
      exec UPDINVPRC '盘点', @d_gdgid, @money1, 0, @d_wrh, @d_cost output
      select @d_invadj = @d_cost - (round(@d_qty * @d_invprc, 2) - @d_invcost)
      insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I)
        values (@cur_date, @cur_settleno, @d_wrh, @d_gdgid,
        @d_qty - @d_acntqty, @d_invadj)
      end
      -- 考虑多到效期,任选一条
      if @d_qty-@d_acntqty <> 0
      begin
      update INV set
        QTY = QTY + @d_qty - @d_acntqty,
        TOTAL = TOTAL + @d_total - @d_acnttl
        where NUM =
        (select min(NUM) from INV(nolock)
        where WRH = @d_wrh and GDGID = @d_gdgid and STORE = @store)
       if @d_subwrh <> 0
       update subwrhinv  set
         qty = qty +@d_qty-@d_acntqty    ,
         total = total + @d_total- @d_acnttl
         where wrh = @d_wrh and gdgid = @d_gdgid and subwrh =@d_subwrh
      end
      ---
      /* 写库存报表 */
      if @store = (select usergid from system(nolock)) and @d_qty-@d_acntqty <> 0
      begin
        select @ysettleno = max(NO) from YEARSETTLE(nolock)
        execute CRTINVRPT @store, @cur_settleno, @cur_date, @d_wrh, @d_gdgid
        update INVDRPT
          set FQ = FQ + @d_qty - @d_acntqty, FT = FT + @d_total - @d_acnttl,
          LSTUPDTIME = getdate()
          where ADATE = @cur_date and BGDGID = @d_gdgid and BWRH = @d_wrh
          and ASETTLENO = @cur_settleno and ASTORE = @store
        update INVMRPT
          set FQ = FQ + @d_qty - @d_acntqty, FT = FT + @d_total - @d_acnttl
          where ASETTLENO = @cur_settleno and BGDGID = @d_gdgid
          and BWRH = @d_wrh and ASTORE = @store
        update INVYRPT
          set FQ = FQ + @d_qty - @d_acntqty, FT = FT + @d_total - @d_acnttl
          where ASETTLENO = @ysettleno and BGDGID = @d_gdgid
          and BWRH = @d_wrh and ASTORE = @store
/* 2001-03-01 改用 @g_inprc,@g_rtlprc 替换@d_inprc, @d_rtlprc 写报表 */
        if @d_qty > @d_acntqty begin
          if @sale = 1/*2003-06-13*/
          insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, ASTORE,
            PY_Q, PY_A, PY_I, PY_R,
            PK_Q, PK_A, PK_I, PK_R
            ) values (
            @cur_date, @cur_settleno, @d_wrh_saved, @d_gdgid, @store,
            @d_qty - @d_acntqty, @d_total - @d_acnttl,
          --(@d_qty - @d_acntqty) * @g_inprc, (@d_qty - @d_acntqty) * @g_rtlprc,
          @d_cost - @d_invadj, (@d_qty - @d_acntqty) * @g_rtlprc,  --2002-10-11
            0, 0, 0, 0)
          else
          insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, ASTORE,
            PY_Q, PY_A, PY_I, PY_R,
            PK_Q, PK_A, PK_I, PK_R
            ) values (
            @cur_date, @cur_settleno, @d_wrh_saved, @d_gdgid, @store,
            @d_qty - @d_acntqty, @d_total - @d_acnttl,
          (@d_qty - @d_acntqty) * @g_inprc, (@d_qty - @d_acntqty) * @g_rtlprc,
            0, 0, 0, 0)
        end else begin
          if @sale = 1/*2003-06-13*/
          insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, ASTORE,
            PY_Q, PY_A, PY_I, PY_R,
            PK_Q, PK_A, PK_I, PK_R
            ) values (
            @cur_date, @cur_settleno, @d_wrh_saved, @d_gdgid, @store,
            0, 0, 0, 0,
            @d_acntqty - @d_qty,
            @d_acnttl - @d_total,
          --(@d_acntqty - @d_qty) * @g_inprc,
          -(@d_cost - @d_invadj),  --2002-10-11
            (@d_acntqty - @d_qty) * @g_rtlprc )
          else
          insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, ASTORE,
            PY_Q, PY_A, PY_I, PY_R,
            PK_Q, PK_A, PK_I, PK_R
            ) values (
            @cur_date, @cur_settleno, @d_wrh_saved, @d_gdgid, @store,
            0, 0, 0, 0,
            @d_acntqty - @d_qty,
            @d_acnttl - @d_total,
          (@d_acntqty - @d_qty) * @g_inprc,
            (@d_acntqty - @d_qty) * @g_rtlprc )
        end
      end
    end /* of 不是大包装商品 */
    else
    begin
      select @i_qty = 0, @i_total = 0
    end
    insert into CKDTL (NUM, LINE, SETTLENO, GDGID, WRH,
      ACNTQTY, QTY, ACNTTL, TOTAL,
      OVFAMT, LOSAMT, INPRC, RTLPRC,
      ACNTQTY2, ACNTTL2, INPRC2, RTLPRC2,subwrh,
      COST  --2002-10-11
      ) values (
      @p_num, @d_line, @cur_settleno, @d_gdgid, @d_wrh_saved,
      @d_acntqty, @d_qty, @d_acnttl, @d_total,
      @d_ovfamt, @d_losamt, @d_inprc, @d_rtlprc,
      @i_qty, @i_total, @g_inprc, @g_rtlprc ,@d_subwrh,
      isnull(@d_cost, 0))  --2002-10-11
    delete from PCKS where LINE = @p_line
    update PCKDTL set
      CKNUM = @p_num,
      CKLINE = @d_line,
      STAT = 1
      where CKNUM IS NULL and CKLINE = @p_line
    update CK set
      OVFAMT = OVFAMT + @d_ovfamt,
      LOSAMT = LOSAMT + @d_losamt
      where NUM = @p_num
    if @d_subwrh = 0
    delete from CKINV
    where GDGID = @d_gdgid and WRH = @d_wrh_saved
    else
    delete  from ckswi
    where gdgid =@d_gdgid and wrh =@d_wrh_saved and subwrh =@d_subwrh

  end
end
GO
