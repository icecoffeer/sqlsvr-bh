SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CSTMIZEDLTNUM]
  @num char(10),
  @mode int, --1=已审核单据冲单 2=已批准单据冲单
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output
with encryption as
begin
  declare
    @ret_status int,           @cur_date datetime,        @cur_settleno int,
    @wrh int,                  @wrh2 int,                 @prepay money,  
    @billto int,               @slr int,                  @vdr int,
    @gdgid int,                @gqty money,               @qty money,                
    @price money,              @gtotal money,             @total money,
    @tax money,                @subwrh int,               @stat int,
    @g_inprc money,            @g_rtlprc money,           @tmp_qty money,
    @line smallint,            @inprc money,              @rtlprc money,
    @src int,                  @storegid int,             @cfmbyself int


  select
    @ret_status = 0,
    @cur_date = convert(datetime, convert(char,getdate(),102))
  select
    @cur_settleno = max(NO) from MONTHSETTLE
  select
    @storegid = usergid, @cfmbyself = cfmbyself from system

  select
    @stat = STAT,
    @billto = BILLTO,
    @vdr = VENDOR,
    @prepay = PREPAY,
    @wrh = WRH,
    @slr = SlR,
    @src = SRC
    from CSTMIZE where NUM = @num

  if @stat <> 1 and @stat <> 11 begin
    raiserror('删除的不是已审核或已批准的单据.', 16, 1)
    return(1)
  end

  update CSTMIZE set STAT = 2 where NUM = @num

  insert into CSTMIZE (NUM, SETTLENO, VENDOR, CLIENT, BILLTO, RECEIVER,
    WRH, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, GATHDATE,
    FILLER, CHECKER, CONFIRMER, CASHIER, SLR, STAT, MODNUM, RECCNT, SRC)
    select @neg_num, @cur_settleno, VENDOR, CLIENT, BILLTO, RECEIVER,
    WRH, -TOTAL, -TAX, -GTOTAL, -PREPAY, NULL, getdate(),getdate(), NULL, NULL,
    @new_oper, @new_oper, 1, 1, slr, 4, @num, RECCNT, SRC
    from CSTMIZE where NUM = @num
  if @mode = 2
    update CSTMIZE set CFMDATE = getdate(), CONFIRMER = @new_oper where NUM = @neg_num

  insert into CSTMIZEDTL (SETTLENO, NUM, LINE, GDGID, GQTY, QTY, 
    PRICE, GTOTAL, TOTAL, TAX, WRH, INPRC, RTLPRC, SUBWRH)
    select @cur_settleno, @neg_num, LINE, GDGID, -GQTY, -QTY,
    PRICE, -GTOTAL, -TOTAL, -TAX, WRH, INPRC, RTLPRC, SUBWRH
    from CSTMIZEDTL
    where NUM = @num

  if not (@src <> @Storegid  and @cfmbyself = 1 and @stat = 11)
  begin 
  insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
                  SK_Q, SK_A, SK_I, SK_R)
     values (@cur_date, @cur_settleno, @billto, 1, @wrh,
             0, -@prepay, 0, 0)

  if @@error <> 0 
  begin
       select @ret_status = 401
       return(@ret_status)       
  end

  if @mode = 2
  begin
      declare c_csmdlt cursor for
        select LINE, GDGID, GQTY, QTY, PRICE, GTOTAL, TOTAL, TAX, WRH, INPRC, RTLPRC, SUBWRH
        from CSTMIZEDTL where NUM = @num
      open c_csmdlt
      fetch next from c_csmdlt into
           @line, @gdgid, @gqty, @qty, @price, @gtotal, @total, @tax,
           @wrh2, @inprc, @rtlprc, @subwrh
      while @@fetch_status = 0 begin
          select
            @g_rtlprc = RTLPRC,
            @g_inprc = INPRC
            from GOODS where GID = @gdgid

          /* update inventory */
          select @tmp_qty = -@qty
          execute @ret_status = UNLOAD @wrh2, @gdgid, @tmp_qty, @g_rtlprc, null
          if  @ret_status <> 0 break

          if @subwrh is not null
          begin
             execute @ret_status = UNLOADSUBWRH @wrh2, @subwrh, @gdgid, @tmp_qty
             if @ret_status <> 0 break
          end

          /* reports */
          insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
                          WC_Q, WC_A, WC_T, WC_I, WC_R)
              values (@cur_date, @cur_settleno, @wrh2, @gdgid, @billto, @slr, @vdr,
                      -@qty, -(@total-@tax), -@tax, -@qty * @inprc, -@qty * @rtlprc)
          if @@error <> 0 
          begin
              select @ret_status = 402
              return(@ret_status)
          end  

          /* 生成调价差异, 库存已经按照当前售价退库了 */
          if @inprc <> @g_inprc or @rtlprc <> @g_rtlprc
          begin
             insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                values (@cur_settleno, @cur_date, @gdgid, @wrh2,
                       (@g_inprc-@inprc) * @qty, (@g_rtlprc-@rtlprc) * @qty)
          end

          fetch next from c_csmdlt into
             @line, @gdgid, @gqty, @qty, @price, @gtotal, @total, @tax,
             @wrh2, @inprc, @rtlprc, @subwrh
      end
      close c_csmdlt
      deallocate c_csmdlt
  end
  end
  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @ret_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@ret_status)
  end

  return(@ret_status)
end
GO
