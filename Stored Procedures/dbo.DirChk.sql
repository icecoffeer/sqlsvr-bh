SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirChk]
  @cls char(10),
  @num char(10),
  @mode smallint,  /* 0=审核,1=复核,2=审核+复核 */
  @isneg int, /* 是否冲单.0=否,1=是
                如果是, 则不用当前值更新单据的INPRC和RTLPRC,
                        不生成提单;
                否则, 应该用当前值更新单据的INPRC和RTLPRC,
                      并根据其他条件决定是否生成提单 */
  @errmsg varchar(200) = '' output
as
begin
  declare
    @m_settleno int,      @m_vendor int,   @m_sender int,     @m_receiver int,
    @m_ocrdate datetime,  @m_psr int,      @m_total money,    @m_tax money,
    @m_alctotal money,    @m_stat smallint,@m_src int,        @m_srcnum char(10),
    @m_sndtime datetime,  @m_note varchar(100),               @m_reccnt int,
    @m_filler int,        @m_checker int,  @m_modnum char(10),@m_vendornum char(10),
    @m_fildate datetime,  @m_finished smallint,               @m_prntime datetime,
    @m_wrh int,           @m_fromnum char(14),                @m_fromcls varchar(20), --XXXX

    @d_line smallint,     @d_settleno int, @d_gdgid int,      @d_wrh int,
    @d_cases money,       @d_qty money,    @d_loss money,     @d_price money,
    @d_total money,       @d_tax money,    @d_alcprc money,   @d_alcamt money,
    @d_wsprc money,       @d_inprc money,  @d_rtlprc money,   @d_validdate datetime,
    @d_bckqty money,      @d_payqty money, @d_bckamt money,   @d_bnum char(10),
    @cur_settleno int,    @cur_date datetime,                 @return_status int,
    @msg varchar(100),    @money1 money,   @g_taxrate money,  @g_inprc money,
    @g_rtlprc money,      @g_wsprc money,  @d_subwrh int,
    @gendsp int,          @dsp_num char(10),    @max_dsp_num char(10),
    @mod_qty money,       @modnum char(10), @i_price money,   @store int,
    @m_ordnum char(10),
    @dd_qty money,         @dd_alcamt money,        @m_paymode char(10),/*2002-01-17*/
    @isbianli bit/*2002-02-05*/
  declare
    @d_outcost money,     @money2 money,/*2002-06-13*/        @optvalue int/*2002-04-19*/,
    @sale smallint/*2003-06-13*/
  declare @ordline int/*2003-08-27*/
  declare @BCKDMDNUM char(14),    @outmsg varchar(255), @bckdmdstat int
  declare @GENBILL char(10),      @GENNUM char(10),     @op_usezbalcprc int  /*2005-8-13*/
  declare @OptBckDmdRepImp int, @BckdmdQty money, @BckedQty money, @BckQty money, @BckLine int, @OverDmdQtyCount int; --ShenMin

  declare @DirOutWriteZBRpt int, @AllBalanceInOut int, @KeepSamePrc int, @ModuleNo int
  exec optreadint 0, '直配出业务写总部进出报表', 0, @DirOutWriteZBRpt output
  exec optreadint 0, '开启全局进出货成本平进平出', 0, @AllBalanceInOut output
  exec optreadint 0, 'BckDmdRepImp', 0, @OptBckDmdRepImp output; --ShenMin

  if @cls = '直配进'
    set @ModuleNo = 84
  if @cls = '直配进退'
    set @ModuleNo = 88
  if @cls = '直配出'
    set @ModuleNo = 164
  if @cls = '直配出退'
    set @ModuleNo = 174

  Set @KeepSamePrc = 0
  select @KeepSamePrc = substring(optionvalue,17,1)
    from hdoption where moduleno = @ModuleNo and optioncaption like 'ChkOption'
  if @KeepSamePrc is null
    set @KeepSamePrc = 0
  if @AllBalanceInOut = 1
    set @KeepSamePrc = 1
  if @AllBalanceInOut = 2
    set @KeepSamePrc = 0

  if @KeepSamePrc = 0
    set @DirOutWriteZBRpt = 0

  select
    @cur_settleno = (select max(NO) from MONTHSETTLE),
    @cur_date = convert(datetime, convert(char(10), getdate(), 102))
  select
    @store = USERGID from SYSTEM
  select
    @m_settleno = SETTLENO,       @m_vendor = VENDOR,
    @m_sender = SENDER,           @m_receiver = RECEIVER,
    @m_ocrdate = OCRDATE,         @m_psr = PSR,
    @m_total = TOTAL,             @m_tax = TAX,
    @m_alctotal = ALCTOTAL,       @m_stat = STAT,
    @m_src = SRC,                 @m_srcnum = SRCNUM,
    @m_sndtime = SNDTIME,         @m_note = NOTE,
    @m_reccnt = RECCNT,           @m_filler = FILLER,
    @m_checker = CHECKER,         @m_modnum = MODNUM,
    @m_vendornum = VENDORNUM,     @m_fildate = FILDATE,
    @m_finished = FINISHED,       @m_prntime = PRNTIME,
    @m_wrh = WRH,                 @m_ordnum = ORDNUM,
    @m_paymode = PAYMODE,/*2002-01-17*/
    @m_fromnum = fromnum,         @m_fromcls = fromcls, --XXXX
    @GENBILL = GENBILL,           @GENNUM = GENNUM /*2005-8-13*/
  from DIRALC
  where CLS = @cls and NUM = @num

  if @cls = '直配进退' or @cls = '直配出退'
  begin
    if (SELECT BCKLMT FROM VENDOR(NOLOCK) WHERE GID = @m_vendor) = 1
    BEGIN
      raiserror('当前供应商被限制退货。', 16, 1)
      return 1
    END
  end

  /*2005-8-13*/
  if @GENBILL is null select @GENBILL = ''
  if @GENNUM is null select @GENNUM = ''
  if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost1' and OPTIONVALUE = '1')
    select @op_usezbalcprc = 1
  else
    select @op_usezbalcprc = 0

  /*2002-02-05*/
  select @isbianli = 0
  if exists (select 1 from warehouse(nolock) where gid = @m_receiver)
	select @isbianli = 1

  --取得当前用户
  declare @fillerxcode varchar(20),
          @fillerx int,
          @fillerxname varchar(50)
  set @fillerxcode = rtrim(substring(suser_sname(), charindex('_', suser_sname()) + 1, 20))
  select @fillerx = gid, @fillerxname = name
    from employee(nolock) where code like @fillerxcode
  if @fillerxname is null
  begin
    set @fillerxcode = '-'
    set @fillerxname = '未知'
  end
  set @fillerxcode = convert(varchar(30),'['+rtrim(isnull(@fillerxcode,''))+']' +
    rtrim(isnull(@fillerxname,'')))
  --
  set @return_status = 0
  if @cls = '直配进退' or @cls = '直配出退'
  begin
    select @bckdmdnum = num from vdrbckdmd (nolock)
      where locknum = @num and lockcls = @cls and stat = 500
    --Receive-Check(StoreBill) Should Found and Write back (VDRBCKDMD.LOCKNUM)
    if @bckdmdnum is not null and rtrim(@bckdmdnum) <> ''
    begin
      select @bckdmdstat = stat from vdrbckdmd(nolock) where num = @bckdmdnum
      if (@bckdmdstat <> 500)
        and ((select optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'ChkWithBckDmd')) = '1')
      begin
          raiserror('来源退货申请单非审核不能继续审核。', 16, 1)
    	    return 1
      end
    	if exists(select 1 from diralcdtl where num = @num and cls= @cls
    	  group by gdgid having count(1)>1)
    	begin
    	  raiserror('单据中有重复商品，不能回写退货申请单', 16, 1)
    	  return 1
    	end
    	if @OptBckDmdRepImp = 0  --ShenMin
    	  begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
          	select @bckdmdnum = fromnum
          	    from diralc where num = @num and cls = @cls --and fromcls = '供应商退货申请单'
          	update vdrbckdmd set
          	    locknum = @num, lockcls = @cls where num = @bckdmdnum
          end
          exec @return_status = vdrbckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
          if @return_status = 0
          begin
            update vdrbckdmddtl set bckedqty = bck.qty
    	      from diralcdtl bck(nolock)
    	      where bck.num = @num and bck.cls = @cls
    	        and vdrbckdmddtl.num = @bckdmdnum
    	        and bck.gdgid = vdrbckdmddtl.gdgid
    	    end
          if @return_status<>0
          begin
            raiserror('回写退货申请单[%s]失败:%s.', 16, 1, @bckdmdnum, @outmsg)
            return (1)
          end
    	  end;
    else if @OptBckDmdRepImp = 1
    	begin
        if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
        begin
        	select @bckdmdnum = fromnum
        	    from diralc where num = @num and cls = @cls;
        end;
      	set @BckdmdQty = 0;
      	set @BckedQty = 0;
        set @BckLine = 0;
        set @BckQty = 0;
        select @BckdmdQty = dmd.Qty, @BckedQty = dmd.BckedQty, @BckLine = bck.Line, @BckQty = bck.qty
        from vdrbckdmddtl dmd(nolock), diralcdtl bck(nolock)
        where bck.num = @num and bck.cls = @cls
          and dmd.gdgid = bck.gdgid
          and dmd.num = @bckdmdnum
          and bck.qty + dmd.bckedqty > dmd.qty;

        if @BckLine <> 0
          begin
            if @BckdmdQty < @BckedQty + @BckQty
              begin
                set @outmsg = '单据中第' + CAST(@BckLine AS varchar(8)) + '行的退货数量'
                            + CAST(@BckQty AS varchar(8)) + ' 超过了来源供应商退货申请单中的可退数量'
                            + CAST(@BckdmdQty - @BckedQty  AS varchar(8)) + '，不允许审核！';
                raiserror('回写退货申请单[%s]失败:%s', 16, 1, @bckdmdnum, @outmsg);
                return(2);
              end;
          end;
         update vdrbckdmddtl set bckedqty = bckedqty + bck.qty
    	  	from diralcdtl bck(nolock)
    	  	where bck.num = @num and bck.cls = @cls
    	  	  and vdrbckdmddtl.num = @bckdmdnum
    	  	  and bck.gdgid = vdrbckdmddtl.gdgid
         update vdrbckdmd
         set locknum = null, lockcls = null where num = @bckdmdnum
         select @OverDmdQtyCount = 0
         select @OverDmdQtyCount = count(1) from vdrbckdmddtl(nolock)
         where num = @bckdmdnum and bckedqty < qty
         if @OverDmdQtyCount = 0
           exec @return_status = vdrbckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
         if @return_status<>0
           begin
             raiserror( '回写退货申请单[%s]失败:%s', 16, 1, @bckdmdnum, @outmsg);
             return(2);
           end
    	end;
    end
  end

  ------------
  if @mode = 0 or @mode = 2
  begin
    if @m_stat <> 0 and @m_stat <> 7
    begin
      raiserror('审核的不是未审核或已预审的单据.', 16, 1)
      return (1)
    end
  end
  if @mode = 1
  begin
    if @m_stat <> 1
    begin
      raiserror('复核的不是已审核的单据.', 16, 1)
      return (1)
    end
  end
  if @mode = 0
    update DIRALC set STAT = 1 , SETTLENO = @cur_settleno, FILDATE = GETDATE()
    where CLS = @cls and NUM = @num
  else if @mode = 1
    update DIRALC set STAT = 6 , SETTLENO = @cur_settleno, CHKDATE = GETDATE()
    where CLS = @cls and NUM = @num
  else
    update DIRALC set STAT = 6 , SETTLENO = @cur_settleno, FILDATE = getdate(),
    CHKDATE = GETDATE()
    where CLS = @cls and NUM = @num

  /* 2002-05-15 2002-10-25 2002-10-28*/
  if @mode = 0 and @m_src = (select USERGID from SYSTEM)
  begin
  	exec OPTREADINT 0, 'AutoOcrDate', 0, @optvalue output
  	if @optvalue = 1
  	begin
  	  select @m_ocrdate = getdate()
  	  update DIRALC set OCRDATE = @m_ocrdate
  	  where CLS = @cls and NUM = @num
  	end
  end

  /* 2000-2-28: 生成提单头 */
  select @gendsp = 0
  if @isneg = 0 and @mode in (0,2) and
  (@cls = '直配进退') and (select DSP from SYSTEM) & 128 <> 0
    select @gendsp = 1
  if @gendsp = 1
  begin
    /* 要求DIRALC.WRH=DIRALCDTL.WRH */
    if (@m_wrh is null)
    or (exists (select * from diralcdtl where cls = @cls and num = @num and
      ((wrh <> @m_wrh) or (wrh is null))))
    begin
      raiserror('单据头和明细的仓位必须一致.', 16, 1)
      return(1)
    end
    select @dsp_num = null
    select @max_dsp_num = max(num) from dsp
    if @max_dsp_num is null select @dsp_num = '0000000001'
    else execute nextbn @max_dsp_num, @dsp_num output
    insert into DSP (
      NUM, WRH, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER, OPENER,
      LSTDSPTIME, LSTDSPEMP, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO, /* 2000-05-13 */SRC)
    values (
      @dsp_num, @m_wrh, @num, getdate(), @m_total, @m_reccnt, @m_filler, @m_psr,
      null, null, 'DIRALC', @cls, @num, null, @cur_settleno, @store)
  end

  /* 处理明细 */
