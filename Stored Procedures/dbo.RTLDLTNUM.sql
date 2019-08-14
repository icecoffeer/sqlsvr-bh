SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLDLTNUM](
    @p_old_num char(10),
    @p_new_oper int,
    @p_neg_num char(10),
    @errmsg varchar(200) = '' output
) with encryption 
as
begin
    declare
        @ret_status int,        @cur_date datetime,     @cur_settleno int,
        @style smallint,        @usergid int,           @gendsp int
    declare
        @om_settleno int,       @om_fildate datetime,   @om_stat smallint,
        @om_total money,        @om_tax money,          @om_change money,
        @om_filler int,         @om_undertaker int,     @om_warrantor int,
        @om_wrh int,            @om_dspunit int,        @om_dspwrh char(10),
        @om_provider int,       @om_modnum char(10),    @om_invno char(10),
        @om_note varchar(100),  @om_reccnt int,         @om_sender int,
        @om_assistant int,      @om_checker int/*2005-8-27*/
    declare
        @dsp_num char(10),      @dsp_stat smallint,     @in_num char(10),
        @alc_num char(10)
    declare
        @od_gdgid int,          @od_cases money,        @od_qty money,
        @od_price money,        @od_discount money,     @od_inprice money,
        @od_alcprc money,       @od_amount money,       @od_rtlprc money,
        @od_inprc money,        @od_subwrh int,         @od_dspsubwrh char(10),
        @od_tax money,
        @op_usezbinprc int,     @op_usezbalcprc int,
        @od_alcamt money,       @od_alctax money,  /*2005-8-13*/
        @od_blueCardCost money, @od_VouAmt money, @od_RedCardCost money
    declare
        @g_inprc money,         @g_rtlprc money,        @g_vdr int,
        @g_taxrate money,       @temp_total money,      @g_payrate money,
        @g_sale int /*tianlei 2007-09-14 增加 @g_payrate @g_sale*/

    select @usergid = usergid from SYSTEM
    select @ret_status = 0,
        @cur_date = convert(datetime, convert(char, getdate(), 102)),
        @cur_settleno = max(NO)
        from MONTHSETTLE
    select @om_settleno = SETTLENO, @om_fildate = FILDATE, @om_stat = STAT,
        @om_total = TOTAL, @om_tax = TAX, @om_change = CHANGE,
        @om_filler = FILLER, @om_undertaker = UNDERTAKER, @om_warrantor = WARRANTOR,
        @om_wrh = WRH, @om_dspunit = DSPUNIT, @om_dspwrh = DSPWRH,
        @om_provider = PROVIDER, @om_modnum = MODNUM, @om_invno = INVNO,
        @om_note = NOTE, @om_reccnt = RECCNT, @om_assistant = ASSISTANT, @om_checker = CHECKER/*2005-8-27*/
        from RTL
        where NUM = @p_old_num
    if @om_stat <> 1  /* 应是 <> 1 */
    begin
        raiserror('冲的不是已审核的单据', 16, 1)
        return(1)
    end

  /* 00-4-07 */
  execute @ret_status = CanDeleteBill 'RTL', null, @p_old_num, @errmsg output
  if @ret_status != 0 begin
    raiserror(@errmsg, 16, 1)
    return(@ret_status)
  end
    /* 按照供货单位确定单据类型，@style:
        1   本店
        2   配供
        3   供应商    */
    if @om_provider = @usergid
        select @style = 1
    else                                                                                
    begin
        if not exists(select 1 from STORE where GID = @om_provider)
            select @style = 3
        else
            select @style = 2
    end

	/*2005-8-8*/
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost1' and OPTIONVALUE = '1')
		select @op_usezbinprc = 1
	else
		select @op_usezbinprc = 0
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost2' and OPTIONVALUE = '1')
		select @op_usezbalcprc = 1
	else
		select @op_usezbalcprc = 0

    if (select DSP from SYSTEM) & 16 <> 0
        select @gendsp = 1
    else
        select @gendsp = 0

    /* 检查对应的提货单，并进行作废处理 */
    if @gendsp = 1 and @style <> 2
    begin
        select @dsp_num = NUM, @dsp_stat = STAT
             from DSP
             where CLS = 'RTL' and POSNOCLS = '' and FLOWNO = @p_old_num
        if @dsp_stat <> 0
        begin
            raiserror('该单据已被提货，不能冲单。', 16, 1)
            return(2)
        end
        execute @ret_status = DSPABORT @dsp_num
        if @ret_status <> 0
        begin
            raiserror('不能作废相关的提货单。', 16, 1)
            return(3)
        end
    end

    update RTL set STAT = 2 where NUM = @p_old_num

    insert into RTL(
        NUM, SETTLENO, FILDATE, STAT, TOTAL,
        TAX, CHANGE, FILLER, UNDERTAKER, WARRANTOR,
        WRH, DSPUNIT, DSPWRH, PROVIDER, MODNUM,
        INVNO, NOTE, RECCNT, SENDER, ASSISTANT, CHECKER/*2005-8-27*/)
        values (@p_neg_num, @cur_settleno, getdate(), 4, -@om_total,
        -@om_tax, -@om_change, @p_new_oper, @om_undertaker, @om_warrantor,
        @om_wrh, @om_dspunit, @om_dspwrh, @om_provider, @p_old_num,
        @om_invno, null, @om_reccnt, @om_sender, @om_assistant, @om_checker/*2005-8-27*/)
   


 insert into RTLCURDTL(
        NUM, ITEMNO, CURRENCY, AMOUNT, CARDNUM)
        select @p_neg_num, ITEMNO, CURRENCY, -AMOUNT, CARDNUM
        from RTLCURDTL
        where NUM = @p_old_num


