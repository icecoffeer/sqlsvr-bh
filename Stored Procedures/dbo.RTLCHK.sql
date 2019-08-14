SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLCHK](
    @p_num char(10)
) with encryption as
begin
    declare
        @ret_status int,        @cur_settleno int,      @usergid int,
        @msg varchar(100),      @style smallint,        @gendsp int,
        @cur_date datetime,  /*2001-06-05*/
		@op_usezbinprc int,     @op_usezbalcprc int,  /*2005-8-6*/
		@op_usezbinprc2 int,    @op_usezbalcprc2 int  /*2005-8-23*/
    declare
        @m_fildate datetime,    @m_stat smallint,       @m_total money,
        @m_tax money,           @m_change money,        @m_filler int,
        @m_undertaker int,      @m_warrantor int,       @m_wrh int,
        @m_dspunit int,         @m_dspwrh char(10),     @m_provider int,
        @m_modnum char(10),     @m_invno char(10),      @m_note varchar(100),
        @m_reccnt int,          @m_sender int
    declare
        @d_line smallint,       @d_gdgid int,           @d_cases money,
        @d_qty money,           @d_price money,         @d_discount money,
        @d_inprice money,       @d_alcprc money,        @d_amount money,
        @d_subwrh int,          @d_dspsubwrh char(10),  @d_tax money,
        @d_blueCardCost money,  @d_RedCardCost money
    declare
        @g_inprc money,         @g_rtlprc money,        @g_vdr int,
        @g_taxrate money,       @g_whsprc money,        @g_sale int,
        @g_payrate money /*2001-06-05*/
    declare
        @dsp_num char(10),      @max_dsp_num char(10),
        @dspwrhgid int,		@dspsubwrhgid int
    declare
        @in_num char(10),       @max_in_num char(10),   @m_alc_total money,
        @m_alc_tax money,       @d_alc_total money,     @d_alc_tax money
    declare
        @dir_num char(10),      @max_dir_num char(10),  @m_in_total money,
        @m_in_tax money,        @d_in_total money,      @d_in_tax money
    declare  /*2001-06-05*/
        @gdinprc money,         @curtime datetime,      @return_status int
    declare
        @opt_UseLocalPrmInprc int
    declare
        @m_gftpro int, @m_gftprowrh int, @m_gftreccnt int, @style2 int,
        @dsp_num2 char(10), @in_num2 char(10), @dir_num2 char(10),
        @gftflag int, @M_WRHS int, @maxline int, @STYLE1 int

    DECLARE @D_COST MONEY /*HXS 2003.02.10*/
    
    DECLARE @favamt MONEY, @rtlprc MONEY  --ShenMin
    
    select @ret_status = 0
    select
        @m_fildate = FILDATE, @m_stat = STAT, @m_total = TOTAL,
        @m_tax = TAX, @m_change = CHANGE, @m_filler = FILLER,
        @m_undertaker = UNDERTAKER, @m_warrantor = WARRANTOR, @m_wrh = WRH,
        @m_dspunit = DSPUNIT, @m_dspwrh = DSPWRH, @m_provider = PROVIDER,
        @m_modnum = MODNUM, @m_invno = INVNO, @m_note = NOTE,
        @m_sender = SENDER, @m_gftpro = GFTPRO, @m_gftprowrh = GFTPROWRH
        from RTL where NUM = @p_num
    select @m_reccnt = count(1) from RTLDTL where NUM = @p_num and isnull(gftflag, 0) = 0
    select @m_gftreccnt = count(1) from RTLDTL where NUM = @p_num and isnull(gftflag, 0) = 1
    if @m_stat <> 0
    begin
        raiserror('审核的不是未审核的单据。', 16, 1)
        return(1)
    end
    select @cur_settleno = max(NO) from MONTHSETTLE
    select @cur_date = convert(datetime, convert(char, getdate(), 102)) /*2001-06-05*/
    select @usergid = USERGID from SYSTEM

    if (select DSP from SYSTEM) & 16 <> 0
        select @gendsp = 1
    else
        select @gendsp = 0

	/*2005-8-13*/
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost1' and OPTIONVALUE = '1')
		select @op_usezbinprc = 1
	else
		select @op_usezbinprc = 0
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost2' and OPTIONVALUE = '1')
		select @op_usezbalcprc = 1
	else
		select @op_usezbalcprc = 0
	/*2005-8-23*/
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost3' and OPTIONVALUE = '1')
		select @op_usezbinprc2 = 1
	else
		select @op_usezbinprc2 = 0
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost4' and OPTIONVALUE = '1')
		select @op_usezbalcprc2 = 1
	else
		select @op_usezbalcprc2 = 0
	--2006.04.18 added by wangxin 增加对销售本地库存的经销商品是否取促销进价
	if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'UseLocalPrmInPrc' and OPTIONVALUE = '1')
	  select @opt_UseLocalPrmInPrc = 1
	else
	  select @opt_UseLocalPrmInPrc = 0

    /* 按照供货单位确定单据类型，@style1:
        1   本店
        2   配供
        3   供应商
		4	其他门店    */
    if @m_provider = @usergid
        select @style1 = 1
    else
    begin
        if not exists(select 1 from STORE where GID = @m_provider)
            select @style1 = 3
        else if exists(select 1 from STORE where GID = @m_provider and PROPERTY >= 8)
            select @style1 = 2
		else
			select @style1 = 4
    end

    /* 将单据状态置为已审核 */
    update RTL set STAT = 1,  FILDATE = getdate() where NUM = @p_num  /*2001-06-06*/

    /* 生成提货单汇总 */
    if @gendsp = 1 and @style1 in (1, 3)  /*2005-8-6*/
    begin
        select @dsp_num = null
        select @max_dsp_num = max(NUM) from DSP
        if @max_dsp_num is null
            select @dsp_num = '0000000001'
        else
            execute NEXTBN @max_dsp_num, @dsp_num output
        select @dspwrhgid = GID from WAREHOUSE(nolock) where CODE = @m_dspwrh
        insert into DSP (
            NUM, WRH, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER, OPENER,
            LSTDSPTIME, LSTDSPEMP, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO, SRC )
        values (@dsp_num, @dspwrhgid, @m_invno, getdate(), @m_total, @m_reccnt, @m_filler, @m_filler,
            null, null, 'RTL', '', @p_num, null, @cur_settleno, @usergid)
    end

    if @style1 in (2, 4)  /*2005-8-6*/
    begin
        /* 生成配货进货单 */
        select @in_num = null
        select @max_in_num = max(NUM) from STKIN(nolock) where cls = '配货'
        if @max_in_num is null
            select @in_num = '0000000001'
        else
            execute NEXTBN @max_in_num, @in_num output
	/* hxs 2003.02.10 fifo*/
	INSERT INTO STKINDTL2(CLS,NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST)
		SELECT '配货',@IN_NUM,R.LINE,R.SUBWRH,R.WRH,R.GDGID,R.QTY,R.COST
		FROM RTLDTL2 R
		WHERE R.NUM = @P_NUM

        insert into STKINDTL(
            CLS, SETTLENO, NUM, LINE, GDGID,
            CASES, QTY, LOSS, PRICE, TOTAL,
            TAX, VALIDDATE, WRH, BCKQTY, PAYQTY,
            BCKAMT, PAYAMT, INPRC, RTLPRC, BNUM,
            SUBWRH)
        select
            '配货', @cur_settleno, @in_num, R.LINE, R.GDGID,
            R.CASES, R.QTY, 0, R.ALCPRC, convert(dec(20,2), R.ALCPRC * R.QTY),
            convert(dec(20,2), R.ALCPRC * R.QTY) - convert(dec(20,2), R.ALCPRC * R.QTY * 100 / (100 + G.SALETAX)),
            null, @m_wrh, 0, 0,
            0, 0, G.INPRC, G.RTLPRC, null,
            null
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID *= G.GID and R.NUM = @p_num and isnull(R.gftflag, 0) = 0
        select @m_alc_total = sum(convert(dec(20,2), isnull(R.ALCPRC,0) * R.QTY)),
            @m_alc_tax = sum(convert(dec(20,2), isnull(R.ALCPRC,0) * R.QTY) -
                convert(dec(20,2), isnull(R.ALCPRC,0) * R.QTY * 100 / (100 + G.SALETAX)))
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID = G.GID and R.NUM = @P_NUM and isnull(R.gftflag, 0) = 0
        insert into STKIN (
            CLS, NUM, ORDNUM, SETTLENO, VENDOR,
            VENDORNUM, BILLTO, OCRDATE, TOTAL, TAX,
            NOTE, FILDATE, PAYDATE, FINISHED, FILLER,
            CHECKER, STAT, MODNUM, PSR, RECCNT,
            SRC, SRCNUM, SNDTIME, PRNTIME, WRH,
            CHKDATE, VERIFIER, GEN, GENBILL, GENCLS,
            GENNUM)
        values(
            '配货', @in_num, '', @cur_settleno, @m_provider,
            '', @m_provider, getdate(), @m_alc_total, @m_alc_tax,
            '', getdate(), null, 0, @m_filler,
            @m_filler, 0, '', 1, @m_reccnt,
            @usergid, null, null, null, @m_wrh,
            getdate(), @m_filler, @usergid, 'RTL', null,
            @p_num)
        /*2005-8-25 Q4712,修正的配货进货单的审核由门店零售单修正存储过程负责调用*/
        if @m_modnum is null or @m_modnum = ''
        begin
            execute @ret_status = STKINCHK '配货', @in_num, 2
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货单审核失败。', 16, 1)
                return(1)
            end
        end
        UPDATE STKINDTL SET SUBWRH=R.SUBWRH FROM RTLDTL R, STKIN S
               WHERE STKINDTL.CLS = '配货' AND STKINDTL.NUM = @IN_NUM AND STKINDTL.LINE=R.LINE AND R.NUM=@P_NUM
                     AND STKINDTL.CLS=S.CLS AND STKINDTL.NUM=S.NUM AND S.GENBILL = 'RTL' AND S.GENNUM=@P_NUM
                     and isnull(R.gftflag, 0) = 0
    end
    else if @style1 = 3
    begin
        /* 生成直配进货单 */
        select @dir_num = null
        select @max_dir_num = max(NUM) from DIRALC(nolock) where cls = '直配进'
        if @max_dir_num is null
            select @dir_num = '0000000001'
        else
            execute NEXTBN @max_dir_num, @dir_num output
        insert into DIRALCDTL(
            CLS, NUM, LINE, SETTLENO, GDGID,
            WRH, CASES, QTY, LOSS, PRICE,
            TOTAL, TAX, ALCPRC, ALCAMT, WSPRC,
            INPRC, RTLPRC, VALIDDATE, BCKQTY, PAYQTY,
            BCKAMT, PAYAMT, BNUM, SUBWRH)
        select
        
        --Edited by ShenMin, Q5348, 门店零售单生成直配单取价格
            '直配进', @dir_num, R.LINE, @cur_settleno, R.GDGID,
            @m_wrh, R.CASES, R.QTY, 0, case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END, 
            convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY ELSE R.INPRICE * R.QTY END),
            convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY ELSE R.INPRICE * R.QTY END) - convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY * 100 / (100 + G.SALETAX) ELSE R.INPRICE * R.QTY * 100 / (100 + G.SALETAX) END),
            case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.ALCPRC END, convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY ELSE R.ALCPRC * R.QTY END), G.WHSPRC,
            G.INPRC, G.RTLPRC, null, 0, 0,
            0, 0, '', R.SUBWRH
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID *= G.GID and R.NUM = @p_num and isnull(R.gftflag, 0) = 0
        select @m_in_total = sum(convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END,0) * R.QTY)), 
            @m_in_tax = sum(convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END,0) * R.QTY) - convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END,0) * R.QTY * 100 / (100 + G.SALETAX))),
            @m_alc_total = sum(convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.ALCPRC END,0) * R.QTY))
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID = G.GID and isnull(R.gftflag, 0) = 0
            
        insert into DIRALC (
            CLS, NUM, ORDNUM, SETTLENO, VENDOR,
            SENDER, RECEIVER, OCRDATE, PSR, TOTAL,
            TAX, ALCTOTAL, STAT, SRC, SRCNUM,
            SRCORDNUM, SNDTIME, NOTE, RECCNT, FILLER,
            CHECKER, MODNUM, VENDORNUM, FILDATE, FINISHED,
            PRNTIME, CHKDATE, WRH, GEN, GENBILL,
            GENCLS, GENNUM)
        values (
            '直配进', @dir_num, '', @cur_settleno, @m_provider,
            @m_sender, @usergid, getdate(), 1, @m_in_total,
            @m_in_tax, @m_alc_total, 0, @usergid, null,
            null, null, null, @m_reccnt, @m_filler,
            @m_filler, null, null, getdate(), 0,
            null, getdate(), @m_wrh, @usergid, 'RTL',
            null, @p_num)
        /*2005-8-25 Q4712,修正的直配进货单的审核由门店零售单修正存储过程负责调用*/
        if @m_modnum is null or @m_modnum = ''
        begin
            execute @ret_status = DIRCHK '直配进', @dir_num, 2, 1
            if @ret_status <> 0
            begin
                raiserror('对应的直配进货单审核失败。', 16, 1)
                return(1)
            end
        end
    end
    
    /* 按照供货单位确定单据类型，@style2:
        1   本店
        2   配供
        3   供应商
		4	其他门店    */
    if @m_gftpro = @usergid
        select @style2 = 1
    else
    begin
        if not exists(select 1 from STORE where GID = @m_gftpro)
            select @style2 = 3
        else if exists(select 1 from STORE where GID = @m_gftpro and PROPERTY >= 8)
            select @style2 = 2
		else
			select @style2 = 4
    end

    /* 生成提货单汇总 */
    if @gendsp = 1 and @style2 in (1, 3)  /*2005-8-6*/
    begin
        select @dsp_num2 = null
        select @max_dsp_num = max(NUM) from DSP
        if @max_dsp_num is null
            select @dsp_num2 = '0000000001'
        else
            execute NEXTBN @max_dsp_num, @dsp_num2 output
        insert into DSP (
            NUM, WRH, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER, OPENER,
            LSTDSPTIME, LSTDSPEMP, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO, SRC )
        values (@dsp_num2, @m_gftprowrh, @m_invno, getdate(), 0, @m_gftreccnt, @m_filler, @m_filler,
            null, null, 'RTL', '', @p_num, null, @cur_settleno, @usergid)
    end

    if @style2 in (2, 4)  /*2005-8-6*/
    begin
        /* 生成配货进货单 */
        select @in_num2 = null
        select @max_in_num = max(NUM) from STKIN(nolock) where cls = '配货'
        if @max_in_num is null
            select @in_num2 = '0000000001'
        else
            execute NEXTBN @max_in_num, @in_num2 output
	
        insert into STKINDTL(
            CLS, SETTLENO, NUM, LINE, GDGID,
            CASES, QTY, LOSS, PRICE, TOTAL,
            TAX, VALIDDATE, WRH, BCKQTY, PAYQTY,
            BCKAMT, PAYAMT, INPRC, RTLPRC, BNUM,
            SUBWRH)
        select
            '配货', @cur_settleno, @in_num2, R.LINE, R.GDGID,
            R.CASES, R.QTY, 0, R.ALCPRC, convert(dec(20,2), R.ALCPRC * R.QTY),
            convert(dec(20,2), R.ALCPRC * R.QTY) - convert(dec(20,2), R.ALCPRC * R.QTY * 100 / (100 + G.SALETAX)),
            null, @m_gftprowrh, 0, 0,
            0, 0, G.INPRC, G.RTLPRC, null,
            null
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID *= G.GID and R.NUM = @p_num and isnull(R.gftflag, 0) = 1
        select @m_alc_total = sum(convert(dec(20,2), isnull(R.ALCPRC,0) * R.QTY)),
            @m_alc_tax = sum(convert(dec(20,2), isnull(R.ALCPRC,0) * R.QTY) -
                convert(dec(20,2), isnull(R.ALCPRC,0) * R.QTY * 100 / (100 + G.SALETAX)))
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID = G.GID and R.NUM = @P_NUM and isnull(R.gftflag, 0) = 1
        insert into STKIN (
            CLS, NUM, ORDNUM, SETTLENO, VENDOR,
            VENDORNUM, BILLTO, OCRDATE, TOTAL, TAX,
            NOTE, FILDATE, PAYDATE, FINISHED, FILLER,
            CHECKER, STAT, MODNUM, PSR, RECCNT,
            SRC, SRCNUM, SNDTIME, PRNTIME, WRH,
            CHKDATE, VERIFIER, GEN, GENBILL, GENCLS,
            GENNUM)
        values(
            '配货', @in_num2, '', @cur_settleno, @m_gftpro,
            '', @m_gftpro, getdate(), @m_alc_total, @m_alc_tax,
            '', getdate(), null, 0, @m_filler,
            @m_filler, 0, '', 1, @m_gftreccnt,
            @usergid, null, null, null, @m_gftprowrh,
            getdate(), @m_filler, @usergid, 'RTL', null,
            @p_num)
        /*2005-8-25 Q4712,修正的配货进货单的审核由门店零售单修正存储过程负责调用*/
        if @m_modnum is null or @m_modnum = ''
        begin
            execute @ret_status = STKINCHK '配货', @in_num2, 2
            if @ret_status <> 0
            begin
                raiserror('对应的配货进货单审核失败。', 16, 1)
                return(1)
            end
        end
        UPDATE STKINDTL SET SUBWRH=R.SUBWRH FROM RTLDTL R, STKIN S
               WHERE STKINDTL.CLS = '配货' AND STKINDTL.NUM = @IN_NUM2 AND STKINDTL.LINE=R.LINE AND R.NUM=@P_NUM
                     AND STKINDTL.CLS=S.CLS AND STKINDTL.NUM=S.NUM AND S.GENBILL = 'RTL' AND S.GENNUM=@P_NUM 
                     and isnull(R.gftflag, 0) = 1 
    end
    else if @style2 = 3
    begin
        /* 生成直配进货单 */
        select @dir_num2 = null
        select @max_dir_num = max(NUM) from DIRALC(nolock) where cls = '直配进'
        if @max_dir_num is null
            select @dir_num2 = '0000000001'
        else
            execute NEXTBN @max_dir_num, @dir_num2 output
        insert into DIRALCDTL(
            CLS, NUM, LINE, SETTLENO, GDGID,
            WRH, CASES, QTY, LOSS, PRICE,
            TOTAL, TAX, ALCPRC, ALCAMT, WSPRC,
            INPRC, RTLPRC, VALIDDATE, BCKQTY, PAYQTY,
            BCKAMT, PAYAMT, BNUM, SUBWRH)
        select
        
        --Edited by ShenMin, Q5348, 门店零售单生成直配单取价格
            '直配进', @dir_num2, R.LINE, @cur_settleno, R.GDGID,
            @m_gftprowrh, R.CASES, R.QTY, 0, case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END, 
            convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY ELSE R.INPRICE * R.QTY END),
            convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY ELSE R.INPRICE * R.QTY END) - convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY * 100 / (100 + G.SALETAX) ELSE R.INPRICE * R.QTY * 100 / (100 + G.SALETAX) END),
            case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.ALCPRC END, convert(dec(20,2), case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 * R.QTY ELSE R.ALCPRC * R.QTY END), G.WHSPRC,
            G.INPRC, G.RTLPRC, null, 0, 0,
            0, 0, '', R.SUBWRH
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID *= G.GID and R.NUM = @p_num and isnull(R.gftflag, 0) = 1
        select @m_in_total = sum(convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END,0) * R.QTY)), 
            @m_in_tax = sum(convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END,0) * R.QTY) - convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.INPRICE END,0) * R.QTY * 100 / (100 + G.SALETAX))),
            @m_alc_total = sum(convert(dec(20,2), isnull(case WHEN G.SALE = 3 THEN R.PRICE * G.PAYRATE/100 ELSE R.ALCPRC END,0) * R.QTY))
            from RTLDTL R, GOODSH G(nolock)
            where R.GDGID = G.GID and isnull(R.gftflag, 0) = 1
            
        insert into DIRALC (
            CLS, NUM, ORDNUM, SETTLENO, VENDOR,
            SENDER, RECEIVER, OCRDATE, PSR, TOTAL,
            TAX, ALCTOTAL, STAT, SRC, SRCNUM,
            SRCORDNUM, SNDTIME, NOTE, RECCNT, FILLER,
            CHECKER, MODNUM, VENDORNUM, FILDATE, FINISHED,
            PRNTIME, CHKDATE, WRH, GEN, GENBILL,
            GENCLS, GENNUM)
        values (
            '直配进', @dir_num2, '', @cur_settleno, @m_gftpro,
            @m_sender, @usergid, getdate(), 1, @m_in_total,
            @m_in_tax, @m_alc_total, 0, @usergid, null,
            null, null, null, @m_gftreccnt, @m_filler,
            @m_filler, null, null, getdate(), 0,
            null, getdate(), @m_gftprowrh, @usergid, 'RTL',
            null, @p_num)
        /*2005-8-25 Q4712,修正的直配进货单的审核由门店零售单修正存储过程负责调用*/
        if @m_modnum is null or @m_modnum = ''
        begin
            execute @ret_status = DIRCHK '直配进', @dir_num2, 2, 1
            if @ret_status <> 0
            begin
                raiserror('对应的直配进货单审核失败。', 16, 1)
                return(1)
            end
        end
    end

    if @ret_status = 0
    begin
        /* 逐条处理单据明细 */
        declare c_rtlchk cursor for
            select LINE, GDGID, CASES, QTY, PRICE,
                DISCOUNT, INPRICE, ALCPRC, AMOUNT, SUBWRH,
                DSPSUBWRH,COST, RTLPRC, ISNULL(BLUECARDCOST, 0), isnull(gftflag, 0), IsNull(RedCardCost, 0) /*HXS 2003.02.10*/   --RTLPRC Added by ShenMin
            from RTLDTL
            where NUM = @p_num
            for update
        open c_rtlchk
        fetch next from c_rtlchk into
            @d_line, @d_gdgid, @d_cases, @d_qty, @d_price,
            @d_discount, @d_inprice, @d_alcprc, @d_amount, @d_subwrh,
            @d_dspsubwrh,@D_COST, @rtlprc, @d_blueCardCost, @gftflag,@d_RedCardCost   --@rtlprc Added by ShenMin
        while @@fetch_status = 0
        begin
			/*HXS 2003.02.10如果是本地销售则需要处理批次出库*/
			if @gftflag = 1 set @STYLE = @STYLE2 
			else set @STYLE = @STYLE1
			if @gftflag = 0 
			  set @M_WRHS = @M_WRH
			else
			  set @M_WRHS = @M_GFTPROWRH
			IF (@STYLE = 1) AND ((SELECT BATCHFLAG FROM SYSTEM) = 2)
			BEGIN
        		EXEC @RETURN_STATUS = RTLCHKFIFO  @P_NUM,@D_LINE,@M_WRHS,@D_GDGID,
				  @D_QTY, @D_COST OUTPUT
			    IF @RETURN_STATUS <> 0 BREAK
			END

			/*2005-8-23 V1版零售单成本算法
			代销的本地商品：首先取促销进价额，没有再取本地成本。
			代销的总部商品受模块282系统选项"IsAllowModLocalCost3"控制：
				1:取总部配出成本
				0:首先取促销进价额，没有再取本地成本。
				其他:等同0的处理
			联销商品根据联销率计算成本。
    		        联销商品如果使用红蓝卡  成本＝（实收金额＋红卡＋蓝卡）× 联销率 — 蓝卡
			经销的本地商品受模块282系统选项"IsAllowModLocalCost1"控制：
				其他:销售取本地成本。
			经销的总部商品受模块282系统选项"IsAllowModLocalCost1"控制：
				1:进货不加权平均，销售取总部配货价做成本。
				0:进货要加权平均，销售取本地成本。
				其他:等同0的处理
			*/
			select @curtime = getdate()
			/*首先取出本地成本价*/
			select @g_inprc = INPRC, @g_rtlprc = RTLPRC, @g_whsprc = WHSPRC,
				@g_vdr = BILLTO, @g_taxrate = SALETAX, @g_sale = sale  /*2001-06-05*/
				from GOODSH(nolock) where GID = @d_gdgid
			/* 00-3-6 INPRC从货位中取 */
			if (select outinprcmode from system) = 1 and @g_sale <> 3
				select @g_inprc = lstinprc from subwrhinv where gdgid = @d_gdgid and subwrh = @d_subwrh

			if @g_sale = 2  /*代销商品处理*/
			begin
				if (@style in (2, 4) and @op_usezbinprc2 = 1) or (@style = 3 and @op_usezbalcprc2 = 1)  /*2005-8-23*/
					select @g_inprc = @d_alcprc
				else
				begin
					select @gdinprc = @g_inprc
						execute @return_status=GetGoodsPrmInprc @usergid, @d_gdgid, @curtime, @d_qty, @g_inprc output
					if @return_status <> 0
						select @g_inprc = @gdinprc
				end
			end
			else if @g_sale = 3  /*联销商品处理*/
			begin
				select @g_inprc = @d_price * payrate / 100,  @g_payRate = payrate
					from goodsh(nolock) where gid = @d_gdgid
			end
			else if @style = 1  /*本地经销商品处理*/
			begin
			    select @gdinprc = @g_inprc
			    --2006.04.18 added by wangxin 增加对销售本地库存的经销商品是否取促销进价
			    if @opt_UseLocalPrmInPrc = 1 
			    begin
    			    execute @return_status=GetGoodsPrmInprc @usergid, @d_gdgid, @curtime, @d_qty, @g_inprc output
    				if @return_status <> 0
    				  select @g_inprc = @gdinprc
    				else
    				  select @gdinprc = @g_inprc	
    		    end			
			end
			else if @style = 3  /*供应商经销商品处理*/
			begin
				if @op_usezbalcprc = 1
					select @g_inprc = @d_alcprc
			end
			else if @style in (2, 4)  /*总部经销商品处理*/
			begin
                if @op_usezbinprc = 1
					select @g_inprc = @d_alcprc
			end

			if (select batchflag from system) = 1
				if @style in (2, 4)  /*2005-8-6*/
				begin
					if @gftflag = 0 
					  select @d_subwrh = SUBWRH from STKINDTL where CLS = '配货' and NUM = @in_num and gdgid = @d_gdgid
					else
					  select @d_subwrh = SUBWRH from STKINDTL where CLS = '配货' and NUM = @in_num2 and gdgid = @d_gdgid
			    end
				else if @style = 3
				begin
					if @gftflag = 0 
					  select @d_subwrh = DIRALCDTL.SUBWRH, @d_dspsubwrh = SUBWRH.CODE from DIRALCDTL, SUBWRH
						where DIRALCDTL.CLS = '直配进' and DIRALCDTL.NUM = @dir_num and DIRALCDTL.gdgid = @d_gdgid
						and DIRALCDTL.SUBWRH = SUBWRH.GID
				    else
				      select @d_subwrh = DIRALCDTL.SUBWRH, @d_dspsubwrh = SUBWRH.CODE from DIRALCDTL, SUBWRH
						where DIRALCDTL.CLS = '直配进' and DIRALCDTL.NUM = @dir_num2 and DIRALCDTL.gdgid = @d_gdgid
						and DIRALCDTL.SUBWRH = SUBWRH.GID
			    end

            -- Q6307: 需要记录当前商品核算价
            -- Zhou Rong, 2006-03-15
          /*  DECLARE @curInPrc DECIMAL;
            SELECT @curInPrc = g.InPrc FROM Goods AS g, RtlDtl AS r WHERE g.GID = r.GDGID AND r.NUM = @p_num;
          */  --Deleted by ShenMin
            update RTLDTL set
                RTLPRC = @g_rtlprc, INPRC = @g_inprc, COST = @d_qty * @g_inprc/*2005-8-23*/,
                SUBWRH = @d_subwrh, DSPSUBWRH = @d_dspsubwrh
                --CURINPRC = @curInPrc        -- Q6307 --Deleted by ShenMin
                where NUM = @p_num and LINE = @d_line and isnull(gftflag, 0) = 0
            -- End Q6307

			/*对批次库存的处理只有在BATCHFLAT不等于２的情况下进行,HXS 2003.02.10*/
			IF (SELECT BATCHFLAG FROM SYSTEM) <> 2
			BEGIN
				/* 库存 */
				if @d_subwrh is not null-- and (select DSP from SYSTEM) & 16 = 16
				begin
					execute @ret_status = UNLOADSUBWRH @m_wrhS, @d_subwrh, @d_gdgid, @d_qty
					if @ret_status <> 0 break
				end
			END

            execute @ret_status = UNLOAD @m_wrhS, @d_gdgid, @d_qty, @g_rtlprc, null
            
            if @ret_status <> 0
            begin
                select @msg = ' 不允许负库存或实行到效期管理的仓位库存不足:' +
                    rtrim(convert(char,@m_wrhS)) + ';' +
                    rtrim(convert(char,@d_gdgid)) + ';' +
                    rtrim(convert(char, @d_qty)) + ';' +
                    rtrim(convert(char,@d_price))
                raiserror(@msg, 16, 1)
                break
            end

            /* 生成提货单明细 */
            if @gendsp = 1 and @style in (1, 3)  /*2005-8-6*/
            begin
				select @dspsubwrhgid = GID from SUBWRH(nolock) where CODE = @d_dspsubwrh
				if @gftflag = 0  
				BEGIN                 
                  select @maxline = line + 1 from DSPDTL where NUM = @dsp_num
                  set @maxline = isnull(@maxline, 1)
                  insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
                    SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE, SUBWRH)
                  values (@dsp_num, @maxline, @d_line, @d_gdgid, @d_amount/@d_qty, @d_qty,
                    @d_amount, 0, 0, 0, null, @dspsubwrhgid )
                  execute IncDspQty @dspwrhgid, @d_gdgid, @d_qty, @dspsubwrhgid
                END else BEGIN
                  select @maxline = line + 1 from DSPDTL where NUM = @dsp_num2
                  set @maxline = isnull(@maxline, 1)
                  insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
                    SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE, SUBWRH)
                  values (@dsp_num2, @maxline, @d_line, @d_gdgid, @d_amount/@d_qty, @d_qty,
                    @d_amount, 0, 0, 0, null, @dspsubwrhgid )
                  execute IncDspQty @dspwrhgid, @d_gdgid, @d_qty, @dspsubwrhgid
                END
            end

            /* 单据审核 */
            select @d_tax = @d_amount - convert(dec(20,2), @d_amount * 100 / (100 + @g_taxrate))
            
            --ShenMin
	              /*将优惠金额作为后台优惠记入报表*/	    
	                set @favamt = @rtlprc * @d_qty - @d_amount
            
			/*HXS 2003.02.10 FIFO*/
			IF (SELECT BATCHFLAG FROM SYSTEM) = 2
			BEGIN
			    if (@favamt <> 0) and ((select PRCTYPE from GOODSH where gid = @D_GDGID) <> 1)--ShenMin, 2005.11.10, 可变价商品不记录优惠额
			      begin	
				INSERT INTO XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
				BVDRGID, BCSTGID,PARAM,
				LS_Q, LS_A, LS_T, LS_I, LS_R, LS1_Q, LS1_A)
				VALUES (@CUR_SETTLENO, @CUR_DATE,
				@M_WRHS, @D_GDGID, 1, @G_VDR, 1, 0,
				@D_QTY, @D_AMOUNT - @D_TAX, @D_TAX,
				@D_COST, @D_QTY * @G_RTLPRC, @d_qty, @favamt)
			      end
			    else
			      begin
			        INSERT INTO XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
				BVDRGID, BCSTGID,PARAM,
				LS_Q, LS_A, LS_T, LS_I, LS_R)
				VALUES (@CUR_SETTLENO, @CUR_DATE,
				@M_WRHS, @D_GDGID, 1, @G_VDR, 1, 0,
				@D_QTY, @D_AMOUNT - @D_TAX, @D_TAX,
				@D_COST, @D_QTY * @G_RTLPRC)
			      end  
			END
			ELSE
			BEGIN
			    if (@favamt <> 0) and ((select PRCTYPE from GOODSH where gid = @D_GDGID) <> 1)--ShenMin, 2005.11.10, 可变价商品不记录优惠额
			      begin
			      	if @g_sale = 3 ---tianlei add
			      	begin
                                   insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
				        BVDRGID, BCSTGID,PARAM,  /*2001-04-27*/
				        LS_Q, LS_A, LS_T, LS_I, LS_R, LS1_Q, LS1_A)
				        values (@cur_settleno, @cur_date/*2001-06-06 convert(datetime, convert(char, @m_fildate, 102))*/,
				        @m_wrh, @d_gdgid, 1, @g_vdr, 1, 0,
				        @d_qty, @d_amount - @d_tax, @d_tax,
				        (@d_amount + @d_blueCardCost + @d_RedCardCost)* @g_PayRate/100 - @d_blueCardCost, @d_qty * @g_rtlprc, @d_qty, @favamt)			      		
			      	end
			        else begin			        	
				        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
				        BVDRGID, BCSTGID,PARAM,  /*2001-04-27*/
				        LS_Q, LS_A, LS_T, LS_I, LS_R, LS1_Q, LS1_A)
				        values (@cur_settleno, @cur_date/*2001-06-06 convert(datetime, convert(char, @m_fildate, 102))*/,
				        @m_wrh, @d_gdgid, 1, @g_vdr, 1, 0,
				        @d_qty, @d_amount - @d_tax, @d_tax,
				        @d_qty * @g_inprc - @d_blueCardCost, @d_qty * @g_rtlprc, @d_qty, @favamt)
			       end
			     end
			    else
			      begin
			      	if @g_sale = 3 ---tianlei add
			      	begin
  			        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
	   			                      BVDRGID, BCSTGID,PARAM,  /*2001-04-27*/
				                        LS_Q, LS_A, LS_T, LS_I, LS_R)
				        values (@cur_settleno, @cur_date/*2001-06-06 convert(datetime, convert(char, @m_fildate, 102))*/,
				                @m_wrh, @d_gdgid, 1, @g_vdr, 1, 0,
				                @d_qty, @d_amount - @d_tax, @d_tax,
				                (@d_amount + @d_blueCardCost + @d_RedCardCost)* @g_PayRate/100 - @d_blueCardCost, @d_qty * @g_rtlprc)			      		
			        end else
			      	begin
			          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BSLRGID,
				                        BVDRGID, BCSTGID,PARAM,  /*2001-04-27*/
				                        LS_Q, LS_A, LS_T, LS_I, LS_R)
				        values (@cur_settleno, @cur_date/*2001-06-06 convert(datetime, convert(char, @m_fildate, 102))*/,
				          @m_wrh, @d_gdgid, 1, @g_vdr, 1, 0,
				          @d_qty, @d_amount - @d_tax, @d_tax,
				          @d_qty * @g_inprc - @d_blueCardCost, @d_qty * @g_rtlprc)
			        end
			   end
			END
	
			/*代销商品若进行促销进价促销，生成调价差异 2001-06-05*/
			if @g_sale = 2 or (@g_sale = 3 /*2005.08.03*/ )
			begin
				select @gdinprc = inprc from goodsh(nolock) where gid = @d_gdgid
				if @g_inprc <> @gdinprc
				begin
				  if (@g_sale = 2) 
				  begin 
					  insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
					  values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
					  @g_inprc * @d_qty - @d_blueCardCost - @gdinprc * @d_qty)
					end else
					begin	
						if (@d_BlueCardCost <> 0) or (@d_RedCardCost <> 0)  						
					    insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
					     values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
					     (@d_amount + @d_blueCardCost + @d_RedCardCost)* @g_PayRate/100 - @d_blueCardCost - @gdinprc * @d_qty)						  
					  else
  					  insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
	   				  values (@cur_settleno, @cur_date, @d_gdgid, @m_wrh,
			   		  @g_inprc * @d_qty - @gdinprc * @d_qty)					  	
					end  
			  end		

			end
			
			/*经销商品若进行促销进价促销，生成调价差异 ShenMin, Q6411*/
			if @g_sale = 1 and @style = 1 and @opt_UseLocalPrmInPrc = 1
			begin
				select @gdinprc = inprc from goodsh(nolock)/*2005-8-19*/ where gid = @d_gdgid
				if @g_inprc <> @gdinprc
					insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
					values (@cur_settleno, @cur_date, @d_gdgid, @m_wrhS,
					@g_inprc * @d_qty - @d_blueCardCost - @gdinprc * @d_qty)
			end		

                  /*存在红蓝卡*/
                 --yzk0928    
      -- if @g_sale = 1 and (not @style = 1 and @opt_UseLocalPrmInPrc = 1) and (@d_blueCardCost <> 0)    
      --if @g_sale = 1 and  @opt_UseLocalPrmInPrc = 1 and (@d_blueCardCost <> 0)    
      --经销商品只要使用蓝卡，就要进行调整
      if @g_sale = 1 and  (@d_blueCardCost <> 0)    
			begin
				select @gdinprc = inprc from goodsh(nolock) where gid = @d_gdgid
				-- if @g_inprc <> @gdinprc
					insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
					values (@cur_settleno, @cur_date, @d_gdgid, @m_wrhS,
					@g_inprc * @d_qty - @d_blueCardCost - @gdinprc * @d_qty)
			end		            
                    
			fetch next from c_rtlchk into
				@d_line, @d_gdgid, @d_cases, @d_qty, @d_price,
				@d_discount, @d_inprice, @d_alcprc, @d_amount, @d_subwrh,
				@d_dspsubwrh,@D_COST, @rtlprc, @d_blueCardCost, @GFTFLAG, @d_RedCardCost
		end
		close c_rtlchk
        deallocate c_rtlchk
    end

    return(@ret_status)
end
GO