----------------------------------------------------------------------------------------------------
  declare c_diralc cursor for
    select
      LINE, GDGID, WRH, QTY, LOSS, PRICE, TOTAL, TAX,
      ALCPRC, ALCAMT, VALIDDATE, INPRC, RTLPRC, SUBWRH, ORDLINE/*2003-08-27*/
    from DIRALCDTL where CLS = @cls and NUM = @num
    for update
  open c_diralc
  fetch next from c_diralc into
    @d_line, @d_gdgid, @d_wrh, @d_qty, @d_loss, @d_price, @d_total, @d_tax,
    @d_alcprc, @d_alcamt, @d_validdate, @d_inprc, @d_rtlprc, @d_subwrh, @ordline/*2003-08-27*/
  while @@fetch_status = 0
  begin
    select @g_inprc = INPRC, @g_rtlprc = RTLPRC,
           @g_wsprc = WHSPRC, @g_taxrate = TAXRATE, @sale = SALE
    from GOODSH where GID = @d_gdgid

    /*00-3-3*/
    if (select OUTinprcmode from system) = 1
      select @g_inprc = lstinprc from subwrhinv
      where subwrh = @d_subwrh and gdgid = @d_gdgid

    /* 2000-5-30 */
    if @mode = 0 or @mode = 2
    begin
      if @isneg = 0
      begin
        /* set INPRC, RTLPRC, WHSPRC to current values */
        select @d_inprc = @g_inprc, @d_rtlprc = @g_rtlprc, @d_wsprc = @g_wsprc
        update DIRALCDTL
        set INPRC = @d_inprc, RTLPRC = @d_rtlprc, WSPRC = @d_wsprc
        where CLS = @cls and NUM = @num and LINE = @d_line
      end
    END

    if @mode in (0, 2)
    begin
      /* update goods */

      /* 2000-11-06: 2000110659194 */
      if @cls = '直配进' or @cls = '直配出'
      begin
          -- Added By zhourong 2006-03-31 9:50:40 ----------------------------------------------
          -- Q6409
          -- 对于直配进货单和直配出货单，如果明细中的商品不存在，则给出提示，终止审核过程
          IF NOT EXISTS (SELECT 1 FROM Goods WHERE GID = @d_gdgid)
          BEGIN
            DECLARE @d_name VARCHAR(50)
            SELECT @d_name = [Name] FROM GoodsH WHERE Gid = @d_gdgid
            RAISERROR('明细商品 %s[%s] 不存在，审核过程被终止。', 16, 1, @d_name, @d_gdgid)
            RETURN 1
          END
          -- End Of Q6409 -----------------------------------------------------------------------------
        if @d_price > 0  and /*2001-05-11:2001050858094*/ @d_qty >0
        begin
          /*2005-8-19 有差异再更新goods，尽量避免零售单使用IC卡时死锁*/
          if (select INPRCTAX from SYSTEM) = 1
            update GOODS set LSTINPRC = @d_price where GID = @d_gdgid and LSTINPRC <> @d_price
          else
            update GOODS set LSTINPRC = @d_price/(1.0+TAXRATE/100.0) where GID = @d_gdgid and LSTINPRC <> @d_price/(1.0+TAXRATE/100.0)
        end
      end

      if ( select BILLTO from GOODS where GID = @d_gdgid ) = 1
        /*2005-8-19 有差异再更新goods，尽量避免零售单使用IC卡时死锁*/
        update GOODS set BILLTO = @m_vendor where GID = @d_gdgid and BILLTO <> @m_vendor
      /* 2000-7-31
      IF @cls = '直配进' execute UPDINVPRC '进货', @d_gdgid, @d_qty, @d_total
      2000-10-28 */
      --IF @cls = '直配进' execute UPDINVPRC '进货', @d_gdgid, @d_qty, @d_alcamt  2002-06-13
    end

    if @mode = 0 or @mode = 2
    begin
      /* VDRGD */
      if not exists (
        select * from VDRGD
        where VDRGID = @m_vendor and GDGID = @d_gdgid and WRH = @d_wrh
      )
      begin
        /* 1999.9.29: 增加对SINGLEVDR的判断 */
	/* 1999.10.21: 取消对SINGLEVDR的判断，见数据结构SYSTEM表注释 */
        if ((select RSTWRH from SYSTEM) <> 1) /* 99-12-6: =0 -> <>1 */
        begin
	/* or ((select SINGLEVDR from SYSTEM) = 1) begin */
          insert into VDRGD(VDRGID, GDGID, WRH) values (@m_vendor, @d_gdgid, @d_wrh)
        end
        else
        begin
          select @msg =
            (select rtrim(NAME)+'['+rtrim(CODE)+']'
             from VENDOR where GID = @m_vendor) +
            '在' +
            (select rtrim(NAME)+'['+rtrim(CODE)+']'
             from WAREHOUSE where GID = @d_wrh) +
            '不供应' +
            (select rtrim(NAME)+'['+rtrim(CODE)+']'
             from GOODS where GID = @d_gdgid)
          raiserror(@msg, 16, 1)
          return(1)
        end
      end
    end

    /* reports */
    if @cls = '直配进'
    begin
      /* 2000-05-17 回写定单 */
      if @mode in (0, 2)
      begin
        if @m_ordnum is not null
          update ORDDTL set ARVQTY = ARVQTY + @d_qty
          where ORDDTL.NUM = @m_ordnum and ORDDTL.GDGID = @d_gdgid  and LINE = @ordline /*2003-08-27*/
      end
      /*2005-8-13 回写门店零售单配货价*/
      if @GENBILL = 'RTL' and @GENNUM <> '' and @KeepSamePrc = 1
      begin
        select @d_alcprc = @d_price
        select @d_alcamt = convert(dec(20,2), @d_alcprc * @d_qty)
        update DIRALCDTL set ALCPRC = @d_alcprc, ALCAMT = @d_alcamt
          where CLS = @cls and NUM = @num and LINE = @d_line
        update RTLDTL set ALCPRC = @d_alcprc
          where NUM = @GENNUM and LINE = @d_line
      end
      /* 2000-06-09 只有mode in (0,2)时影响库存 */
      if @mode in (0, 2)
      begin
      	/* 库存操作 */
        if @GENBILL <> 'RTL' or (@GENBILL = 'RTL' and @op_usezbalcprc = 0) /*2005-8-13*/
          execute UPDINVPRC '进货', @d_gdgid, @d_qty, @d_alcamt, @d_wrh /*2002.08.18*/
      	if @sale = 1
      	    update DIRALCDTL set COST = @d_alcamt
      	        where CLS = @cls and NUM = @num and LINE = @d_line
      	else
      	    update DIRALCDTL set COST = @d_qty * @d_inprc --2004-08-12
      	        where CLS = @cls and NUM = @num and LINE = @d_line
      	  --where current of c_diralc
        select @money1 = @d_qty + @d_loss
        execute @return_status = LOADIN @d_wrh, @d_gdgid, @money1,
          @g_rtlprc, @d_validdate
        if @return_status <> 0 break

        /* 2000-4-3 增加了system.batchflag=1时的处理,
        ref 用货位实现批次管理(二).doc */
        if (select batchflag from system) = 1
        begin
          if @d_subwrh is null
          begin
            if @money1 >= 0
            begin
              execute @return_status = GetSubWrhBatch @d_wrh, @d_subwrh output, @errmsg output
              if @return_status <> 0 break
              update DIRALCDTL set SUBWRH = @d_subwrh
                where CLS = @cls and NUM = @num and LINE = @d_line
            end
            else /* @money1 < 0 */
            begin
              select @errmsg = '负数进货必须指定货位'
              select @return_status = 1005
              break
            end
          end
          else /* @d_subwrh is not null */
          begin
            if @money1 < 0
            begin
              select @mod_qty = null
              select @mod_qty = qty + loss from diralcdtl
                where cls = @cls and num = @modnum and subwrh = @d_subwrh
              if @mod_qty is null
              begin
                select @errmsg = '找不到对应的进单'
                select @return_status = 1006
                raiserror(@errmsg, 16, 1)
                break
              end
              if @mod_qty <> @money1
              begin
                select @errmsg = '数量和对应的进单('+@modnum+')上的不符合'
                select @return_status = 1007
                raiserror(@errmsg, 16, 1)
                break
              end
            end
          end
        end

        if @d_subwrh is not null
        begin
          /* 2000-4-3 货位中的参考进价 */
          if (select INPRCTAX from SYSTEM) = 1
            select @i_price = @d_alcprc
          else
            select @i_price = @d_alcprc/(1.0+TAXRATE/100.0) from GOODS where GID = @d_gdgid
          execute @return_status = LOADINSUBWRH @d_wrh, @d_subwrh, @d_gdgid, @money1, @i_price
          if @return_status <> 0 break
        end
      end /* 库存操作 */

      execute @return_status = STKINDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        '直配', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_alcprc, @d_alcamt, 0, @d_loss, @d_inprc, @d_rtlprc, @mode
      if @return_status <> 0 break
      /* 生成调价差异 */
      -- 2002-06-13 移动加权平均下不计算进价调价差异
      --if @d_inprc <> @g_inprc or @d_rtlprc <> @g_rtlprc
      --if @d_rtlprc <> @g_rtlprc
      /*2003-06-13 V2算法下，代销商品仍然应该计算进价的调价差异,这种现象只会发生在冲单和修正情况下*/
        if @d_inprc <> @g_inprc or @d_rtlprc <> @g_rtlprc
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @d_gdgid, @d_wrh,
        --(@g_inprc-@d_inprc) * @d_qty, (@g_rtlprc-@d_rtlprc) * @d_qty)
        case @sale when 1 then 0 else (@g_inprc-@d_inprc) * @d_qty end, (@g_rtlprc-@d_rtlprc) * @d_qty)
    end

    if @cls = '直配出'
    begin
      --2002-06-13
      update DIRALCDTL set COST = TOTAL
        where CLS = @cls and NUM = @num and LINE = @d_line
      if @d_price <> @d_alcprc
      begin
        if @DirOutWriteZBRpt = 1
        begin
          set @return_status = 1
          set @errmsg = '打开了选项“直配出业务写总部进出报表”，但['+@num+']中行['+convert(char,@d_line)
            +']不是平进平出的单据，配货价不同于发生单价，请确认上述选项。'
          close c_diralc
          deallocate c_diralc
          raiserror(@errmsg, 16, 1)
        end
      end
      if @DirOutWriteZBRpt = 0
      begin
      execute @return_status = STKINDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        '自营', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_price, @d_total, @d_tax, /* 2000-07-25 @d_loss*/ 0, @d_inprc, @d_rtlprc, @mode
      end
      if @return_status <> 0 break
      if @mode = 0 or @mode = 2
      begin
        select @money1 = @d_alcamt - @d_alcamt / (1.00 + @g_taxrate / 100.00)
	    /* 2002-06-04 */
        if (select sale from goods where gid = @d_gdgid) <> 1
		  select @i_price = @d_inprc
        else
          if (select INPRCTAX from SYSTEM) = 1
            select @i_price = @d_price
          else
            select @i_price = @d_price / (1.0 + @g_taxrate/100.0)
        if @DirOutWriteZBRpt = 0
        begin
          if @sale =1
          execute @return_status = STKOUTDTLCHKCRT
            '直配', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
            @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
            @money1, @i_price, @d_rtlprc, @m_vendor, @d_total, 1, 0 /*2005-05-31*/
          else
          execute @return_status = STKOUTDTLCHKCRT
            '直配', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
            @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
            @money1, @i_price, @d_rtlprc, @m_vendor, null, 1, 0 /*2005-05-31*/
          if @return_status <> 0 break
        end