/*if exists(select 1 from RTLCURDTL(nolock) where currency in (select code from currency(nolock) where name='IC卡'))
 insert into RTLCURDTL(
        NUM, ITEMNO, CURRENCY, AMOUNT, CARDNUM)
        select @p_neg_num, ITEMNO, 
         case currency when (select code from currency(nolock) where name='IC卡') then '1' else currency end, 
         -AMOUNT, CARDNUM
        from RTLCURDTL
        where NUM = @p_old_num 
else 
 insert into RTLCURDTL(
        NUM, ITEMNO, CURRENCY, AMOUNT, CARDNUM)
        select @p_neg_num, ITEMNO, CURRENCY, -AMOUNT, CARDNUM
        from RTLCURDTL
        where NUM = @p_old_num
*/
--
    insert into RTLDTL(
        NUM, LINE, SETTLENO, GDGID, CASES,
        QTY, PRICE, DISCOUNT, INPRICE, ALCPRC,
        AMOUNT, RTLPRC, INPRC, SUBWRH, DSPSUBWRH,
        TAX, COST, BlueCardCost, RedCardCost, VouAmt/*2005-8-23*/)
        select @p_neg_num, LINE, @cur_settleno, GDGID, -CASES,
        -QTY, PRICE, DISCOUNT, INPRICE, ALCPRC,
        -AMOUNT, RTLPRC, INPRC, SUBWRH, DSPSUBWRH,
        -TAX, COST, -BlueCardCost, -RedCardCost, -VouAmt/*2005-8-23*/
        from RTLDTL
        where NUM = @p_old_num
    update BILLAPDX set NUM = @p_neg_num
        where BILL = 'RTL' and CLS = '' and NUM = @p_old_num

    declare c_rtldlt cursor for
        select GDGID, CASES, QTY, PRICE, DISCOUNT, INPRICE,
            ALCPRC, AMOUNT, RTLPRC, INPRC, SUBWRH, DSPSUBWRH, BlueCardCost, RedCardCost, VouAmt
        from RTLDTL
        where NUM = @p_old_num
    open c_rtldlt
    fetch next from c_rtldlt into
        @od_gdgid, @od_cases, @od_qty, @od_price, @od_discount, @od_inprice,
        @od_alcprc, @od_amount, @od_rtlprc, @od_inprc, @od_subwrh, @od_dspsubwrh, @od_BlueCardCost, @od_RedCardCost, @od_VouAmt
    while @@fetch_status = 0
    begin
        select @g_inprc = INPRC, @g_rtlprc = RTLPRC, @g_vdr = BILLTO,
            @g_taxrate = SALETAX, @g_payRate = payrate, @g_sale = sale /* tianlie add get payrate sale 2007-09-14*/
            from GOODSH where GID = @od_gdgid

        if @style = 1 or (@style = 3 and @op_usezbalcprc = 0)
            or (@style = 2 and @op_usezbinprc = 0)  /*2005-8-23*/
        begin
            /*2003-04-15*/
            select @temp_total = @od_qty * @od_inprc
            execute UPDINVPRC '进货', @od_gdgid, @od_qty, @temp_total
        end

        /* 库存 */
        if @od_subwrh is not null --and (select DSP from SYSTEM) & 16 = 16
        begin
            execute @ret_status = LOADINSUBWRH
                @om_wrh, @od_subwrh, @od_gdgid, @od_qty,
                @od_price   /* 2000-6-29 Li Ximing ref 用货位实现批次管理三.doc */
            if @ret_status <> 0 break
        end
        execute @ret_status = LOADIN
            @om_wrh, @od_gdgid, @od_qty, @g_rtlprc, null
        if @ret_status <> 0 break

        /* 写入报表 */
     --ShenMin
	/*将优惠金额作为后台优惠记入报表*/
	declare @od_favamt MONEY	
	set @od_favamt = @od_amount - @od_rtlprc * @od_qty
	
        select @od_tax = @od_amount - convert(dec(20,2), @od_amount * 100 / (100 + @g_taxrate))
        
        if (@od_favamt <> 0)  and ((select PRCTYPE from GOODSH where gid = @od_gdgid) <> 1)  --ShenMin, 2005.11.10, 可变价商品不记录优惠额         
        begin
        	if @g_sale = 3 --tianlei add对联销商品的处理    	 联销商品如果使用红蓝卡  成本＝（实收金额＋红卡＋蓝卡）× 联销率 — 蓝卡
            insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,PARAM,/*2001-04-27*/
              LS_Q, LS_A, LS_T, LS_I, LS_R, LS1_Q, LS1_A) --ShenMin
            values (@cur_date, @cur_settleno, @om_wrh, @od_gdgid, 1, 1, @g_vdr, 0,
              -@od_qty, -(@od_amount - @od_tax), -@od_tax,
--            -@od_qty * @g_inprc, -@od_qty * @g_rtlprc)
             -((@od_amount + @od_blueCardCost + @od_RedCardCost)* @g_PayRate/100 - @od_blueCardCost) , -@od_qty * @od_rtlprc, @od_qty, @od_favamt) --ShenMin  /*2003-04-15 不能用当前inprc记报表，同时还记录di3*/        	
          else
            insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,PARAM,/*2001-04-27*/
              LS_Q, LS_A, LS_T, LS_I, LS_R, LS1_Q, LS1_A) --ShenMin
            values (@cur_date, @cur_settleno, @om_wrh, @od_gdgid, 1, 1, @g_vdr, 0,
              -@od_qty, -(@od_amount - @od_tax), -@od_tax,
--            -@od_qty * @g_inprc, -@od_qty * @g_rtlprc)
             -(@od_qty * @od_inprc - @od_BlueCardCost) , -@od_qty * @od_rtlprc, @od_qty, @od_favamt) --ShenMin  /*2003-04-15 不能用当前inprc记报表，同时还记录di3*/
        end    
        else begin
        	if @g_sale = 3 /*tianlei add*/        	
            insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,PARAM,/*2001-04-27*/
              LS_Q, LS_A, LS_T, LS_I, LS_R)
            values (@cur_date, @cur_settleno, @om_wrh, @od_gdgid, 1, 1, @g_vdr, 0,
              -@od_qty, -(@od_amount - @od_tax), -@od_tax,
--            -@od_qty * @g_inprc, -@od_qty * @g_rtlprc)
              -((@od_amount + @od_blueCardCost + @od_RedCardCost)* @g_PayRate/100 - @od_blueCardCost), -@od_qty * @od_rtlprc)  /*2003-04-15 不能用当前inprc记报表，同时还记录di3*/  
          else
            insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,PARAM,/*2001-04-27*/
              LS_Q, LS_A, LS_T, LS_I, LS_R)
            values (@cur_date, @cur_settleno, @om_wrh, @od_gdgid, 1, 1, @g_vdr, 0,
              -@od_qty, -(@od_amount - @od_tax), -@od_tax,
--            -@od_qty * @g_inprc, -@od_qty * @g_rtlprc)
              -(@od_qty * @od_inprc - @od_BlueCardCost), -@od_qty * @od_rtlprc)  /*2003-04-15 不能用当前inprc记报表，同时还记录di3*/  
          	  
        end    
                        
        /* 生成调价差异, 库存已经按照当前售价退库了 */
        if @od_inprc <> @g_inprc or @od_rtlprc <> @g_rtlprc or @od_blueCardCost <> 0 
        begin
        	if @g_sale = 3 /*tianlei add*/
            insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                values (@cur_settleno, @cur_date, @od_gdgid, @om_wrh,
                @g_inprc * @od_qty - ((@od_amount + @od_blueCardCost + @od_RedCardCost)* @g_PayRate/100 - @od_blueCardCost) , (@g_rtlprc-@od_rtlprc) * @od_qty)     
                --(@g_inprc - @od_inprc) * @od_qty + @od_blueCardCost , (@g_rtlprc-@od_rtlprc) * @od_qty)        	
          else
            insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
                values (@cur_settleno, @cur_date, @od_gdgid, @om_wrh,
                (@g_inprc - @od_inprc) * @od_qty + @od_blueCardCost , (@g_rtlprc-@od_rtlprc) * @od_qty)
        end

        fetch next from c_rtldlt into
            @od_gdgid, @od_cases, @od_qty, @od_price, @od_discount, @od_inprice,
            @od_alcprc, @od_amount, @od_rtlprc, @od_inprc, @od_subwrh, @od_dspsubwrh, @od_BlueCardCost, @od_RedCardCost, @od_VouAmt
    end
    close c_rtldlt
    deallocate c_rtldlt

    return(@ret_status)
end
GO
