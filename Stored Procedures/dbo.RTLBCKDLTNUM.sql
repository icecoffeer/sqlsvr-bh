SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLBCKDLTNUM](
    @p_old_num char(10),
    @p_new_oper int,
    @p_neg_num char(10),
    @errmsg varchar(200) = '' output
) with encryption as
begin
    declare
        @ret_status int,        @cur_settleno int,      @usergid int,
        @cur_date datetime,     @style smallint
    declare
        @om_settleno int,       @om_fildate datetime,   @om_stat smallint,
        @om_total money,        @om_filler int,         @om_wrh int,
        @om_modnum char(10),    @om_invno char(10),     @om_note varchar(100),
        @om_reccnt int,         @om_checker int,        @om_tax money,
        @om_dspwrh char(10),    @om_provider int,       @om_assistant int/*2005-8-27*/
    declare
        @od_gdgid int,          @od_cases money,        @od_qty money,
        @od_price money,        @od_discount money,     @od_amount money,
        @od_inprc money,        @od_rtlprc money,       @od_subwrh int,
	@od_line smallint,      @od_tax money, @od_blueCardCost money, @od_RedCardCost money /*tianlei 2007-09-14 add*/
    declare
        @g_inprc money,         @g_rtlprc money,        @g_vdr int,
        @g_taxrate money,	@t_money1 money, @g_sale int, @g_payrate money /*tianlei 2007-09-14 add*/
    declare
        @in_num char(10),       @temp_qty money,        @temp_total money,
        @usezbinprc int  /*2005-8-23*/

    select @usergid = USERGID from SYSTEM
    select @ret_status = 0,
        @cur_date = convert(datetime, convert(char, getdate(), 102)),
        @cur_settleno = max(NO)
        from MONTHSETTLE
    select @om_settleno = SETTLENO, @om_fildate = FILDATE, @om_stat = STAT,
        @om_total = TOTAL, @om_filler = FILLER, @om_wrh = WRH,
        @om_modnum = MODNUM, @om_invno = INVNO, @om_note = NOTE,
        @om_reccnt = RECCNT, @om_checker = CHECKER, @om_tax = TAX,
        @om_dspwrh = DSPWRH, @om_provider = PROVIDER, @om_assistant = ASSISTANT/*2005-8-27*/
        from RTLBCK where NUM = @p_old_num
    if @om_stat <> 1
    begin
        raiserror('冲的不是已审核的单据', 16, 1)
        return(1)
    end

	/*2005-8-23 检查配货价是否使用总部成本价*/
	if @om_provider = @usergid
		select @usezbinprc = 0
	else if exists(select 1 from hdoption(nolock) where moduleno = 284 and optioncaption = 'PriceType' and optionvalue = '1')
		select @usezbinprc = 1
	else
		select @usezbinprc = 0

  /* 00-4-07 */
  execute @ret_status = CanDeleteBill 'RTLBCK', null, @p_old_num, @errmsg output
  if @ret_status != 0 begin
    raiserror(@errmsg, 16, 1)
    return(@ret_status)
  end
    update RTLBCK set STAT = 2 where NUM = @p_old_num

    insert into RTLBCK(
        NUM, SETTLENO, FILDATE, STAT, TOTAL,
        FILLER, WRH, MODNUM, INVNO, NOTE,
        RECCNT, CHECKER, TAX, DSPWRH, PROVIDER, ASSISTANT/*2005-8-27*/)
        values (@p_neg_num, @cur_settleno, getdate(), 4, -@om_total,
        @p_new_oper, @om_wrh, @p_old_num, @om_invno, null,
        @om_reccnt, @om_checker, -@om_tax, @om_dspwrh, @om_provider, @om_assistant/*2005-8-27*/)
    insert into RTLBCKCURDTL(
        NUM, ITEMNO, CURRENCY, AMOUNT)
        select @p_neg_num, ITEMNO, CURRENCY, -AMOUNT
        from RTLBCKCURDTL
        where NUM = @p_old_num

    /*insert into RTLBCKDTL(
        NUM, LINE, SETTLENO, GDGID, CASES,
        QTY, PRICE, DISCOUNT, AMOUNT, RTLPRC,
        INPRC, SUBWRH, ALCPRC, DSPSUBWRH, TAX, COST, BlueCardCost, RedCardCost, VouAmt)
        select @p_neg_num, LINE, @cur_settleno, GDGID, -CASES,
        -QTY, PRICE, DISCOUNT, -AMOUNT, RTLPRC,
        INPRC, SUBWRH, ALCPRC, DSPSUBWRH, -TAX, -COST, BlueCardCost, RedCardCost, VouAmt
        from RTLBCKDTL
        where NUM = @p_old_num
    update BILLAPDX set NUM = @p_neg_num
        where BILL = 'RTLBCK' and CLS = '' and NUM = @p_old_num*/

       insert into RTLBCKDTL(
        NUM, LINE, SETTLENO, GDGID, CASES,
        QTY, PRICE, DISCOUNT, AMOUNT, RTLPRC,
        INPRC, SUBWRH, ALCPRC, DSPSUBWRH, TAX, COST, BlueCardCost, RedCardCost, VouAmt)
        select @p_neg_num, LINE, @cur_settleno, GDGID, -CASES,
        -QTY, PRICE, DISCOUNT, -AMOUNT, RTLPRC,
        INPRC, SUBWRH, ALCPRC, DSPSUBWRH, -TAX, -COST, -BlueCardCost, -RedCardCost, -VouAmt
        from RTLBCKDTL
        where NUM = @p_old_num
    update BILLAPDX set NUM = @p_neg_num
        where BILL = 'RTLBCK' and CLS = '' and NUM = @p_old_num

    declare c_rtlbckdlt cursor for
        select LINE, GDGID, CASES, QTY, PRICE, DISCOUNT,
            AMOUNT, RTLPRC, INPRC, SUBWRH, ISNULL(BlueCardCost, 0), ISNULL(RedCardCost, 0) /*tianlei 2007-09-14 add RedCardCost*/
        from RTLBCKDTL
        where NUM = @p_old_num
    open c_rtlbckdlt
    fetch next from c_rtlbckdlt into
        @od_line, @od_gdgid, @od_cases, @od_qty , @od_price, @od_discount,
        @od_amount, @od_rtlprc, @od_inprc, @od_subwrh, @od_blueCardCost, @od_RedCardCost /*tianlei 2007-09-14 add RedCardCost*/
    while @@fetch_status = 0
    begin
        select @g_inprc = INPRC/*LSTINPRC 2003-04-16*/, @g_rtlprc = RTLPRC, @g_vdr = BILLTO,
            @g_taxrate = SALETAX, @g_sale = sale, @g_payrate = payrate /*tianlei 2007-09-14 add sale payrate*/
        from GOODSH where GID = @od_gdgid

        if @usezbinprc = 1
            /*2005-8-23 如果经销、代销商品使用总部成本价，则不在门店移动平均；联销商品调用UPDINVPRC也没任何实际效果*/
           select @ret_status = 0
        else
        begin
            /*2003-04-15*/
            select @temp_qty = -@od_qty, @temp_total = -@od_qty * @od_inprc
            execute UPDINVPRC '进货', @od_gdgid, @temp_qty, @temp_total 
        end

        /* 库存，在调用UNLOAD的时候尚有问题 */
        execute @ret_status = UNLOAD @om_wrh, @od_gdgid, @od_qty, @g_rtlprc, null
        if @ret_status <> 0 break

    	if (select batchflag from system) = 1
    	begin
      		/* 00-3-16: system.batchflag=1时对输入的检查 */
      		if @od_subwrh is null begin
        		select @errmsg = name + '[' + code + ']' from goodsh where gid = @od_gdgid
        		select @ret_status = 1011
        		select @errmsg = '必须提供货位批号: 第' + convert(char(3), @od_line) + '行,' + @errmsg
        		break
      		end
      		select @t_money1 = isnull((select qty from subwrhinv where subwrh = @od_subwrh and gdgid = @od_gdgid), 0)
      		if @od_qty > @t_money1 begin
        		select @ret_status = 1012
        		select @errmsg = name + '[' + code + ']' from goodsh where gid = @od_gdgid
        		select @errmsg = '当前库存中数量少于冲单的数量: 第' + convert(char(3), @od_line) + '行,' + @errmsg
        		break
      		end
    	end
        if @od_subwrh is not null and (select DSP from SYSTEM) = 0
        begin
            execute @ret_status = UNLOADSUBWRH @om_wrh, @od_subwrh, @od_gdgid, @od_qty
            if @ret_status <> 0 break
        end
        /* 写入报告 */
        select @od_tax = @od_amount - convert(dec(20,2), @od_amount * 100 / (100 + @g_taxrate))  /*2001-04-29*/
        if @g_sale = 3 /*tianlei 2007-09-14 add*/
          insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID, PARAM, /*2001-04-27*/
            LST_Q, LST_A, LST_T, LST_I, LST_R)
            values (@cur_date, @cur_settleno, @om_wrh, @od_gdgid, 1, 1, @g_vdr, 0, 
            -@od_qty, -(@od_amount - @od_tax), -@od_tax,  /*2001-04-29*/
            -((@od_amount + @od_blueCardCost + @od_RedCardCost)* @g_PayRate/100 - @od_blueCardCost),  -@od_qty * @od_rtlprc)  /*2003-04-15*/        
        else
          insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID, PARAM, /*2001-04-27*/
            LST_Q, LST_A, LST_T, LST_I, LST_R)
            values (@cur_date, @cur_settleno, @om_wrh, @od_gdgid, 1, 1, @g_vdr, 0, 
            -@od_qty, -(@od_amount - @od_tax), -@od_tax,  /*2001-04-29*/
--            -@od_qty * @g_inprc, -@od_qty * @g_rtlprc)
            -(@od_qty * @od_inprc - @od_blueCardCost),  -@od_qty * @od_rtlprc)  /*2003-04-15*/

        if @od_inprc <> @g_inprc or @od_rtlprc <> @g_rtlprc or @od_blueCardCost<>0
        begin
        	 if @g_sale = 3 /*tianlei 2007-09-13 add*/
             insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                values (@cur_settleno, @cur_date, @od_gdgid, @om_wrh,
               (@od_amount + @od_blueCardCost + @od_RedCardCost)* @g_PayRate/100 - @od_blueCardCost - @g_inprc * @od_qty , (@g_rtlprc-@od_rtlprc) * -@od_qty)        	 
        	 else
             insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                values (@cur_settleno, @cur_date, @od_gdgid, @om_wrh,
                (@g_inprc-@od_inprc) * -@od_qty - @od_blueCardCost, (@g_rtlprc-@od_rtlprc) * -@od_qty)
        end

        fetch next from c_rtlbckdlt into
            @od_line, @od_gdgid, @od_cases, @od_qty , @od_price, @od_discount,
            @od_amount, @od_rtlprc, @od_inprc, @od_subwrh, @od_blueCardCost, @od_RedCardCost
    end
    close c_rtlbckdlt
    deallocate c_rtlbckdlt

    return(@ret_status)
end
GO