/*2002-02-05 YSP:便利版并入标准版*/
	/* 回写定单 */
        if @mode in (0, 2)
        begin
          if @m_ordnum is not null
            update ORDDTL set ARVQTY = ARVQTY + @d_qty
	          where ORDDTL.NUM = @m_ordnum and ORDDTL.GDGID = @d_gdgid  and LINE = @ordline /*2003-08-27*/
	    end

        if @isbianli = 1
	    begin
		  select @money1 = @d_qty + @d_loss
		  execute @return_status = LOADIN @m_receiver, @d_gdgid, @money1, @g_rtlprc, @d_validdate
		  if @return_status <> 0 break

		  /* 调整库存快照的依据是KEPTDATE>OCRDATE而不是KEPTDATE<OCRDATE */
		  if exists(select * from ckinv where wrh = @m_receiver and KEPTDATE > @m_OCRDATE)
		  begin
            if not exists( select * from ckinv where wrh = @m_receiver and GDGID = @d_gdgid )
            begin
              insert into ckinv (WRH,GDGID,QTY,TOTAL,KEPTDATE,INPRC,RTLPRC)
 				values (@m_receiver, @d_gdgid, 0, 0, @m_ocrdate, @d_inprc, @d_rtlprc)
  			  insert into pcks (SETTLENO,GDGID,WRH,SUBWRH,ACNTQTY,QTY,
			    ACNTTL,TOTAL,OVFAMT,LOSAMT,INPRC,RTLPRC)
    			values (@m_settleno, @d_gdgid, @m_receiver,0,0,0,
				0,0,0,0,@d_inprc, @d_rtlprc)
            end
			update ckinv
			  set QTY = QTY + @money1,
			  TOTAL = case when QTY + @money1 >=0 then (QTY + @money1)*RTLPRC else 0 end
			  where WRH = @m_receiver and GDGID = @d_gdgid

            update PCKS
              set ACNTQTY = ACNTQTY + @money1,
			  ACNTTL = case when ACNTQTY + @money1 >=0 then (ACNTQTY + @money1)*RTLPRC else 0 end,
              OVFAMT = case when QTY - ACNTQTY - @money1 >= 0 then (QTY - ACNTQTY - @money1) * RTLPRC else 0 end,
			  LOSAMT = case when ACNTQTY + @money1 - QTY > 0 then (ACNTQTY + @money1 - QTY)  * RTLPRC else 0 end
              where wrh = @m_receiver and gdgid = @d_gdgid
		  end
	    end
