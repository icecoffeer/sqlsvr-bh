SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINBCKCHK](
  @cls char(10),
  @num char(10),
  @mode smallint,
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) --with encryption
as
begin
  declare
    @return_status int,      @cur_date datetime,       @cur_settleno int,
    @wrh int,                @billto int,              @psr int,
    @stat smallint,          @gdgid int,               @qty money,
    @price money,            @total money,             @tax money,
    @inprc money,            @rtlprc money,            @validdate datetime,
    @line smallint,          @msg varchar(200),        @acnt smallint,
    @subwrh int,
    @m_wrh int,              @m_total money,          @m_reccnt int,
    @m_filler int,
    @gendsp int,             @dsp_num char(10),       @max_dsp_num char(10),
    @store int,              @d_cost money /*2002-06-13*/,
    @sale smallint,/*2003-06-13*/@ret int,   @outmsg varchar(255),
    @vendor int,             @genbill varchar(10),    @gennum varchar(14), /*2005-8-23*/
    @rtlbck_usezbinprc int  /*2005-8-23*/

    DECLARE @BCKDMDNUM char(14), @bckdmdstat int
    declare @OptBckDmdRepImp int, @BckdmdQty money, @BckedQty money, @BckQty money, @BckLine int, @OverDmdQtyCount int; --ShenMin

  declare @opt_MAndDWrh int
  exec Optreadint 0, 'SynMasterAndDetailWrh', 0, @opt_MAndDWrh output
  exec optreadint 0, 'BckDmdRepImp', 0, @OptBckDmdRepImp output; --ShenMin

  --ShenMin
  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  select @wrh = wrh from STKINBCK(nolock) where cls = @cls and num = @num
  exec @return_status = WMSFILTER 'STKINBCK', @piCls = @Cls, @piNum = @num, @piToStat = 1, @piOper = @Oper,@piWrh = @wrh, @piTag = 0, @piAct = null, @poMsg = @msg OUTPUT
  if @return_status <> 0
    begin
     raiserror(@msg, 16, 1)
     return -1
    end

  --取得当前用户
  declare @fillerxcode varchar(20), @fillerx int, @fillerxname varchar(50)
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

  select
    @return_status = 0
  select @store = usergid from system
  select
    @stat = STAT,
    @cur_date = convert(datetime, convert(char, getdate(), 102)),
    @cur_settleno = SETTLENO,
    @billto = BILLTO,
    @psr = PSR,
    @m_wrh = WRH,
    @m_total = TOTAL,
    @m_reccnt = RECCNT,
    @m_filler = FILLER,
    @vendor = VENDOR,    /*2005-8-23*/
    @genbill = GENBILL,  /*2005-8-23*/
    @gennum = GENNUM     /*2005-8-23*/
    from STKINBCK where CLS = @cls and NUM = @num

  IF @CLS = '自营' AND (SELECT BCKLMT FROM VENDOR(NOLOCK) WHERE GID = @BILLTO) = 1
  BEGIN
    raiserror('当前结算单位被限制退货。', 16, 1)
    return 1
  END

  /*2005-8-23 检查是否门店零售退货单生成且使用了总部成本价*/
  if @genbill = 'RTLBCK' and @gennum <> '' and @vendor <> @store
    and exists(select 1 from hdoption(nolock) where moduleno = 284 and optioncaption = 'PriceType' and optionvalue = '1')
    select @rtlbck_usezbinprc = 1
  else
    select @rtlbck_usezbinprc = 0

  --bckdmd----------------------------------2005.03.17-----------
  if @return_status = 0 and @cls = '配货'
  begin
    --set @clsstr = '配进退'
    select @bckdmdnum = num from bckdmd (nolock)
        where locknum = @num and lockcls = '配进退' and stat = 400
    --Receive&Check(StoreBill) Should Found and Write back (BCKDMD.LOCKNUM)

    if @bckdmdnum is not null and rtrim(@bckdmdnum) <> ''
    begin
      select @bckdmdstat = stat from bckdmd(nolock) where num = @bckdmdnum
      if (@bckdmdstat <> 400)
        and ((select optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'ChkWithBckDmd')) = '1')
      begin
          raiserror('来源退货申请单已经终止不能继续审核。', 16, 1)

    return 1
      end
     if exists(select 1 from stkinbckdtl where num = @num and cls= @cls
       group by gdgid having count(1)>1)
     begin
       raiserror('单据中有重复商品，不能回写退货申请单', 16, 1)
       return 1
     end
      if @OptBckDmdRepImp = 0  --ShenMin
        begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
           select @bckdmdnum = gennum
               from stkinbck where num = @num and cls = @cls --and datalength(gennum) = 14
               and gencls = '配货退货申请单'
           update bckdmd set
               locknum = @num, lockcls = '配进退' where num = @bckdmdnum
          end
          exec @ret = bckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
          if @ret = 0
          update bckdmddtl set bckedqty = bck.qty
              from stkinbckdtl bck(nolock)
              where bck.num = @num and bck.cls = @cls and bckdmddtl.num = @bckdmdnum
          and bck.gdgid = bckdmddtl.gdgid
        end;
      else if @OptBckDmdRepImp = 1
       begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
             select @bckdmdnum = gennum
                 from stkinbck where num = @num and cls = @cls --and datalength(gennum) = 14
                 and gencls = '配货退货申请单'
          end;
         set @BckdmdQty = 0;
         set @BckedQty = 0;
          set @BckLine = 0;
          set @BckQty = 0;
          select @BckdmdQty = dmd.Qty, @BckedQty = dmd.BckedQty, @BckLine = bck.Line, @BckQty = bck.qty
          from bckdmddtl dmd(nolock), stkinbckdtl bck(nolock)
          where bck.num = @num and bck.cls = @cls
            and dmd.gdgid = bck.gdgid
            and dmd.num = @bckdmdnum
            and bck.qty + dmd.bckedqty > dmd.qty;

          if @BckLine <> 0
            begin
              if @BckdmdQty < @BckedQty + @BckQty
                begin
                  set @outmsg = '单据中第' + CAST(@BckLine AS varchar(8)) + '行的退货数量'
                              + CAST(@BckQty AS varchar(8)) + ' 超过了来源配货退货申请单中的可退数量'
                              + CAST(@BckdmdQty - @BckedQty  AS varchar(8)) + '，不允许审核！';
                  set @ret = 2;
                end;
            end;
          if @ret = 0
            begin
              update bckdmddtl set bckedqty = bckedqty + bck.qty
             from stkinbckdtl bck(nolock)
             where bck.num = @num and bck.cls = @cls
               and bckdmddtl.num = @bckdmdnum
               and bck.gdgid = bckdmddtl.gdgid
              update bckdmd
              set locknum = null, lockcls = null where num = @bckdmdnum
              select @OverDmdQtyCount = 0
              select @OverDmdQtyCount = count(1) from bckdmddtl(nolock)
              where num = @bckdmdnum and bckedqty < qty
              if @OverDmdQtyCount = 0
                exec @return_status = bckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
              if @return_status<>0
                begin
                  set @outmsg = '更改退货申请单' + @bckdmdnum + '状态失败！';
                  set @ret = 2;
                end
            end;
       end;
    end
    set @return_status = @ret
  end
  --vdrbckdmd
  if @return_status = 0 and @cls = '自营'
  begin
    --set @clsstr = '自营进退'
    select @bckdmdnum = num from vdrbckdmd (nolock)
        where locknum = @num and lockcls = '自营进退' and stat = 500
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
     if exists(select 1 from stkinbckdtl where num = @num and cls= @cls
       group by gdgid having count(1)>1)
     begin
       raiserror('单据中有重复商品，不能回写退货申请单', 16, 1)
       return 1
     end
      if @OptBckDmdRepImp = 0  --ShenMin
        begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
           select @bckdmdnum = gennum
               from stkinbck where num = @num and cls = @cls --and datalength(gennum) = 14
               and gencls = '供应商退货申请单'
           update vdrbckdmd set
               locknum = @num, lockcls = '自营进退' where num = @bckdmdnum
          end;
          exec @ret = vdrbckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
          if @ret = 0
            update vdrbckdmddtl set bckedqty = bck.qty
           from stkinbckdtl bck(nolock)
           where bck.num = @num and bck.cls = @cls and vdrbckdmddtl.num = @bckdmdnum
           and bck.gdgid = vdrbckdmddtl.gdgid
        end;
      else if @OptBckDmdRepImp = 1
       begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
             select @bckdmdnum = gennum
                 from stkinbck where num = @num and cls = @cls --and datalength(gennum) = 14
                 and gencls = '供应商退货申请单'
          end;
         set @BckdmdQty = 0;
         set @BckedQty = 0;
          set @BckLine = 0;
          set @BckQty = 0;
          select @BckdmdQty = dmd.Qty, @BckedQty = dmd.BckedQty, @BckLine = bck.Line, @BckQty = bck.qty
          from vdrbckdmddtl dmd(nolock), stkinbckdtl bck(nolock)
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
                  set @ret = 2;
                end;
            end;
          if @ret = 0
            begin
              update vdrbckdmddtl set bckedqty = bckedqty + bck.qty
             from stkinbckdtl bck(nolock)
             where bck.num = @num and bck.cls = @cls
               and vdrbckdmddtl.num = @bckdmdnum
               and bck.gdgid = vdrbckdmddtl.gdgid;
              update vdrbckdmd
              set locknum = null, lockcls = null where num = @bckdmdnum;
              select @OverDmdQtyCount = 0
              select @OverDmdQtyCount = count(1) from vdrbckdmddtl(nolock)
              where num = @bckdmdnum and bckedqty < qty
              if @OverDmdQtyCount = 0
                exec @return_status = vdrbckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
              if @return_status<>0
                begin
                  set @outmsg = '更改供应商退货申请单' + @bckdmdnum + '状态失败！';
                  set @ret = 2;
                end
            end;
       end;
    end;
    set @return_status = @ret
  end
  if @return_status<>0
  begin
    raiserror('回写退货申请单[%s]失败:%s.', 16, 1, @bckdmdnum, @outmsg)
    return (@return_status)
  end
  --write back over----------------------------------2005.03.17-----------

  if @mode = 0 or @mode = 2 begin
    /* 99-12-29 */
    if @stat not in (0,7)  begin
      raiserror('审核的不是未审核的单据.', 16, 1)
   return (1)
    end
  end
  if @mode = 1 begin
    if @stat <> 1  begin
      raiserror('复核的不是已审核的单据.', 16, 1)
      return (1)
    end
  end
  select @cur_settleno = max(NO) from MONTHSETTLE
  if @mode = 0
    update STKINBCK set STAT = 1, FILDATE = GETDATE(), SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num
  else if @mode = 1
    update STKINBCK set STAT = 6, CHKDATE = GETDATE(), SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num
  else
    update STKINBCK set STAT = 6, CHKDATE = GETDATE(), fildate = getdate(),
 SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num

  /* 启用限制单据的汇总仓位和明细仓位一致 */
  if @cls = '自营' and @opt_MAndDWrh = 1
  begin
    update STKINBCKDTL set wrh = @wrh, note = ltrim(rtrim(note)) + ' 原仓位(' + ltrim(rtrim(str(wrh))) + ')'
    where CLS = @cls and NUM = @num and wrh <> @wrh
  end

  /* 2000-2-28: 生成提单头 */
  if @mode in (0,2) and
     (@cls = '自营' and (select DSP from SYSTEM) & 32 <> 0) or
     (@cls = '配货' and (select DSP from SYSTEM) & 64 <> 0)
    select @gendsp = 1
  else
    select @gendsp = 0
  if @gendsp = 1
  begin
    /* 99-12-6: 要求STKINBCK.WRH=STKINBCKDTL.WRH */
    if (@m_wrh is null)
    or (exists (select * from stkinbckdtl where cls = @cls and num = @num and
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
      LSTDSPTIME, LSTDSPEMP, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO,
      /* 2000-05-12 */ SRC)
    values (
      @dsp_num, @m_wrh, @num, getdate(), @m_total, @m_reccnt, @m_filler, @psr,
      null, null, 'STKINBCK', @cls, @num, null, @cur_settleno,
      /* 2000-05-12 */ @store)
  end

  /* deal with the details */
  declare c_stkinbckdtl cursor for
    select WRH,GDGID, QTY, PRICE, TOTAL, TAX,
    INPRC, RTLPRC, VALIDDATE, LINE, SUBWRH
    from STKINBCKDTL where CLS = @cls and NUM = @num
    for update
  open c_stkinbckdtl
  fetch next from c_stkinbckdtl into
    @wrh, @gdgid, @qty, @price, @total, @tax,
    @inprc, @rtlprc, @validdate, @line, @subwrh
  while @@fetch_status = 0 begin
    /* 99-12-6 */
    --ShenMin
    if @cls = '配货'
    begin
       if exists (select 1 from goods where goods.gid = @gdgid and (goods.isltd & 16) = 16 )
       begin
          raiserror('第%d行的商品已经被限制向总部退货!', 16, 1, @line)
   return (-1)
       end;
    end
    if @cls = '自营' --ShenMin
    begin
       if exists (select 1 from goods where goods.gid = @gdgid and (goods.isltd & 32) = 32 )
       begin
          raiserror('第%d行的商品已经被限制向供应商退货!', 16, 1, @line)
   return (-1)
       end;
    end

    if (select rstwrh from system) = 1
    begin
      /* check against VDRGD */
      if not exists (
        select * from VDRGD
        where VDRGID = @billto and GDGID = @gdgid and WRH = @wrh
      ) begin
        select @msg =
          (select rtrim(NAME)+'['+rtrim(CODE)+']'
           from VENDOR where GID = @billto) +
          '在' +
          (select rtrim(NAME)+'['+rtrim(CODE)+']'
           from WAREHOUSE where GID = @wrh) +
          '不供应' +
          (select rtrim(NAME)+'['+rtrim(CODE)+']'
           from GOODS where GID = @gdgid)
        raiserror(@msg, 16, 1)
        return(1)
      end
    end

    if @genbill = 'RTLBCK'
      /*2005-8-23 如果由门店零售退货单产生则取由零售退货单赋值的进价*/
      select @sale = SALE from GOODSH(nolock) where GID = @gdgid
    else
      /* set INPRC, RTLPRC to current values */
      select @inprc = INPRC, @rtlprc = RTLPRC, @sale = SALE/*2002-06-13*/ from GOODSH where GID = @gdgid

    /*00-3-3*/
    if (select outinprcmode from system) = 1
      select @inprc = lstinprc from subwrhinv
      where subwrh = @subwrh and gdgid = @gdgid

    /* 2000-11-20 */
    if @mode = 0 or @mode = 2
      update STKINBCKDTL set INPRC = @inprc, RTLPRC = @rtlprc
        where CLS = @cls and NUM = @num and LINE = @line

    /* 2000-06-08 */
    /* if @mode = 1 or @mode = 2 begin */
    if @mode = 0 or @mode = 2 begin
      /* update STKINDTL */
      if (select PAYTODTL from GOODS where GID = @gdgid) = 1 begin
        update STKINDTL
          set BCKQTY = BCKQTY + STKBCKIN.QTY
          from STKBCKIN
          where STKINDTL.CLS = STKBCKIN.CLS
            and STKINDTL.NUM = STKBCKIN.INNUM
            and STKINDTL.LINE = STKBCKIN.INLINE
            and STKBCKIN.BCKNUM = @num
            and STKBCKIN.BCKLINE = @line
        if @@error <> 0 begin
          select @return_status = @@error
          break
        end
      end
    end

    /* 2000-05-16 增加未提数动作放到出库之前, 以防止库存记录被删除 */
    /* 2000-2-28: 生成提单明细 */
    if @gendsp = 1
    begin
      insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
        SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE, /* 2000-05-13 */SUBWRH )
      values ( @dsp_num, @line, @line, @gdgid, @price, @qty,
        @total, 0, 0, 0, null, @subwrh )
      execute IncDspQty @wrh, @gdgid, @qty, /*00-3-3*/ @subwrh
    end

    if @mode = 0 or @mode = 2 begin
      /* update inventory */
      execute @return_status = UNLOAD @wrh, @gdgid, @qty, @rtlprc, @validdate
      if @return_status <> 0 break
      if @subwrh is not null
      begin
        execute @return_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @qty
        if @return_status <> 0 break
      end
      /* update INVPRC */
      if @rtlbck_usezbinprc = 1
        /*2005-8-23 如果经销、代销商品由门店零售退货单产生并使用总部成本价，则不在门店移动平均；联销商品调用UPDINVPRC也没任何实际效果*/
        select @return_status = 0
      else
        execute UPDINVPRC '进货退货', @gdgid, @qty, @total, @wrh, @d_cost output /*2002-06-13 2002.08.18*/
      if @sale = 1
         update STKINBCKDTL set COST = @d_cost  --2002-06-13
           where CLS = @cls and NUM = @num and LINE = @line
      else
         update STKINBCKDTL set COST = @qty * @inprc  --2004-08-12
           where CLS = @cls and NUM = @num and LINE = @line
    end

    /* reports */
    if @sale = 1 /*2003-06-13*/
    execute @return_status = STKINBCKDTLCRT
      @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @cls, @wrh, @gdgid, @billto, @psr,
      @qty, @price, @total, @tax, @inprc, @rtlprc, @mode,
      @d_cost /*2002-06-13*/
    else
    execute @return_status = STKINBCKDTLCRT
      @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @cls, @wrh, @gdgid, @billto, @psr,
      @qty, @price, @total, @tax, @inprc, @rtlprc, @mode
    if @return_status <> 0 break

    fetch next from c_stkinbckdtl into
      @wrh,@gdgid,@qty,@price, @total, @tax,
      @inprc, @rtlprc, @validdate, @line, @subwrh
  end
  close c_stkinbckdtl
  deallocate c_stkinbckdtl
  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  if @cls = '直配进退' or @cls = '直配出退'
  begin
    update BCKEXPFEE set PROCAMT = EXPAMT where VDRGID = @billto
  end

  return(@return_status)
end
GO
