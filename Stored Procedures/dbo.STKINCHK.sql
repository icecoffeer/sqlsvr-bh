SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINCHK](
  @cls char(10),
  @num char(10),
  @mode smallint,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,       @cur_date datetime,    @cur_settleno int,
    @wrh int,                 @billto int,           @vdrgid int,
    @psr int,                 @stat smallint,        @gdgid int,
    @qty money,               @loss money,           @price money,
    @total money,             @tax money,            @inprc money,
    @rtlprc money,            @validdate datetime,   @t_qty money,
    @ordnum char(10),         @msg varchar(200),     @acnt smallint,
    @line smallint,           @tmp_money money,      @subwrh int,
    @i_price money,           @modnum char(10),      @mod_qty money,
    @optvalue int, /*2002-09-10*/
	@GENBILL char(10),        @op_usezbinprc int  /*zengyun 2005-8-8*/
  declare @ordline int/*2003-08-27*/

  declare @opt_MAndDWrh int
  exec Optreadint 0, 'SynMasterAndDetailWrh', 0, @opt_MAndDWrh output

  select
    @return_status = 0
  select
    @stat = STAT,
    @cur_date = convert(datetime, convert(char, getdate(), 102)),
    @vdrgid = VENDOR,
    @billto = BILLTO,
    @psr = PSR,
    @ordnum = ORDNUM,
    @modnum = MODNUM,
	@GENBILL = GENBILL, /*zengyun 2005-8-8*/
	  @wrh = wrh  --ShenMin
    from STKIN where CLS = @cls and NUM = @num
  if @mode = 0 or @mode = 2 begin
    /* 99-12-29 */
    if @stat not in (0,7)  begin
      select @errmsg = '审核的不是未审核的单据.'
      raiserror(@errmsg, 16, 1)
      return (1003)
    end
  end

  /*zengyun 2005-8-8*/
  if @GENBILL is null select @GENBILL = ''  /*zengyun 2005-8-8*/
  if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost1' and OPTIONVALUE = '1')
    select @op_usezbinprc = 1
  else
    select @op_usezbinprc = 0

  if @mode = 1 begin
    if @stat <> 1  begin
      select @errmsg = '复核的不是已审核的单据.'
      raiserror(@errmsg, 16, 1)
      return (1004)
    end
  end


 --ShenMin
  declare
    @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  select @wrh = wrh from stkin(nolock) where cls = @cls and num = @num
  exec @return_status = WMSFILTER 'STKIN', @piCls = @cls, @piNum = @num, @piToStat = 1, @piOper = @Oper,@piWrh =@wrh,  @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return -1
    end

  select @cur_settleno = MAX(NO) from MONTHSETTLE
  if @mode = 0
    update STKIN set STAT = 1 , SETTLENO = @cur_settleno, FILDATE = GETDATE()
    where CLS = @cls and NUM = @num
  else if @mode = 1
    update STKIN set STAT = 6 , SETTLENO = @cur_settleno, CHKDATE = GETDATE()
    where CLS = @cls and NUM = @num
  else
    update STKIN set STAT = 6 , SETTLENO = @cur_settleno, FILDATE = GETDATE(),
    CHKDATE = GETDATE()
    where CLS = @cls and NUM = @num

  /* 启用限制单据的汇总仓位和明细仓位一致 */
  if @cls = '自营' and @opt_MAndDWrh = 1
  begin
    update STKINDTL set wrh = @wrh, note = ltrim(rtrim(note)) + ' 原仓位(' + ltrim(rtrim(str(wrh))) + ')'
    where CLS = @cls and NUM = @num and wrh <> @wrh
  end

  /* deal with the details */
  declare c_stkin cursor for
    select LINE, WRH,GDGID, QTY, PRICE, TOTAL, TAX, LOSS,
           INPRC, RTLPRC, VALIDDATE, SUBWRH, ORDLINE/*2003-08-27*/
    from STKINDTL where CLS = @cls and NUM = @num
  open c_stkin
  fetch next from c_stkin into @line,
    @wrh, @gdgid, @qty, @price, @total, @tax, @loss,
    @inprc, @rtlprc, @validdate, @subwrh, @ordline/*2003-08-27*/
  while @@fetch_status = 0 begin
    if @mode in (0, 2)
    begin
      /* update goods */

      /* 2000-11-06: 2000110659194 */
      if @cls <> '调入' and @price > 0
      begin
        /*2005-8-19 有差异再更新goods，尽量避免零售单使用IC卡时死锁*/
        if (select INPRCTAX from SYSTEM) = 1
          update GOODS set LSTINPRC = @price where GID = @gdgid and LSTINPRC <> @price
        else
          update GOODS set LSTINPRC = @price/(1.0+TAXRATE/100.0) where GID = @gdgid and LSTINPRC <> @price/(1.0+TAXRATE/100.0)
      end

      if ( select BILLTO from GOODS where GID = @gdgid ) = 1 begin
        /*2005-8-19 有差异再更新goods，尽量避免零售单使用IC卡时死锁*/
        update GOODS set BILLTO = @billto where GID = @gdgid and BILLTO <> @billto
      end
      /*2005-8-13*/
      if @GENBILL <> 'RTL' or (@GENBILL = 'RTL' and @op_usezbinprc = 0)
      begin
        select @tmp_money = @qty + @loss
        execute UPDINVPRC '进货', @gdgid, @tmp_money, @total, @wrh /*2002.08.18*/
      end
    end

    /* 如果审核到复核这段时间发生了调价，会造成单据与进货日报金额不等 */
    /* 所以条件从@mode = 1 or @mode = 2改成@mode = 0 or @mode = 2 */
    /* 1999-4-1, caili */
    if @mode = 0 or @mode = 2 begin
      /* set INPRC, RTLPRC to current values */
      select @inprc = INPRC, @rtlprc = RTLPRC from GOODSH where GID = @gdgid
      if @GENBILL = 'RTL' and @op_usezbinprc = 1  /*zengyun 2005-8-11 任务单4712*/
        select @inprc = @price
      update STKINDTL set INPRC = @inprc, RTLPRC = @rtlprc
        where CLS = @cls and NUM = @num and LINE = @line
    end

    if @mode = 0 or @mode = 2 begin
      /* update inventory */
      select @t_qty = @qty + @loss
      execute @return_status = LOADIN @wrh, @gdgid, @t_qty, @rtlprc, @validdate
      if @return_status <> 0 break
      /* 2000-3-15 增加了system.batchflag=1时的处理,
      ref 用货位实现批次管理(二).doc */
      if (select batchflag from system) = 1
      begin
      	/*
      	货位空
      	  数量>=0: 生成货位
      	  数量<0:错误
      	货位不空
      	  数量>=0: 插入货位到货位表中
      	  数量<0: 必须存在对应的正单
      	*/
        if @subwrh is null
        begin
          if @t_qty >= 0
          begin
            execute @return_status = GetSubWrhBatch @wrh, @subwrh output, @errmsg output
            if @return_status <> 0 break
            update STKINDTL set SUBWRH = @subwrh
              where CLS = @cls and NUM = @num and LINE = @line
          end
          else /* @t_qty < 0 */
          begin
            select @errmsg = '负数进货必须指定货位'
            select @return_status = 1005
            break
          end
        end
        else /* @subwrh is not null */
        begin
          if @t_qty < 0
          begin
            select @mod_qty = null
            select @mod_qty = qty + loss from stkindtl
              where cls = @cls and num = @modnum and subwrh = @subwrh
            if @mod_qty is null
            begin
              select @errmsg = '找不到对应的进单'
              select @return_status = 1006
              raiserror(@errmsg, 16, 1)
              break
            end
            if @mod_qty <> @t_qty
            begin
              select @errmsg = '数量和对应的进单('+@modnum+')上的不符合'
              select @return_status = 1007
              raiserror(@errmsg, 16, 1)
              break
            end
          end
          /* 2000-12-14: 2000121356773 */
          else begin
            execute InsSubWrhBatch @wrh, @subwrh
          end
        end
      end

      if @subwrh is not null
      begin
        /* 2000-1-7 李希明：货位中的参考进价
           2000-2-28 李希明：根据系统标志做去税处理 */
        if (select INPRCTAX from SYSTEM) = 1
          select @i_price = @price
        else
          select @i_price = @price/(1.0+TAXRATE/100.0) from GOODS where GID = @gdgid
        execute @return_status = LOADINSUBWRH @wrh, @subwrh, @gdgid, @t_qty, @i_price
        if @return_status <> 0 break
      end
    end
    if @mode = 0 or @mode = 2 begin
      /* VDRGD */
      if not exists (
        select * from VDRGD
        where VDRGID = @billto and GDGID = @gdgid and WRH = @wrh
      ) begin
        if (select RSTWRH from SYSTEM) <> 1 /* 99-12-6: =0 -> <>1 */
        begin
          insert into VDRGD(VDRGID, GDGID, WRH) values (@billto, @gdgid, @wrh)
        end
        else begin
          select @return_status = 1008
          select @errmsg =
            (select rtrim(NAME)+'['+rtrim(CODE)+']'
             from VENDOR where GID = @billto) +
            '在' +
            (select rtrim(NAME)+'['+rtrim(CODE)+']'
             from WAREHOUSE where GID = @wrh) +
            '不供应' +
            (select rtrim(NAME)+'['+rtrim(CODE)+']'
             from GOODS where GID = @gdgid)
          raiserror(@errmsg, 16, 1)
          break
        end
      end
    end
    if @mode = 0 or @mode = 2 begin
       /* ORDER */
      if @ordnum is not null
        update ORDDTL set ARVQTY = ARVQTY + @qty
        where ORDDTL.NUM = @ordnum and ORDDTL.GDGID = @gdgid and LINE = @ordline /*2003-08-27*/

    end
    /* reports */
    execute @return_status = STKINDTLCRT
      @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @cls, @wrh, @gdgid, @billto, @psr,
      @qty, @price, @total, @tax, @loss, @inprc, @rtlprc, @mode
    if @return_status <> 0 break

    fetch next from c_stkin into @line,
      @wrh,@gdgid,@qty,@price, @total, @tax, @loss,
      @inprc, @rtlprc, @validdate, @subwrh, @ordline/*2003-08-27*/
  end
  close c_stkin
  deallocate c_stkin

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror(@errmsg, 16, 1)
    return (@return_status)
  end

  /* 设置ORD.FINISHED */
  if @mode in(0, 2)
  begin
    --2006.12.06 added by zhanglong,  在单量管理改造
    execute @return_status = DECORDQTY 'STKIN', @cls, @num
    if @return_status <> 0 return(@return_status)
  end

  if (@mode = 0 or @mode = 2) and @ordnum is not null
  begin
    /*2002-09-10*/
    select @optvalue = 0
    if @cls = '自营'
  	  exec OPTREADINT 52, 'WriteBackToOrd', 0, @optvalue output
    if @cls = '调入'
  	  exec OPTREADINT 73, 'WriteBackToOrd', 0, @optvalue output
    if @optvalue = 1
      or not exists (select * from ORDDTL where NUM = @ordnum and QTY > ARVQTY + ASNQTY)
    begin
      update ORD set FINISHED = 1 where NUM = @ordnum and FINISHED = 0
      /* Q5965 jinlei 扣除定单上剩余的在单量 */
      exec @return_status = ChgOrdQty @CLS, @ordnum
    end
  end
  return(@return_status)
end
GO