/*2002-02-05 YSP:便利版并入标准版*/
      end
    end

    /* 2000-2-25 */
    if @cls = '直销'
    begin
      --2002-06-13
      update DIRALCDTL set COST = TOTAL
        where CLS = @cls and NUM = @num and LINE = @d_line
      if @DirOutWriteZBRpt = 0
      begin
      execute @return_status = STKINDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        '自营', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_price, @d_total, @d_tax, /* 2000-07-27 @d_loss*/0, @d_inprc, @d_rtlprc, @mode
      if @return_status <> 0 break
      end

      if @mode = 0 or @mode = 2
      begin
        select @money1 = @d_alcamt - @d_alcamt / (1.00 + @g_taxrate / 100.00)
		/* 2001-06-04 */
        if (select sale from goods where gid = @d_gdgid) <> 1
          select @i_price = @d_inprc
        else
          if (select INPRCTAX from SYSTEM) = 1
            select @i_price = @d_price
          else
            select @i_price = @d_price / (1.0 + @g_taxrate/100.0)
        if @sale = 1
        execute @return_status = STKOUTDTLCHKCRT
          '批发', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
          @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
          @money1, @i_price, @d_rtlprc, @m_vendor, @d_total, 1, 0 /*2005-05-31*/
        else
        execute @return_status = STKOUTDTLCHKCRT
          '批发', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
          @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
          @money1, @i_price, @d_rtlprc, @m_vendor, null, 1, 0 /*2005-05-31*/
        if @return_status <> 0 break
      end

      if (@mode in (0,2)) and (@m_paymode <> '应收款') begin  /*2002-01-17*/
        execute @return_status = RCPDTLCHK
          @cur_date, @cur_settleno, @m_receiver, @d_gdgid, @d_wrh, @d_qty,
          @d_alcamt, @d_inprc, @d_rtlprc
      end
      if @return_status <> 0 break
    end

    if @cls = '直配进退'
    begin
    	/* 2000-07-25 */
    	if @d_loss <> 0
    	begin
    		select @return_status = 1029,
    			@errmsg = '直配进货退货单上不能填写溢余数: 第' + ltrim(convert(char,@d_line))+'行'
    		break
    	end

      select @d_outcost = null --2002-06-13
      /* 2000-06-09 只有mode in (0,2)时影响库存 */
      if @mode in (0, 2)
      begin /* 库存操作 */
        /*2002-06-13*/
        if @isneg = 1
        begin
          select @money1 = -@d_qty, @money2 = -COST
            from DIRALCDTL where CLS = @cls and NUM = @num and LINE = @d_line
          execute UPDINVPRC '进货', @d_gdgid, @money1, @money2, @d_wrh /*2002.08.18*/
        end
        select @money1 = @d_qty + @d_loss
        execute @return_status = UNLOAD @d_wrh, @d_gdgid, @money1,
          @g_rtlprc, @d_validdate
        if @return_status <> 0 break
        if @d_subwrh is not null
        begin
          execute @return_status = UNLOADSUBWRH @d_wrh, @d_subwrh, @d_gdgid, @money1
          if @return_status <> 0 break
        end
        /*2002-06-13*/
        if @isneg = 0
        begin
          execute UPDINVPRC '进货退货', @d_gdgid, @d_qty, @d_alcamt, @d_wrh, @d_outcost output /*2002.08.18*/
          if @sale = 1
            update DIRALCDTL set COST = @d_outcost
                where CLS = @cls and NUM = @num and LINE = @d_line
          else --2004-08-12
            update DIRALCDTL set COST = @d_qty * @d_inprc
                where CLS = @cls and NUM = @num and LINE = @d_line
        end
      end /* 库存操作 */

      if @sale = 1
      execute @return_status = STKINBCKDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        '直配', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_alcprc, @d_alcamt, 0, @d_inprc, @d_rtlprc, @mode,
        @d_outcost --2002-06-13
      else
      execute @return_status = STKINBCKDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        '直配', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_alcprc, @d_alcamt, 0, @d_inprc, @d_rtlprc, @mode
      if @return_status <> 0 break

      /* 生成调价差异 */
      -- 2002-06-13 移动加权平均核算不计算进价调价差异
      --if @d_inprc <> @g_inprc or @d_rtlprc <> @g_rtlprc
      --if @d_rtlprc <> @g_rtlprc
    /*2003-06-13 V2算法下，代销商品仍然应该计算进价的调价差异,这种现象只会发生在冲单和修正情况下*/
        if @d_inprc <> @g_inprc or @d_rtlprc <> @g_rtlprc
        insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @d_gdgid, @d_wrh,
      --  -(@g_inprc-@d_inprc) * @d_qty, -(@g_rtlprc-@d_rtlprc) * @d_qty)
        case @sale when 1 then 0 else -(@g_inprc-@d_inprc) * @d_qty end, -(@g_rtlprc-@d_rtlprc) * @d_qty)
    end

    if @cls = '直配出退'
    begin
      --2002-06-13
      update DIRALCDTL set COST = TOTAL
        where CLS = @cls and NUM = @num and LINE = @d_line
      if @d_price <> @d_alcprc
      begin
        if @DirOutWriteZBRpt = 1
        begin
          set @return_status = 1
          set @errmsg = '打开了选项“直配出业务写总部进出报表”，但['+@num+']中行['+convert(char,@d_line)
            +']不是平进平出的单据，配货价不同于发生单价，请确认上述选项。'
          close c_diralc
          deallocate c_diralc
          raiserror(@errmsg, 16, 1)
        end
      end
      if @DirOutWriteZBRpt = 0
      begin
      execute @return_status = STKINBCKDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        /* 2000-2-25 '直配' */ '自营', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_price, @d_total, @d_tax, /*2002-04-18 @d_inprc*/@d_alcprc, @d_rtlprc, @mode
      if @return_status <> 0 break
      end
      if @mode = 0 or @mode = 2
      begin
        select @money1 = @d_alcamt - @d_alcamt / (1.00 + @g_taxrate / 100.00)
        /* 2001-06-04 */
        if (select sale from goods where gid = @d_gdgid) <> 1
          select @i_price = @d_inprc
        else
          if (select INPRCTAX from SYSTEM) = 1
            select @i_price = @d_alcprc
          else
            select @i_price = @d_alcprc / (1.0 + @g_taxrate/100.0)
        if @DirOutWriteZBRpt = 0
        begin
          if @sale = 1
          execute @return_status = STKOUTBCKDTLCHKCRT
            '直配', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
            @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
            @money1, @i_price, @d_rtlprc, @m_vendor, 1, 0, @d_total /*2002.08.28*/
          else
          execute @return_status = STKOUTBCKDTLCHKCRT
            '直配', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
            @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
            @money1, @i_price, @d_rtlprc, @m_vendor, 1, 0, null
          if @return_status <> 0 break
        end
