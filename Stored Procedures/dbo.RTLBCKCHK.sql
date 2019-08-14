SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLBCKCHK](
    @p_num char(10)
) with encryption as
begin
    declare
        @ret_status int,        @cur_settleno int,          @usergid int,
        @msg varchar(200),      @style smallint,            @cur_date datetime  /*2001-06-05*/
    declare
        @m_settleno int,        @m_fildate datetime,        @m_stat smallint,
        @m_total money,         @m_filler int,              @m_wrh int,
        @m_modnum char(10),     @m_invno char(10),          @m_note varchar(100),
        @m_reccnt int,          @m_checker int,             @m_tax money,
        @m_dspwrh int,          @m_provider int
    declare
        @d_line smallint,       @d_gdgid int,               @d_cases money,
        @d_qty money,           @d_price money,             @d_discount money,
        @d_amount money,        @d_subwrh int,              @d_tax money,  /*2001-04-29*/
		@d_alcprc money,  /*2005-8-13*/
        @d_blueCardCost money,  @d_RedCardCost money /*tianlei add @d_RedCardCost*/      
    declare
        @g_inprc money,         @g_rtlprc money,            @g_vdr int,
        @g_taxrate money,       @g_sale int,                @g_payrate money /*tianlei add @g_payrate */        
    declare
        @in_num char(10),       @max_in_num char(10),       @m_alc_total money,
        @m_alc_tax money,	@mod_qty money
    declare  /*2001-06-05*/
        @gdinprc money,         @curtime datetime,          @return_status int,
		@op_noalcprofit int,    @usezbinprc int  /*2005-8-23*/
    declare
        @m_gftpro int,          @m_gftprowrh int,           @mgd_wrh int,
        @GftFlag int

    DECLARE @D_COSTPRC MONEY,@D_COST MONEY /*HXS 2002.02.10*/
    declare
        @opt_UseLocalPrmInprc int  --ShenMin

    select @ret_status = 0
    select
        @m_settleno = SETTLENO, @m_fildate = FILDATE, @m_stat = STAT,
        @m_total = TOTAL, @m_filler = FILLER, @mgd_wrh = WRH,
        @m_modnum = MODNUM, @m_invno = INVNO, @m_note = NOTE,
        @m_reccnt = RECCNT, @m_checker = CHECKER, @m_tax = TAX,
        @m_dspwrh = DSPWRH, @m_provider = PROVIDER, @m_gftpro = GFTPRO, 
        @m_gftprowrh = GFTPROWRH
        from RTLBCK where NUM = @p_num
    if @m_stat <> 0
    begin
        raiserror('审核的不是未审核的单据。', 16, 1)
        return(1)
    end
    select @cur_settleno = max(NO) from MONTHSETTLE
    select @cur_date = convert(datetime, convert(char, getdate(), 102)) /*2001-06-05*/
    select @usergid = USERGID from SYSTEM

    /* 按照供货单位确定单据类型，@style:
        1   本店
        2   配供    */
    if @m_provider = @usergid
        select @style = 1
    else
        select @style = 2

	/*2005-8-23 检查配货价是否使用总部成本价*/
	if @style = 1
		select @usezbinprc = 0
	else if exists(select 1 from hdoption(nolock) where moduleno = 284 and optioncaption = 'PriceType' and optionvalue = '1')
		select @usezbinprc = 1
	else
		select @usezbinprc = 0

	/*2005-8-13 检查本地配进退是否平进平出*/
	if exists(select 1 from hdoption where moduleno = 0 and optioncaption = '开启全局进出货成本平进平出' and optionvalue = '1')
		select @op_noalcprofit = 1
	else if exists(select 1 from hdoption where moduleno = 43 and optioncaption = 'ChkOption' and substring(optionvalue, 17, 1) = '1')
		select @op_noalcprofit = 1
	else
		select @op_noalcprofit = 0
		
	--2006.04.18 added by ShenMin, Q6561 增加对销售本地库存的经销商品是否取促销进价
	/*检查销售本地库存时是否使用促销进价*/
	if exists(select 1 from HDOPTION where MODULENO = 284 and OPTIONCAPTION = 'UseLocalPrmInPrc' and OPTIONVALUE = '1')
	  select @opt_UseLocalPrmInPrc = 1
	else
	  select @opt_UseLocalPrmInPrc = 0

    update RTLBCK set STAT = 1, FILDATE = getdate() where NUM = @p_num  /*2001-06-06*/

    SELECT @D_COST=0
    declare c_rtlbckchk cursor for
        select
            LINE, GDGID, CASES, QTY, PRICE, ALCPRC,
            DISCOUNT, AMOUNT, SUBWRH, COSTPRC, ISNULL(BlueCardCost, 0), isnull(GftFlag, 0), ISNULL(RedCardCost, 0)
        from RTLBCKDTL
        where NUM = @p_num
        for update
    open c_rtlbckchk
    fetch next from c_rtlbckchk into
        @d_line, @d_gdgid, @d_cases, @d_qty, @d_price, @d_alcprc,
        @d_discount, @d_amount, @d_subwrh,@D_COSTPRC, @d_blueCardCost, @GftFlag, @d_RedCardCost /*tianlei  2007.09.14 add @d_RedCardCost*/        
    while @@fetch_status = 0
    begin
      if @GftFlag = 0
	      set @M_WRH = @mgd_wrh
	    else
	      set @M_WRH = @m_gftprowrh
	      
	/*HXS 2003.02.10 处理FIFO*/
	IF (SELECT BATCHFLAG FROM SYSTEM) = 2
	BEGIN
		EXEC @RETURN_STATUS = RTLBCKFIFOCHK @STYLE,@P_NUM,@D_LINE,@M_WRH,
			@D_GDGID,@D_QTY,@D_COSTPRC,@D_COST OUTPUT,@MSG OUTPUT
		IF @RETURN_STATUS <> 0
		BEGIN
			RAISERROR(@MSG,16,1)
			BREAK
		END
	END

		select @curtime = getdate()

        select @g_inprc = INPRC/*LSTINPRC 2003-04-16*/, @g_rtlprc = RTLPRC, @g_taxrate = SALETAX, @g_vdr = BILLTO, 
               @g_sale = sale /*2001-06-05*/
            from GOODSH where GID = @d_gdgid

        /*2005-8-23
        如果经销、代销商品配货价取的是总部的成本价，则以总部成本价记日报，并不参与门店移动平均。
        如果经销、代销配货价取的是门店的价格，则以门店价格记日报，并参与门店移动平均。
        */
        if @usezbinprc = 1 and @g_sale in (1, 2)
        begin
            select @g_inprc = @d_alcprc
        end
        else
        begin
            /*2001-06-05*/
            if @g_sale = 2 
            begin 
                select @curtime = getdate()
                execute @return_status=GetGoodsPrmInprc @usergid, @d_gdgid, @curtime, @d_qty, @g_inprc output
                if @return_status <> 0
                    select @g_inprc = INPRC from GOODSH where GID = @d_gdgid
            end
            if @g_sale = 3
            begin
                select @g_inprc = @d_price * PAYRATE / 100, @g_payrate = payrate from GOODSH where GID = @d_gdgid  /*tianlei add payrate*/
            end
           --2006.4.19, Edited by ShenMin, Q6561, 门店零售退货单InPrc和CurInPrc取值  
            if @g_sale = 1 and @style = 1 and @opt_UseLocalPrmInPrc = 1
		    begin
    			select @gdinprc = @g_inprc
    			execute @return_status=GetGoodsPrmInprc @usergid, @d_gdgid, @curtime, @d_qty, @g_inprc output
    			if @return_status <> 0
    				select @g_inprc = @gdinprc
    			else
    				select @gdinprc = @g_inprc	
    		    end			

            /*2005-8-13 如果本地配进退是平进平出，则重置配货价*/
            if @op_noalcprofit = 1
                select @d_alcprc = @g_inprc
        end

        -- Q6307: 需要记录当前商品核算价
        -- Zhou Rong, 2006-03-15
        /*DECLARE @curInPrc DECIMAL;
        SELECT @curInPrc = g.InPrc FROM Goods AS g, RtlDtl AS r WHERE g.GID = r.GDGID AND r.NUM = @p_num;
        */ --Deleted by ShenMin
        update RTLBCKDTL set
            INPRC = @g_inprc, ALCPRC = @d_alcprc, RTLPRC = @g_rtlprc, COST = @d_qty * @g_inprc /*2005-8-23*/
            --CURINPRC = @CurInPrc -- Q6307--Deleted by ShenMin
            where NUM = @p_num and LINE = @d_line and isnull(gftflag, 0) = 0

        /* 库存 */
        execute @ret_status = LOADIN @m_wrh, @d_gdgid, @d_qty, @g_rtlprc, null
        if @ret_status <> 0
        begin
            select @msg = ' 不允许负库存或实行到效期管理的仓位库存不足:' +
                rtrim(convert(char,@m_wrh)) + ';' +
                rtrim(convert(char,@d_gdgid)) + ';' +
                rtrim(convert(char, @d_qty)) + ';' +
                rtrim(convert(char,@g_rtlprc))
            raiserror(@msg, 16, 1)
            break
        end
      /* 2000-3-16 增加了system.batchflag=1时的处理,
      ref 用货位实现批次管理(二).doc */
      if (select batchflag from system) = 1
      begin
          if @d_subwrh is null
          begin
              if @d_qty >= 0
              begin
            	  execute @ret_status = GetSubWrhBatch @m_wrh, @d_subwrh output, @msg output
                  if @ret_status <> 0 break
            	  update RTLBCKDTL set SUBWRH = @d_subwrh
              	  where NUM = @p_num and LINE = @d_line
              end else /* @t_qty < 0 */
              begin
                  select @msg = '门店零售退货单负数退货必须指定货位'
            	  select @ret_status = 1005
                  break
              end
          end else /* @subwrh is not null */
          begin
              if @d_qty < 0
              begin
              	  select @mod_qty = null
            	  select @mod_qty = qty from RTLBCKDTL
              	  where num = @m_modnum and subwrh = @d_subwrh
                  if @mod_qty is null
                  begin
              	      select @msg = '找不到对应的门店零售退货单'
              	      select @ret_status = 1006
                      raiserror(@msg, 16, 1)
              	      break
            	  end
                  if @mod_qty <> @d_qty
            	  begin
              	      select @msg = '数量和对应的门店零售退货单('+@m_modnum+')上的不符合'
                      select @ret_status = 1007
                      raiserror(@msg, 16, 1)
                      break
                  end
              end
          end
      end

        if @d_subwrh is not null /* and (select DSP from SYSTEM) = 0 */
        begin
            execute @ret_status = LOADINSUBWRH @m_wrh, @d_subwrh, @d_gdgid, @d_qty, @g_inprc
            if @ret_status <> 0 break
        end
        /* 单据审核 */
        select @d_tax = @d_amount - convert(dec(20,2), @d_amount * 100 / (100 + @g_taxrate))  /*2001-04-29*/
        /*FIFO HXS 2003.02.10*/
        IF (SELECT BATCHFLAG FROM SYSTEM) = 2
        BEGIN
            INSERT INTO XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
                BVDRGID, BCSTGID, PARAM,
                LST_Q, LST_A, LST_T, LST_I, LST_R)
            VALUES (@CUR_SETTLENO, @CUR_DATE,
                @M_WRH, @D_GDGID, 1, @G_VDR, 1, 0,
                @D_QTY, @D_AMOUNT - @D_TAX, @D_TAX,
                @D_COST, @D_QTY * @G_RTLPRC)
        END
        ELSE
        BEGIN
         if @g_sale = 3 /*tianlei 2007-09-14 add*/      


            insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,        
                BVDRGID, BCSTGID, PARAM,  /*2001-04-27*/        
                LST_Q, LST_A, LST_T, LST_I, LST_R)        
            values (@cur_settleno, @cur_date/*2001-06-06 convert(datetime, convert(char, @m_fildate, 102))*/,        
                @m_wrh, @d_gdgid, 1, @g_vdr, 1, 0,        
                @d_qty, @d_amount - @d_tax, @d_tax,  /*2001-04-29*/        
                (@d_amount + @d_blueCardCost + @d_RedCardCost)* @g_PayRate/100 - @d_blueCardCost, @d_qty * @g_rtlprc)                 
          else      
            insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,        
                BVDRGID, BCSTGID, PARAM,  /*2001-04-27*/        
                LST_Q, LST_A, LST_T, LST_I, LST_R)        
            values (@cur_settleno, @cur_date/*2001-06-06 convert(datetime, convert(char, @m_fildate, 102))*/,        
                @m_wrh, @d_gdgid, 1, @g_vdr, 1, 0,        
                @d_qty, @d_amount - @d_tax, @d_tax,  /*2001-04-29*/        
                @d_qty * @g_inprc - @d_blueCardCost, @d_qty * @g_rtlprc)        
        END
        /*代销商品若进行促销进价促销，生成调价差异 2001-06-05*/
        if @g_sale = 2 or (@g_sale = 3 /*2005.08.04*/)
        begin
           select @gdinprc = inprc from goodsh where gid = @d_gdgid
           if @g_inprc <> @gdinprc
           begin       
             if @g_sale = 3  /*tianlei 2007-09-14 add*/      
               insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)        
               values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,        
               @gdinprc* @d_qty-((@d_amount + @d_blueCardCost + @d_RedCardCost)* @g_PayRate/100 - @d_blueCardCost))   --sunya       
      
               --values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,        
               --(@d_amount + @d_blueCardCost + @d_RedCardCost)* @g_PayRate/100 - @d_blueCardCost - @g_inprc * @d_qty)       
                  
              else      
               insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)        
               values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,        
                      (@gdinprc-@g_inprc) * @d_qty + @d_blueCardCost)                     --sunya      
      
               --values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,        
               --(@gdinprc-@g_inprc) * @d_qty - @d_blueCardCost)        
          end           
        end
       /*经销商品若进行促销进价促销，生成调价差异 ShenMin, Q6561*/
        if @g_sale = 1 and @style = 1 and @opt_UseLocalPrmInPrc = 1
        begin
           select @gdinprc = inprc from goodsh where gid = @d_gdgid
           if @g_inprc <> @gdinprc
               insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
               values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
               (@gdinprc-@g_inprc) * @d_qty - @d_blueCardCost)
        end

        -- 红蓝卡
