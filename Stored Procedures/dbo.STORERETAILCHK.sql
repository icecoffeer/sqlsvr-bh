SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STORERETAILCHK](
  @num char(14),
  @cls char(10),
  @oper varchar(30),
  @ToStat smallInt,
  @Msg varchar(200) output
) with encryption as
begin
  declare
    @posno varchar(10),
    @cstgid int, /* 客户的GID */
    @settleno int,
    @date datetime,
    @itemno smallint,
    @gdgid int,
    @qty money,
    @inprc money,
    @rtlprc money,
    @realamt money,
    @favamt money, @favamt_saved money,
    @wrh int,
    @wrh1 int,
    @wrh2 int,
    @slrgid int,
    @amt money,
    @g_inprc money,
    @g_rtlprc money,
    @return_status int,
    @store int,
    @ReCalcInPrcTag int
  declare
    @temp1 smallint,
    @temp2 money,
    @temp3 money,
    @payrate money,
    @vdrgid int,
    @fildate datetime,
    @total_favamt money,
    @total_gdcnt money
  declare
    @temp money,
    @outcost money,
    @g_payrate money
  declare
    @param int


  declare
    @filler varchar(100),
    @opener int,
    @sale smallint,
    @reccnt int,
    @stat int,
    @DBName varchar(10)

  if not exists(select * from STORERETAIL where NUM = @num and CLS = @cls)
  begin
  	select @Msg = '不存在要批准的门店零售单'
  	return(1)
  end

  select @stat = STAT from STORERETAIL where NUM = @num and CLS = @cls
  if @stat = 0 and (@tostat <> 3400 and @tostat <> 3500)
  begin
      select @Msg = '单据状态不合法'
      return(1)
  end

  if @stat = 3500 and (@tostat <> 3400 and @tostat <> 3510 and @tostat <> 3520)
  begin
    select @Msg = '已交定金的门店零售单据状态只能批准或取消'
      return(1)
  end

  if @tostat = 3500
    update STORERETAIL set STAT = @toStat,LSTUPDTIME = getdate(), LASTMODIFIER = @oper
    where NUM = @num and CLS = @cls
  else
    update STORERETAIL set STAT = @toStat, SELLERAPPROVER = @oper, SellerApproveTime = isnull(SellerApproveTime, getdate()),
      LSTUPDTIME = getdate(), LASTMODIFIER = @oper
    where NUM = @num and CLS = @cls
  exec STORERETAILADDLOG @NUM, @CLS, @TOSTAT, '', @OPER

  if @toStat = 3500  or @tostat = 3510 or @tostat = 3520
    return 0
  Declare @DealWithInPrc int
  Exec OptReadInt 0, 'DealWithInPrc', 0, @DealWithInPrc output
  /* processing */
    select @return_status = 0
    select @cstgid = 1
    select
      @fildate = convert(datetime, convert(char,SellerApproveTime,102)),
      @wrh1 = SELLERWRH,
      @posno = POSNO,
      @realamt = TOTAL,
      @reccnt = RECCNT,
      @filler = FILLER,
      @settleno = settleno
      from STORERETAIL where NUM = @NUM and CLS = @CLS

      select @DBName = DB_NAME()
      exec @return_status = master..xp_PosLic @DBName, @posno
      if (@return_status <> 0) or (select rtlproc from workstation where no = @posno and style = 0 ) <> 1
      begin
        select @msg = '收银机注册不合法'
        return(@return_status)
      end

     if @slrgid is null select @slrgid = 1
     select @amt = 0, @total_favamt = 0, @total_gdcnt = 0
     select @param = 0
    declare c_SRDtl cursor for
      select LINE, GDGID, BUYERORDERQTY, INPRC, PRICE, TOTAL, FAVAMT,
             SELLERASSISTANT, SenderWRH, ReCalcInPrcTag
      from STORERETAILDTL
      where NUM = @NUM and CLS = @CLS
      order by SELLERASSISTANT, SENDERWRH
    open c_SRDtl
    fetch next from c_SRDtl into
      @ITEMNO, @gdgid, @qty, @inprc, @rtlprc, @realamt, @favamt,
      @opener, @wrh2, @ReCalcInPrcTag
    while @@fetch_status = 0
    begin
      if @wrh2 is null or @wrh2 in (0,1) select @wrh2 = @wrh1
      select @sale = null
      select @sale = SALE,
        @g_inprc = INPRC, @g_rtlprc = RTLPRC, @g_payrate = PAYRATE
        from GOODS where GID = @gdgid

      if @sale is null
      begin
        select @msg = '第' + rtrim(convert(char,@itemno)) +
                      '行的商品不存在(GID=' +
                      rtrim(convert(char,@gdgid)) + ')'
        select @return_status = 1
        break
      end

      select @store = usergid from system
      declare
	  @poMsg varchar(1000),
	  @curdate datetime
      if @sale = 3
      begin
                ------取促销联销率
          select @curdate = FILDATE from STORERETAIL(NOLOCK) where NUM = @NUM and CLS = @cls
          execute @return_status = GetGoodsPrmPayRate @store, @gdgid, @curdate, '1*1', @PayRate output, @poMsg output
          if @return_status = 0
            select @g_payrate = @payRate
          else
            select @payrate = @g_payrate
          select @inprc = @realamt * @g_payrate / 100 / @qty
          select @g_inprc = @inprc
          update STORERETAILDTL set INPRC = @inprc
            where NUM = @NUM and CLS = @CLS and LINE = @itemno
      end
      else if @sale = 1
      begin
        if @DealWithInPrc = 1
        begin
          update STORERETAILDTL set inprc = @inprc
          where NUM = @NUM and CLS = @CLS and LINE = @itemno
        end
        else
        begin
          select @inprc = @g_inprc
          update STORERETAILDTL set inprc = @inprc
          where NUM = @NUM and CLS = @CLS and LINE = @itemno
        end
      end

      if @wrh2 is null or @wrh2 = 1
        select @wrh = WRH from GOODS where GID = @gdgid
      else
        select @wrh = @wrh2


      if @sale <> 0
      begin
        if @sale = 1
        begin
          select @inprc = @g_inprc
          update STORERETAILDTL set INPRC = @inprc
            where NUM = @NUM and CLS = @CLS and LINE = @itemno
        end
        select @temp = @qty * @inprc
        execute UPDINVPRC '零售', @gdgid, @qty, @temp, @wrh, @outcost output
        if @sale = 1
            update STORERETAILDTL set COST = @outcost
              where NUM = @NUM and CLS = @CLS and LINE = @itemno
        else
            update STORERETAILDTL set COST = @temp
              where NUM = @NUM and CLS = @CLS and LINE = @itemno
      end

      if @qty > 0 begin
        select @temp2 = @qty
        execute @return_status = UNLOAD @wrh, @gdgid, @temp2, @g_rtlprc, null
      end else begin
        select @temp2 = -@qty
        execute @return_status = LOADIN @wrh, @gdgid, @temp2, @g_rtlprc, null
      end
      if @return_status <> 0 begin
        select @msg = ' 不允许负库存或实行到效期管理的仓位库存不足:' +
          rtrim(convert(char,@wrh)) + ';' +
          rtrim(convert(char,@gdgid)) + ';' +
          ltrim(convert(char, @qty)) + ';' +
          ltrim(convert(char,@rtlprc))
        break
      end

      /* 销售报表 */
      select @vdrgid = BILLTO from GOODSH where GID = @gdgid
      if (@sale = 1)
      begin
        if @realamt > 0 begin
        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
          @vdrgid, @cstgid,
          @qty, @realamt, 0, isnull(@outcost, @qty * @inprc), @qty * @rtlprc, @param)
        end else begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
          @vdrgid, @cstgid,
          @qty, @realamt, 0, isnull(@outcost, @qty * @inprc), @qty * @rtlprc, @param)
        end
      end
      else if @sale = 2 /*代销*/
        begin
        if @realamt > 0 begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
          @vdrgid, @cstgid,
          @qty, @realamt, 0, @qty * @inprc, @qty * @rtlprc, @param)
        end
        else begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
          @vdrgid, @cstgid,
          @qty, @realamt, 0, @qty * @inprc, @qty * @rtlprc, @param)
        end
      end
      else
      begin
        if @realamt > 0 begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
          @vdrgid, @cstgid,
          @qty, @realamt, 0, @realamt * @payrate / 100, @qty * @rtlprc, @param)
        end else begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
          @vdrgid, @cstgid,
          @qty, @realamt, 0, @realamt * @payrate / 100, @qty * @rtlprc, @param)
        end
      end
      if @@error <> 0 begin
        select @msg = 'XS:' +
          rtrim(convert(char,@settleno)) + ';' +
          rtrim(convert(char,@fildate,2)) + ';' +
          rtrim(convert(char,@wrh)) + ';' +
          rtrim(convert(char,@gdgid)) + ';' +
          rtrim(convert(char, @posno)) + ';' +
          rtrim(convert(char,@slrgid)) + ';' +
          rtrim(convert(char,@vdrgid)) + ';' +
          rtrim(convert(char,@qty)) + ';' +
          rtrim(convert(char,@realamt)) + ';' +
          rtrim(convert(char,0)) + ';' +
          rtrim(convert(char,@qty * @inprc)) + ';' +
          rtrim(convert(char,@qty * @rtlprc))
        select @return_status = 1
        break
      end
      /* 优惠报表 */
      select @favamt_saved = @favamt

      if @favamt <> 0 begin
        /* LS1: 后台优惠 */
        select @favamt = sum(FAVAMT) from STORERETAILFAVDTL
          where NUM = @NUM and CLS = @CLS
          and ITEMNO = @itemno and FAVTYPE in ('00', '01','03','04','05','07','08', '11', '19', '20')
        if @favamt is not null and @favamt <> 0 begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS1_Q, LS1_A, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, @slrgid,
          @vdrgid,  @cstgid,
          @qty, @favamt, @param)
          if @@error <> 0 begin
            select @msg = 'XS:LS1:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char, @posno)) + ';' +
              rtrim(convert(char,@slrgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@qty)) + ';' +
              rtrim(convert(char,@favamt))
            select @return_status = 1
            break
          end
        end
        /* LS2：前台优惠 */
        select @favamt = sum(FAVAMT) from STORERETAILFAVDTL
          where NUM = @NUM and CLS = @CLS
          and ITEMNO = @itemno and (FAVTYPE in ('09','10','12','13')
          or FAVTYPE like '16__' or FAVTYPE like '24%')
      if @favamt is not null and @favamt <> 0 begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS2_Q, LS2_A, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, @slrgid,
          @vdrgid, @cstgid,
          @qty, @favamt, @PARAM)
          if @@error <> 0 begin
            select @msg = 'XS:LS2:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char, @posno)) + ';' +
              rtrim(convert(char,@slrgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@qty)) + ';' +
              rtrim(convert(char,@favamt))
            select @return_status = 1
            break
          end
        end
        /* LS3: 付款方式优惠 */
        select @favamt = sum(FAVAMT) from STORERETAILFAVDTL
          where NUM = @NUM and CLS = @CLS and ITEMNO = @itemno
          and (FAVTYPE like '15__' or FAVTYPE in ('14', '17'))
        if @favamt is not null and @favamt <> 0 begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LS3_Q, LS3_A, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, @slrgid,
          @vdrgid, @cstgid,
          @qty, @favamt, @PARAM)
          if @@error <> 0 begin
            select @msg = 'XS:LS3:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char, @posno)) + ';' +
              rtrim(convert(char,@slrgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@qty)) + ';' +
              rtrim(convert(char,@favamt))
            select @return_status = 1
            break
          end
        end
      end
      /* 调价差异 */
      if @g_rtlprc <> @rtlprc begin
        insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_R )
        values (@fildate, @settleno, @wrh, @gdgid, @qty, @qty*(@rtlprc-@g_rtlprc))
        if @@error <> 0 begin
          select @msg = '记录零售核算售价调价差异发生错误'
          select @return_status = 1
          break
        end
      end
      if @g_inprc <> @inprc
      begin
        if @DealWithInPrc = 1
        begin
          if @qty >= 0
            execute calcprmbanlan '零售', @settleno, @fildate, @gdgid, @wrh, @cstgid, @qty, @inprc, @g_inprc
        end
        else
        begin
          insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@fildate, @settleno, @wrh, @gdgid, @qty, @qty*(@inprc-@g_inprc))
        end
        if @@error <> 0 begin
          select @msg = '记录零售核算价调价差异发生错误'
          select @return_status = 1
          break
        end
      end
      select
        @amt = @amt + @realamt,
        @total_favamt = @total_favamt + @favamt_saved,
        @total_gdcnt = @total_gdcnt + @qty

      fetch next from c_SRDtl into
        @itemno, @gdgid, @qty, @inprc, @rtlprc, @realamt, @favamt,
        @opener, @wrh2, @ReCalcInPrcTag
    end
    close c_SRDtl
    deallocate c_SRDtl

    update WORKSTATION set
      CNT = CNT + 1,
      AMT = AMT + @amt
    where NO = @posno

    if @date = @fildate
      update WORKSTATION set
        TODAYCNT = TODAYCNT + 1,
        TODAYAMT = TODAYAMT + @amt
      where NO = @posno


   --复制到Buy
  exec @return_status = CopyToBuyFromSR @num, @cls, @msg
  return(@return_status)
end
GO