/*2002-02-05 YSP:便利版并入标准版*/
	  if @isbianli = 1
	  begin
		select @money1 = @d_qty + @d_loss
		execute @return_status = UNLOAD @m_receiver, @d_gdgid, @money1, @g_rtlprc, @d_validdate
		if @return_status <> 0 break

        /* 调整库存快照的依据是KEPTDATE>OCRDATE*/
        if exists(select * from ckinv where wrh = @m_receiver and KEPTDATE > @m_OCRDATE )
	    begin
        	if not exists( select * from ckinv where wrh = @m_receiver and GDGID = @d_gdgid )
        	begin
        	  insert into ckinv (WRH,GDGID,QTY,TOTAL,KEPTDATE,INPRC,RTLPRC)
	          values (@m_receiver, @d_gdgid, 0, 0, @m_ocrdate, @d_inprc, @d_rtlprc)
        	  insert into pcks (SETTLENO,GDGID,WRH,SUBWRH,ACNTQTY,QTY,
        	         ACNTTL,TOTAL,OVFAMT,LOSAMT,INPRC,RTLPRC)
                  values (@m_settleno, @d_gdgid, @m_receiver,0,0,0,
                         0,0,0,0,@d_inprc, @d_rtlprc)
	        end
			update ckinv
		      set QTY = QTY - @money1,
			  TOTAL = case when QTY - @money1 >=0 then (QTY - @money1)*RTLPRC else 0 end
			  where WRH = @m_receiver and GDGID = @d_gdgid

            update PCKS
              set ACNTQTY = ACNTQTY - @money1,
			  ACNTTL = case when ACNTQTY - @money1 >=0 then (ACNTQTY - @money1)*RTLPRC else 0 end,
              OVFAMT = case when QTY - ACNTQTY + @money1 >= 0 then (QTY - ACNTQTY + @money1) * RTLPRC else 0 end,
			  LOSAMT = case when ACNTQTY - @money1 - QTY > 0 then (ACNTQTY - @money1 - QTY)  * RTLPRC else 0 end
              where wrh = @m_receiver and gdgid = @d_gdgid
            end
	    end