--        if @g_sale = 1 and not (@style = 1 and @opt_UseLocalPrmInPrc = 1) or @d_blueCardCost <> 0
 --       if @g_sale = 1 and  @opt_UseLocalPrmInPrc = 1 and (@d_blueCardCost <> 0)   
 ---      经销商品存在蓝卡，就要调整
        if @g_sale = 1 and (@d_blueCardCost <> 0)   
        begin
            select @gdinprc = inprc from goodsh where gid = @d_gdgid
            -- if @g_inprc <> @gdinprc
               insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
               values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
               (@gdinprc-@g_inprc) * @d_qty + @d_blueCardCost)    
        end

        fetch next from c_rtlbckchk into
            @d_line, @d_gdgid, @d_cases, @d_qty, @d_price, @d_alcprc,
            @d_discount, @d_amount, @d_subwrh, @D_COSTPRC, @d_blueCardCost, @GftFlag, @d_RedCardCost
    end
    close c_rtlbckchk
    deallocate c_rtlbckchk


    if @ret_status = 0 and @style = 2
    begin
        /* 生成配货进货退货单 */
        select @in_num = null
        select @max_in_num = max(NUM) from STKINBCK where cls = '配货'
        if @max_in_num is null
            select @in_num = '0000000001'
        else
            execute NEXTBN @max_in_num, @in_num output
	/* FIFO HXS 2003.02.10*/
	INSERT INTO STKINBCKDTL2(CLS,NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST)
		SELECT '配货',@IN_NUM,R.LINE,R.SUBWRH,R.WRH,R.GDGID,R.QTY,R.COST
		FROM RTLBCKDTL2 R
		WHERE R.NUM = @P_NUM

        insert into STKINBCKDTL(
            CLS, SETTLENO, NUM, LINE, GDGID,
            CASES, QTY, PRICE, TOTAL, TAX,
            VALIDDATE, WRH, INPRC, RTLPRC, BNUM,
            SUBWRH,COST/*FIFO HXS 2003.02.10*/)
        select
            '配货', @cur_settleno, @in_num, R.LINE, R.GDGID,
            R.CASES, R.QTY, R.ALCPRC, convert(dec(20,2), R.ALCPRC * R.QTY),
            convert(dec(20,2), R.ALCPRC * R.QTY) - convert(dec(20,2), R.ALCPRC * R.QTY * 100 / (100 + G.SALETAX)),
            null, @mgd_wrh, R.INPRC/*2005-8-23*/, G.RTLPRC, null,
            R.SUBWRH,R.COST
            from RTLBCKDTL R, GOODSH G
            where R.GDGID = G.GID and R.NUM = @p_num and isnull(gftflag, 0) = 0
        /*2005-8-23*/
        select @m_alc_total = sum(TOTAL), @m_alc_tax = sum(TAX), @m_reccnt = count(1)
            from STKINBCKDTL
            where CLS = '配货' and NUM = @in_num
        insert into STKINBCK (
            CLS, NUM, SETTLENO, VENDOR, VENDORNUM,
            BILLTO, OCRDATE, TOTAL, TAX, NOTE,
            FILDATE, FILLER, CHECKER, STAT, MODNUM,
            PSR, RECCNT, SRC, SRCNUM, SNDTIME,
            PRNTIME, FINISHED, CHKDATE, WRH, PRECHECKER,
            PRECHKDATE, GEN, GENBILL, GENCLS, GENNUM)
        values(
            '配货', @in_num, @cur_settleno, @m_provider, '',
            @m_provider, getdate(), @m_alc_total, @m_alc_tax, '',
            getdate(), @m_filler, @m_filler, 0, '',
            1, @m_reccnt, @usergid, null, null,
            null, 0, getdate(), @mgd_wrh, @m_filler,
            getdate(), @usergid, 'RTLBCK', null, @p_num)
        /*2005-8-25 Q4712,修正的配货进货退货单的审核由门店零售退货单修正存储过程负责调用*/
        if @m_modnum is null or @m_modnum = ''
        begin
            execute @ret_status = STKINBCKCHK '配货', @in_num, 2
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货退货单审核失败。', 16, 1)
                return(1)
            end
        end
    end
    
    if @m_gftpro = @usergid
        select @style = 1
    else
        select @style = 2
        
    if @ret_status = 0 and @style = 2
    begin
        /* 生成配货进货退货单 */
        select @in_num = null
        select @max_in_num = max(NUM) from STKINBCK where cls = '配货'
        if @max_in_num is null
            select @in_num = '0000000001'
        else
            execute NEXTBN @max_in_num, @in_num output
	/* FIFO HXS 2003.02.10*/
	INSERT INTO STKINBCKDTL2(CLS,NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST)
		SELECT '配货',@IN_NUM,R.LINE,R.SUBWRH,R.WRH,R.GDGID,R.QTY,R.COST
		FROM RTLBCKDTL2 R
		WHERE R.NUM = @P_NUM

        insert into STKINBCKDTL(
            CLS, SETTLENO, NUM, LINE, GDGID,
            CASES, QTY, PRICE, TOTAL, TAX,
            VALIDDATE, WRH, INPRC, RTLPRC, BNUM,
            SUBWRH,COST/*FIFO HXS 2003.02.10*/)
        select
            '配货', @cur_settleno, @in_num, R.LINE, R.GDGID,
            R.CASES, R.QTY, R.ALCPRC, convert(dec(20,2), R.ALCPRC * R.QTY),
            convert(dec(20,2), R.ALCPRC * R.QTY) - convert(dec(20,2), R.ALCPRC * R.QTY * 100 / (100 + G.SALETAX)),
            null, @m_gftprowrh, R.INPRC/*2005-8-23*/, G.RTLPRC, null,
            R.SUBWRH,R.COST
            from RTLBCKDTL R, GOODSH G
            where R.GDGID = G.GID and R.NUM = @p_num and isnull(gftflag, 0) = 1
        /*2005-8-23*/
        select @m_alc_total = sum(TOTAL), @m_alc_tax = sum(TAX), @m_reccnt = count(1)
            from STKINBCKDTL
            where CLS = '配货' and NUM = @in_num
        insert into STKINBCK (
            CLS, NUM, SETTLENO, VENDOR, VENDORNUM,
            BILLTO, OCRDATE, TOTAL, TAX, NOTE,
            FILDATE, FILLER, CHECKER, STAT, MODNUM,
            PSR, RECCNT, SRC, SRCNUM, SNDTIME,
            PRNTIME, FINISHED, CHKDATE, WRH, PRECHECKER,
            PRECHKDATE, GEN, GENBILL, GENCLS, GENNUM)
        values(
            '配货', @in_num, @cur_settleno, @m_gftpro, '',
            @m_gftpro, getdate(), @m_alc_total, @m_alc_tax, '',
            getdate(), @m_filler, @m_filler, 0, '',
            1, @m_reccnt, @usergid, null, null,
            null, 0, getdate(), @m_gftprowrh, @m_filler,
            getdate(), @usergid, 'RTLBCK', null, @p_num)
        /*2005-8-25 Q4712,修正的配货进货退货单的审核由门店零售退货单修正存储过程负责调用*/
        if @m_modnum is null or @m_modnum = ''
        begin
            execute @ret_status = STKINBCKCHK '配货', @in_num, 2
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货退货单审核失败。', 16, 1)
                return(1)
            end
        end
    end

    return(@ret_status)
end
GO