/*2002-02-05 YSP:便利版并入标准版*/
      end
    end

    /* 2000-2-25 */
    if @cls = '直销退'
    begin
      --2002-06-13
      update DIRALCDTL set COST = TOTAL
        where CLS = @cls and NUM = @num and LINE = @d_line

      execute @return_status = STKINBCKDTLCRT
        @cur_date, @cur_settleno, @cur_date, @cur_settleno,
        '自营', @d_wrh, @d_gdgid, @m_vendor, @m_psr,
        @d_qty, @d_price, @d_total, @d_tax, /*2002-04-18 @d_inprc*/@d_alcprc, @d_rtlprc, @mode
      if @return_status <> 0 break
      if @mode = 0 or @mode = 2
      begin
        select @money1 = @d_alcamt - @d_alcamt / (1.00 + @g_taxrate / 100.00)
        /* 2001-06-04 */
        if (select sale from goods where gid = @d_gdgid) <> 1
          select @i_price = @d_inprc
        else
          if (select INPRCTAX from SYSTEM) = 1
            select @i_price = @d_alcprc
          else
            select @i_price = @d_alcprc / (1.0 + @g_taxrate/100.0)
        if @sale = 1
        execute @return_status = STKOUTBCKDTLCHKCRT
          '批发', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
          @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
          @money1, @i_price, @d_rtlprc, @m_vendor, 1, 0, @d_total/*2002.08.28*/
        else
        execute @return_status = STKOUTBCKDTLCHKCRT
          '批发', @cur_date, @cur_settleno, @m_fildate, @m_settleno,
          @m_receiver, @m_psr, @d_wrh, @d_gdgid, @d_qty, @d_alcamt,
          @money1, @i_price, @d_rtlprc, @m_vendor, 1, 0, null
        if @return_status <> 0 break
      end

      if (@mode in (0,2)) and (@m_paymode <> '应收款') begin  /*2002-01-17*/
        select @dd_qty = -@d_qty, @dd_alcamt = -@d_alcamt
        execute @return_status = RCPDTLCHK
          @cur_date, @cur_settleno, @m_receiver, @d_gdgid, @d_wrh, @dd_qty,
          @dd_alcamt, @d_inprc, @d_rtlprc
      end
      if @return_status <> 0 break
    end

    /* 2000-2-28: 生成提单明细 */
    if @gendsp = 1
    begin
      insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
        SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE, /* 2000-05-13 */SUBWRH )
      values ( @dsp_num, @d_line, @d_line, @d_gdgid, @d_price, @d_qty,
        @d_total, 0, 0, 0, null, @d_subwrh )
      execute IncDspQty @d_wrh, @d_gdgid, @d_qty, /*00-3-3*/ @d_subwrh
    end

    fetch next from c_diralc into
      @d_line, @d_gdgid, @d_wrh, @d_qty, @d_loss, @d_price, @d_total, @d_tax,
      @d_alcprc, @d_alcamt, @d_validdate, @d_inprc, @d_rtlprc, @d_subwrh, @ordline/*2003-08-27*/
  end
  close c_diralc
  deallocate c_diralc
----------------------------------------------------------------------------------------------------

  /* 2001-05-29:设置ORD.FINISHED*/
  if @cls = '直配进'
  begin
    if @mode in (0, 2)
    begin
      if @isneg = 0
        execute @return_status = DECORDQTY 'DIRALC', @cls, @num
      if @return_status <> 0 return(@return_status)
    end

    if @m_ordnum is not null
    begin
      if not exists
      (select * from ORDDTL where NUM = @m_ordnum
      and QTY > ARVQTY + ASNQTY)
        update ORD set FINISHED = 1 where NUM = @m_ordnum
      else
        update ORD set FINISHED = 0 where NUM = @m_ordnum

      /*2002-09-10*/
      exec OPTREADINT 84, 'WriteBackToOrd', 0, @optvalue output
      if @optvalue = 1
      begin
        update ORD set FINISHED = case when @isneg = 0 then 1 else 0 end
          where NUM = @m_ordnum
        if @isneg = 0
          /* Q5965 jinlei 扣除定单上剩余的在单量 */
          exec @return_status = ChgOrdQty @CLS, @m_ordnum
      end
    end
  end

/*2002-02-05 YSP:便利版并入标准版*/
  if @cls = '直配出'
  begin
    if @m_ordnum is not null
    begin
      if not exists
      (select * from ORDDTL where NUM = @m_ordnum
      and QTY > ARVQTY + ASNQTY)
        update ORD set FINISHED = 1 where NUM = @m_ordnum
      else
        update ORD set FINISHED = 0 where NUM = @m_ordnum

      /*2002-04-19*/
      exec OPTREADINT 164, 'WriteBackToOrd', 0, @optvalue output
      if @optvalue = 1
        update ORD set FINISHED = case when @isneg = 0 then 1 else 0 end
          where NUM = @m_ordnum
    end
  end
/*2002-02-05 YSP:便利版并入标准版*/

  if (@mode in (0,2)) and (@m_paymode <> '应收款') begin            /*此时，这张批发单的结算状态应该是已结清 2001-10-29*/
      if @cls in ('直销','直销退') and (select RcpFinished from DirAlc where num = @num and cls = @cls )<>1 begin
         update Diralc
         set RcpFinished = 1 where num = @num and cls = @cls

        update DirAlcDtl
        set rcpqty = qty,rcpamt = alcamt
        where num = @num and cls = @cls
     end
  end

    --2006-1-3 ShenMin, Q5960, 信用额度增加直配单据的控制
  declare
    @opt_UseLeaguestore int,
    @receiver int,
    @total money,
    @account1 money,
    @account2 money,
    @account3 money
  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output
  if @opt_UseLeaguestore = 1 and @cls = '直配出'
  begin
    select  @total = TOTAL, @receiver = receiver from DIRALC(nolock) where CLS = @cls and NUM = @num
    execute @return_status = UPDLEAGUESTOREALCACCOUNTTOTAL @NUM, @receiver, '直配出', @total
  end

  if @opt_UseLeaguestore = 1 and @cls = '直配出退'
  begin
    select  @account1 = TOTAL, @receiver = receiver from DIRALC(nolock) where CLS = @cls and NUM = @num
    select @account2 = total, @account3 = account from LEAGUESTOREALCACCOUNT(nolock)
    where storegid = @receiver
    if @account3 + @account2 + @account1 < 0
      begin
        raiserror('该单据金额为负，配货信用额与交款额不足,不能审核', 16, 1)
        return(5)
      end
    else
      begin
        set @account1 = -@account1
        exec UPDLEAGUESTOREALCACCOUNTTOTAL @num, @receiver, '直配出退', @account1
      end
  end

  if @cls = '直配进退' or @cls = '直配出退'
  begin
    update BCKEXPFEE set PROCAMT = EXPAMT where VDRGID = @m_vendor
  end

  return(@return_status)
end
GO
