SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Stkoutchk_ProcAlcGft](
  @cls char(10),
  @num char(10),
  @ckinv smallint,
  @bvalt float,
  @avalt float
)
with encryption
as
begin
  declare
    @opt_AlcGftQtyMatch int,  @opt_CanAlcQtyLmt int,  @m_GFTGID int,
    @m_store int,             @m_GDGid int,           @m_MainGDQty money,
    @m_TmpMainQty money,      @m_settleno int,        @m_client int,
    @m_slr int,               @m_filler int,          @m_ordnum char(10),
    @outnum char(10),         @opt_AlcQtyLmt int,     @opt_DelFlag int,
    @m_AlcQty money,          @m_ckinv int,           @m_PRICE money,
    @m_SumQty money,          @m_wrh int,             @m_rtlprc money,
    @m_inprc money,           @m_wsprc money,         @m_taxrate money,
    @m_qpc money,             @m_invqty money,        @m_invtotal money,
    @m_diff money,            @m_diffm money,         @m_return_status int,
    @m_GdAlcQty money

  --读取系统选项
  exec OptReadInt 90, 'AlcGftQtyMatch', 0, @opt_AlcGftQtyMatch output
  exec OptReadInt 90, 'CanAlcQtyLmt', 0, @opt_CanAlcQtyLmt output
  exec OptReadInt 0,  'AlcQtyLmt', 0, @opt_AlcQtyLmt output
  exec Optreadint 0, 'IFDELSTKOUTDTL', 0, @opt_DelFlag output

  select @m_store = usergid from system
  select @m_settleno = max(NO) from MONTHSETTLE
  select
    @m_client = BILLTO,
    @m_slr = SLR,
    @m_ordnum = ORDNUM,
    @m_filler = FILLER
  from STKOUT(nolock)
  where CLS = @cls and NUM = @num

  /* 如果严格匹配, 先将主商品数量减到赠品协议用到的数量 */
  if @opt_AlcGftQtyMatch = 1
  begin
    declare c_STKOUTGFTDTL cursor for
    select GDGID, ISNULL(SUM(ALCQTY), 0) from STKOUTGFTDTL where cls = @cls and num = @num and FLAG = 0 group by GDGID

    open c_STKOUTGFTDTL
    fetch next from c_STKOUTGFTDTL into @m_GDGid, @m_AlcQty
    while @@fetch_status = 0
    begin
      select @m_SumQty = isnull(sum(qty), 0) from stkoutdtl where cls = @cls and num = @num and gdgid = @m_GDGid and isnull(gftflag, 0) = 0
      if @m_SumQty > @m_AlcQty
      begin
        select @m_PRICE = isnull(PRICE, 0), @m_wrh = wrh
        from stkoutdtl(nolock)
        where cls = @cls and num = @num and isnull(gftflag, 0) <> 1 and gdgid = @m_GDGid

        select @m_inprc = isnull(inprc, 0), @m_rtlprc = isnull(rtlprc, 0), @m_wsprc = isnull(whsprc, 0),
               @m_taxrate = isnull(taxrate, 0), @m_qpc = isnull(qpc, 0)
        from goods(nolock) where gid = @m_GDGid

        select @m_invqty = isnull(sum(AVLQTY), 0), @m_invtotal = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
        where WRH = @m_wrh and GDGID = @m_GDGid and STORE = @m_store

        set @m_diff = @m_SumQty - @m_AlcQty
        set @m_diffm = @m_diff * @m_PRICE
        if @m_diff > 0
        begin
          set @m_ckinv  = @ckinv & 6 --只记缺货待配和配货池
          execute @m_return_status = StkOutChkRegLack
                  @m_ckinv,
                  @m_GDGid, @m_PRICE, @m_inprc, @m_rtlprc, @m_wsprc, @m_taxrate, @m_qpc, 0,
                  @m_wrh, @m_invqty, @m_invtotal, 0, 0, @m_diff, @m_diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
          /*将GFTID置为-1，防止后面将‘缺货待配’的配出单明细删除*/
          update stkoutdtl set GFTID = -1
          where cls = @cls and num = @num and gdgid = @m_GDGid and isnull(gftflag, 0) <> 1
        end

        exec GetGdValue @m_client, @m_GDGid, 'ALCQTY', @m_GdAlcQty OUTPUT

        if @opt_CanAlcQtyLmt = 0  --不按配货单位
          select @m_GdAlcQty = 1

        set @m_invqty = floor(@m_invqty / @m_GdAlcQty) * @m_GdAlcQty

        if @m_invqty < @m_SumQty --判断库存是否也没有，就记缺货列表，缺货待配和配货池不用记录。
        begin
          if @m_SumQty - @m_invqty > @m_SumQty - @m_AlcQty set @m_diff = @m_SumQty - @m_AlcQty
          else set @m_diff = @m_SumQty - @m_invqty
          set @m_diffm = @m_diff * @m_PRICE

          if @m_diff > 0
          begin
            set @m_ckinv  = @ckinv & 1 --只记缺货列表
            execute @m_return_status = StkOutChkRegLack
                  @m_ckinv,
                  @m_GDGid, @m_PRICE, @m_inprc, @m_rtlprc, @m_wsprc, @m_taxrate, @m_qpc, 0,
                  @m_wrh, @m_invqty, @m_invtotal, 0, 0, @m_diff, @m_diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
          end
        end

        update stkoutdtl set qty = @m_AlcQty where cls = @cls and num = @num and gdgid = @m_GDGid and isnull(gftflag, 0) = 0
      end

      fetch next from c_STKOUTGFTDTL into @m_GDGid, @m_AlcQty
    end
    close c_STKOUTGFTDTL
    deallocate c_STKOUTGFTDTL
  end

  update STKOUTGFTDTL set INVTAG = 0 where cls = @cls and num = @num

  /* 赠品限制配货,按选项处理 */
  if @opt_AlcGftQtyMatch = 0
  begin
    /* 删除限制配货的赠品 */
    delete from stkoutdtl where cls = @cls and num = @num
      and gdgid in (select g.gid from goods g(nolock) where isltd & 1 = 1)
      and isnull(gftflag,0) = 1
    delete from STKOUTGFTDTL where cls = @cls and num = @num
      and GFTGID in (select g.gid from goods g(nolock) where isltd & 1 = 1)
      and FLAG = 1
  end
  else
  begin
    /* 删除主商品和限制配货的赠品 */
    declare c_STKOUTGFTDTL cursor for
    select GFTGID
    from STKOUTGFTDTL
    where cls = @cls and num = @num
      and GFTGID in (select g.gid from goods g(nolock) where isltd & 1 = 1) and FLAG = 1
    group by GFTGID --对赠品GID分组

    open c_STKOUTGFTDTL
    fetch next from c_STKOUTGFTDTL into
      @m_GFTGID
    while @@fetch_status = 0
    begin
      /*对主商品遍历*/
      declare c_STKOUTGFTDTL1 cursor for
      select GDGid, Isnull(sum(ALCQTY), 0) from STKOUTGFTDTL
      where cls = @cls and num = @num and FLAG = 0
        and AGANUM in (select AGANUM from STKOUTGFTDTL where GFTGID = @m_GFTGID)
      group by GDGID  --对主商品GID分组

      open c_STKOUTGFTDTL1
      fetch next from c_STKOUTGFTDTL1 into
        @m_GDGid, @m_MainGDQty
      while @@fetch_status = 0
      begin
        select @m_TmpMainQty = qty from stkoutdtl where cls = @cls and num = @num and GDGID = @m_GDGid and isnull(gftflag, 0) <> 1
        if @m_TmpMainQty > @m_MainGDQty
        begin
          update stkoutdtl set qty = qty - @m_MainGDQty
            where cls = @cls and num = @num and GDGID = @m_GDGid and isnull(gftflag, 0) <> 1
          update stkoutdtl set total = round(qty * price, 2)
            where cls = @cls and num = @num and GDGID = @m_GDGid and isnull(gftflag, 0) <> 1
        end else delete from stkoutdtl where cls = @cls and num = @num and GDGID = @m_GDGid and isnull(gftflag, 0) <> 1

        fetch next from c_STKOUTGFTDTL1 into
          @m_GDGid, @m_MainGDQty  --主商品循环
      end
      close c_STKOUTGFTDTL1
      deallocate c_STKOUTGFTDTL1

      fetch next from c_STKOUTGFTDTL into
        @m_GFTGID  --赠品循环
    end
    close c_STKOUTGFTDTL
    deallocate c_STKOUTGFTDTL

    /*删除赠品*/
    delete from stkoutdtl
      where isnull(gftflag, 0) = 1 and gdgid in (select GFTGID from STKOUTGFTDTL
        where AGANUM in (select AGANUM from STKOUTGFTDTL
          where GFTGID in (select g.gid from goods g(nolock) where isltd & 1 = 1)))

    delete from STKOUTGFTDTL where cls = @cls and num = @num
      and AGANUM in (select AGANUM from STKOUTGFTDTL where GFTGID in (select g.gid from goods g(nolock) where isltd & 1 = 1))
  end

  declare
    @gdgid int,                 @qty money,                     @gftflag int,
    @GFTWRH int,                @PRICE money,                   @TOTAL money,
    @AGANUM char(14),           @flag int,                      @wrh int,
    @inprc money,               @rtlprc money,                  @wsprc money,
    @taxrate money,             @qpc money,                     @invqty money,
    @invtotal money,            @PreQty money,                  @alcqty money,
    @invqty_canuse money,       @qty1 money,                    @TmpPreQty money,
    @allowneg int,              @lackratio money,               @MATCHTIME2 int,
    @GDGID2 int,                @ALCQTY2 money,                 @GFTGID2 int,
    @GFTQTY2 money,             @FLAG2 int,                     @MinPerAlcQty2 int,
    @OldMatch2 int,             @i int,                         @GDAlcQty2 money,
    @AlcQtyMax2 int,            @qty2 money,                    @invqty_canuse2 money,
    @PreQty2 money,             @invqty2 money,                 @wrh2 int,
    @qtymain2 money,            @PerAlcQty2 money,              @MainGDQty2 money,
    @TmpMainQty2 money,         @price2 money,                  @inprc2 money,
    @rtlprc2 money,             @wsprc2 money,                  @taxrate2 money,
    @qpc2 money,                @invtotal2 money,               @ckinvM int,
    @line int,                  @lineno int,                    @vTotal money,
    @vTax money,                @diff money,                    @diffm money,
    @return_status int,         @TmpPreQty2 money

  /*对配出单赠品明细记录处理*/
  declare c_Procalcgft1 cursor for
    select d.gdgid, d.qty, isnull(d.gftflag, 0), g.GFTWRH, d.PRICE, d.TOTAL, g.AGANUM, g.flag
    from STKOUTGFTDTL g(nolock), stkoutdtl d(nolock)
    where g.cls = d.cls and g.num = d.num and d.cls = @cls and d.num = @num and g.INVTAG = 0 --没有记录库存的进入循环
    and ((g.GDGID = d.gdgid  and g.flag = 0 and isnull(d.gftflag, 0) = 0) or
     (g.GFTGID = d.gdgid and g.flag = 1 and isnull(d.gftflag, 0) = 1 and g.aganum = d.srcaganum)) order by g.LISTNO  --根据序号排序
  open c_Procalcgft1
  fetch next from c_Procalcgft1 into @gdgid, @qty, @gftflag, @GFTWRH, @PRICE, @TOTAL, @AGANUM, @flag
  while @@fetch_status = 0
  begin
    --@wrh记录明细仓位
    if @gftflag = 1 set @wrh = @GFTWRH
    else select @wrh = wrh from stkoutdtl(nolock) where cls = @cls and num = @num and gdgid = @gdgid and isnull(gftflag, 0) <> 1

    --取得数据
    select @inprc = isnull(inprc, 0), @rtlprc = isnull(rtlprc, 0), @wsprc = isnull(whsprc, 0),
      @taxrate = isnull(taxrate, 0), @qpc = isnull(qpc, 0)--, @alcqty = isnull(alcqty, 0)
    from goods(nolock) where gid = @gdgid

    exec GetGdValue @m_client, @gdgid, 'ALCQTY', @alcqty OUTPUT

    select @invqty = isnull(sum(AVLQTY), 0), @invtotal = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
    where WRH = @wrh and GDGID = @gdgid and STORE = @m_store

    if @gftflag = 1  --赠品
      update stkoutdtl set invqty = @invqty where cls = @cls and num = @num
        and gdgid = @gdgid and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM

    --得到库存(扣除预配库存)
    select @PreQty = isnull(sum(ALCQTY), 0) from STKOUTGFTDTL(nolock)
      where cls = @cls and num = @num and GDGID = @GDGID and FLAG = 0 and INVTAG = 1
    if @PreQty is null set @PreQty = 0

    select @TmpPreQty = isnull(sum(GFTQTY), 0) from STKOUTGFTDTL(nolock)
      where cls = @cls and num = @num and GFTGID = @GDGID and FLAG = 1 and INVTAG = 1
    if @TmpPreQty is null set @TmpPreQty = 0

    set @PreQty = @PreQty + @TmpPreQty

    set @invqty = @invqty - @PreQty

    if @gftflag = 1  --赠品
    begin
      set @invqty_canuse = @invqty
      set @qty1 = @qty
    end
    else begin  --主商品
      if @opt_CanAlcQtyLmt = 1  --配货单位
      begin
        set @qty1 = floor(@qty / @alcqty) * @alcqty
        set @invqty_canuse = floor(@invqty / @alcqty) * @alcqty
        if (@opt_AlcQtyLmt = 1) and (@invqty_canuse = 0) --配货出货单审核时要货数量小于配货单位的处理
        begin
          set @invqty_canuse = @invqty
        end
      end
      else
      begin
        set @qty1 = @qty
        set @invqty_canuse = @invqty
      end
    end /* 至此: @qty = 实际配货数， @qty1 = 实际按配货单位的配货数 ， @invqty_canuse = 按配货单位的可用库存*/

    select @allowneg = allowneg from warehouse where gid = @wrh
    /* 允许负库存就不管,只记录配货单位 */
    if @allowneg = 1
    begin
      /*先根据选项将主商品配货数减到配货单位整数倍(赠品不考虑配货单位)*/
      if @gftflag = 0  --主商品
      begin
        if (@opt_CanAlcQtyLmt = 1) and (not ((@opt_AlcQtyLmt = 1) and (floor(@invqty / @alcqty) * @alcqty = 0)))--配货单位
        begin
          /* 根据配货单位更新主商品数量*/
          set @qty1 = floor(@qty / @alcqty) * @alcqty
          update stkoutdtl set qty = @qty1, total = round(@qty1 * price, 2)
            where cls = @cls and num = @num and gdgid = @gdgid and isnull(gftflag, 0) = 0
          update STKOUTGFTDTL set ALCQTY = @qty1
            where cls = @cls and num = @num and AGANUM = @AGANUM and gdgid = @gdgid

          /*主商品因为配货单位而被清空的情况*/
          if @qty1 = 0
          begin
            if @opt_DelFlag = 1
            begin
              delete from stkoutdtl where cls = @cls and num = @num and gdgid = @gdgid and isnull(gftflag, 0) = 0
              delete from STKOUTGFTDTL where cls = @cls and num = @num and AGANUM = @AGANUM and gdgid = @gdgid
            end
          end
        end
      end

      fetch next from c_Procalcgft1 into @gdgid, @qty, @gftflag, @GFTWRH, @PRICE, @TOTAL, @AGANUM, @flag
      continue
    end

    --计算缺货比
    if @qty1 = 0 
      set @lackratio = 0
    else
      set @lackratio = (@qty1 - @invqty_canuse) / @qty1 * 100
    if @qty1 < 0 select @lackratio = -1

    if @lackratio <= @bvalt
    begin
      if (@gftflag = 0) or (@gftflag = 1) --主商品或赠品处理相同
      begin
        --根据选项主商品和赠品是否匹配(如果不匹配不必处理)
        if (@opt_AlcGftQtyMatch = 1) or (@gftflag = 0 and @opt_AlcGftQtyMatch = 0)
        begin
          declare c_Procalcgft2 cursor for
          select MATCHTIME, GDGID, ALCQTY, GFTGID, GFTQTY, FLAG
          from STKOUTGFTDTL(nolock) where cls = @cls and num = @num and AGANUM = @AGANUM

          open c_Procalcgft2
          fetch next from c_procalcgft2 into @MATCHTIME2, @GDGID2, @ALCQTY2, @GFTGID2, @GFTQTY2, @FLAG2

          set @MinPerAlcQty2 = @MATCHTIME2
          set @OldMatch2 = @MATCHTIME2

          /* 根据协议数量和配货单位更新主商品赠品数量*/
          while @@fetch_status = 0
          begin
             if @flag2 = 0
               select @wrh2 = wrh from stkoutdtl(nolock) where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1
             else
               select @wrh2 = GFTWRH from STKOUTGFTDTL(nolock) where cls = @cls and num = @num
                 and gftgid = @GFTGID2 and AGANUM = @AGANUM

             if @flag2 = 0
               select @invqty2 = isnull(sum(AVLQTY), 0) from V_ALCINV(nolock)
                 where WRH = @wrh2 and GDGID = @gdgid2 and STORE = @m_store
             else
               select @invqty2 = isnull(sum(AVLQTY), 0) from V_ALCINV(nolock)
                 where WRH = @wrh2 and GDGID = @GFTGID2 and STORE = @m_store
                 
             if @flag2 = 1  --赠品
               update stkoutdtl set invqty = @invqty2 where cls = @cls and num = @num
                 and gdgid = @GFTGID2 and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM
             else 
               update stkoutdtl set invqty = @invqty2 where cls = @cls and num = @num  
                 and gdgid = @GDGID2 and isnull(gftflag, 0) = 0


             select @PreQty2 = isnull(sum(ALCQTY), 0) from STKOUTGFTDTL(nolock)
               where cls = @cls and num = @num and GDGID = @GDGID2 and FLAG = 0 and INVTAG = 1
             if @PreQty2 is null set @PreQty2 = 0
             select @TmpPreQty2 = isnull(sum(GFTQTY), 0) from STKOUTGFTDTL(nolock)
               where cls = @cls and num = @num and GFTGID = @GFTGID2 and FLAG = 1 and INVTAG = 1
             if @TmpPreQty2 is null set @TmpPreQty2 = 0
             set @PreQty2 = @PreQty2 + @TmpPreQty2

             set @invqty2 = @invqty2 - @PreQty2

             if @FLAG2 = 0 exec GetGdValue @m_client, @GDGID2, 'ALCQTY', @GDAlcQty2 OUTPUT
             else select @GDAlcQty2 = 1

             if @opt_CanAlcQtyLmt = 0  --不按配货单位
               select @GDAlcQty2 = 1

             if @FLAG2 = 0 set @PerAlcQty2 = @ALCQTY2 / @MATCHTIME2
             else set @PerAlcQty2 = @GFTQTY2 / @MATCHTIME2

             set @invqty_canuse2 = floor(@invqty2 / @GDAlcQty2) * @GDAlcQty2

             if (@opt_AlcQtyLmt = 1) and (@invqty_canuse2 = 0) --配货出货单审核时要货数量小于配货单位的处理
             begin
               set @invqty_canuse2 = @invqty2
               select @GDAlcQty2 = 1  --这种情况下把库存全部配出，相当于不按配货单位取整
             end

             if (@opt_CanAlcQtyLmt = 1) and (@FLAG2 = 0)
             begin
               --计算协议数量和配货单位的最小公倍数
               set @i = 1
               while @i <= @PerAlcQty2
               begin
                 if (@i * @GDAlcQty2 / @PerAlcQty2) = floor(@i * @GDAlcQty2 / @PerAlcQty2) break
                 set @i = @i + 1
               end
               set @AlcQtyMax2 = @i * @GDAlcQty2
             end else set @AlcQtyMax2 = @PerAlcQty2
             --if @lackratio <= 0
             --begin
               if @FLAG2 = 0
                 select @qtymain2 = qty from stkoutdtl
                 where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1
               else
                 select @qtymain2 = qty from stkoutdtl
                 where cls = @cls and num = @num and gdgid = @GFTGID2 and isnull(gftflag, 0) = 1
                   and srcaganum = @AGANUM
               set @qty2 = floor(@qtymain2 / @AlcQtyMax2) * @AlcQtyMax2
             --end
             --else set @qty2 = floor(@invqty_canuse2 / @AlcQtyMax2) * @AlcQtyMax2
             if @qty2 > floor(@invqty_canuse2 / @AlcQtyMax2) * @AlcQtyMax2 
               set @qty2 = floor(@invqty_canuse2 / @AlcQtyMax2) * @AlcQtyMax2
             /*至此 @qty2记录能出货数量, @PerAlcQty2记录单倍协议配货数量*/

             if @FLAG2 = 0
             begin
               --select @qtymain2 = qty from stkoutdtl(nolock) where cls = @cls and num = @num
                 --and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1
               select @qtymain2 = alcqty from STKOUTGFTDTL(nolock) where cls = @cls and num = @num  
                 and gdgid = @GDGID2 and flag = 0 and aganum = @AGANUM
               if @qty2 < @qtymain2 --配货数量减少了
               begin
                 if @qty2 / @PerAlcQty2 < @MinPerAlcQty2 set @MinPerAlcQty2 = @qty2 / @PerAlcQty2
               end
             end
             else
             begin
               --select @qtymain2 = qty from stkoutdtl(nolock) where cls = @cls and num = @num
                 --and gdgid = @GFTGid2 and isnull(gftflag, 0) = 1 and srcaganum = @AGANUM
               select @qtymain2 = gftqty from STKOUTGFTDTL(nolock) where cls = @cls and num = @num  
                 and gftgid = @GFTGid2 and flag = 1 and aganum = @AGANUM  
               if @qty2 < @qtymain2 --配货数量减少了
               begin
                 if @qty2 / @PerAlcQty2 < @MinPerAlcQty2 set @MinPerAlcQty2 = @qty2 / @PerAlcQty2
               end
             end

             fetch next from c_Procalcgft2 into
               @MATCHTIME2, @GDGID2, @ALCQTY2, @GFTGID2, @GFTQTY2, @FLAG2
          end
          close c_Procalcgft2
          deallocate c_Procalcgft2

          declare c_Procalcgft2 cursor for
          select GDGID, ALCQTY, GFTGID, GFTQTY, FLAG
          from ALCGFTDTL(nolock) where SRCNUM = @AGANUM

          open c_Procalcgft2
          fetch next from c_procalcgft2 into @GDGID2, @ALCQTY2, @GFTGID2, @GFTQTY2, @FLAG2
          while @@fetch_status = 0
          begin
            if (@opt_AlcGftQtyMatch = 1) and (@FLAG2 = 0)
            begin
              update STKOUTGFTDTL set MATCHTIME = @MinPerAlcQty2, ALCQTY = @MinPerAlcQty2 * @ALCQTY2
                where cls = @cls and num = @num and AGANUM = @AGANUM and GDGID = @GDGID2 and FLAG = 0

              select @wrh2 = wrh from stkoutdtl(nolock) where cls = @cls and num = @num
                and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              select @invqty2 = isnull(sum(AVLQTY), 0), @invtotal2 = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
                 where WRH = @wrh2 and GDGID = @gdgid2 and STORE = @m_store

              if @opt_CanAlcQtyLmt = 1
                --select @GDAlcQty2 = alcqty from goods(nolock) where gid = @GDGID2
                exec GetGdValue @m_client, @GDGID2, 'ALCQTY', @GDAlcQty2 OUTPUT
              else
                select @GDAlcQty2 = 1

              set @invqty_canuse2 = floor(@invqty2 / @GDAlcQty2) * @GDAlcQty2
              if (@opt_AlcQtyLmt = 1) and (@invqty_canuse2 = 0) --配货出货单审核时要货数量小于配货单位的处理
              begin
                set @invqty_canuse2 = @invqty2
              end

              --@qtymain2配出单数量
              select @qtymain2 = qty from stkoutdtl
                where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              --@qty2实际可以配出数量
              set @qty2 = (@OldMatch2 - @MinPerAlcQty2) * @ALCQTY2
              set @qty2 = @qtymain2 - @qty2
              if @qty2 > @invqty_canuse2 set @qty2 = @invqty_canuse2

              update stkoutdtl set qty = @qty2, total = round(@qty2 * price, 2)
                where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              --更新后的数量比原来的少了-记录缺货待配
              select @inprc2 = isnull(inprc, 0), @rtlprc2 = isnull(rtlprc, 0), @wsprc2 = isnull(whsprc, 0),
                @taxrate2 = isnull(taxrate, 0), @qpc2 = isnull(qpc, 0)
              from goods(nolock) where gid = @GDGID2

              select @PRICE2 = isnull(PRICE, 0)
              from stkoutdtl(nolock)
              where cls = @cls and num = @num and isnull(gftflag, 0) <> 1 and gdgid = @GDGID2

              set @diff = @qtymain2 - @qty2
              set @diffm = @diff * @price2
              if @diff > 0
              begin
                set @ckinvM  = @ckinv & 6 --只记缺货待配和配货池
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 0,
                  @wrh2, @invqty2, @invtotal2, 0, 0, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output, 1 /*缺货待配累加*/
                  /*将GFTID置为-1，防止后面将‘缺货待配’的配出单明细删除*/
                  update stkoutdtl set GFTID = -1
                    where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1
              end

              if @invqty_canuse2 < @qtymain2 --判断库存是否也没有，就记缺货列表，缺货待配和配货池不用记录。
              begin
                set @ckinvM  = @ckinv & 1 --只记缺货列表
                set @diff = @qtymain2 - @invqty_canuse2
                set @diffm = @diff * @price2
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 0,
                  @wrh2, @invqty2, @invtotal2, @invqty2, @invtotal2, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
              end
            end
            else if (@opt_AlcGftQtyMatch = 0) and (@FLAG2 = 0)
            begin
              update STKOUTGFTDTL set MATCHTIME = @MinPerAlcQty2, ALCQTY = @MinPerAlcQty2 * @ALCQTY2
                where cls = @cls and num = @num and AGANUM = @AGANUM and GDGID = @GDGID2 and FLAG = 0

              select @wrh2 = wrh from stkoutdtl(nolock) where cls = @cls and num = @num
                and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              select @invqty2 = isnull(sum(AVLQTY), 0), @invtotal2 = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
                 where WRH = @wrh2 and GDGID = @gdgid2 and STORE = @m_store

              if @opt_CanAlcQtyLmt = 1
                --select @GDAlcQty2 = alcqty from goods(nolock) where gid = @GDGID2
                exec GetGdValue @m_client, @GDGID2, 'ALCQTY', @GDAlcQty2 OUTPUT
              else
                select @GDAlcQty2 = 1

              set @invqty_canuse2 = floor(@invqty2 / @GDAlcQty2) * @GDAlcQty2
              if (@opt_AlcQtyLmt = 1) and (@invqty_canuse2 = 0) --配货出货单审核时要货数量小于配货单位的处理
              begin
                set @invqty_canuse2 = @invqty2
              end

              --@qtymain2配出单数量
              select @qtymain2 = qty from stkoutdtl
                where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              --@qty2实际可以配出数量
              set @qty2 = @qtymain2
              if @qty2 > @invqty_canuse2 set @qty2 = @invqty_canuse2
              else set @qty2 = floor(@qty2 / @GDAlcQty2) * @GDAlcQty2

              update stkoutdtl set qty = @qty2, total = round(@qty2 * price, 2)
                where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              --更新后的数量比原来的少了-记录缺货待配
              select @inprc2 = isnull(inprc, 0), @rtlprc2 = isnull(rtlprc, 0), @wsprc2 = isnull(whsprc, 0),
                @taxrate2 = isnull(taxrate, 0), @qpc2 = isnull(qpc, 0)
              from goods(nolock) where gid = @GDGID2

              select @PRICE2 = isnull(PRICE, 0)
              from stkoutdtl(nolock)
              where cls = @cls and num = @num and isnull(gftflag, 0) <> 1 and gdgid = @GDGID2

              set @diff = @qtymain2 - @qty2
              set @diffm = @diff * @price2
              if @diff > 0
              begin
                set @ckinvM  = @ckinv & 6 --只记缺货待配和配货池
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 0,
                  @wrh2, @invqty2, @invtotal2, 0, 0, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output, 1 /*缺货待配累加*/
                  /*将GFTID置为-1，防止后面将‘缺货待配’的配出单明细删除*/
                  update stkoutdtl set GFTID = -1
                    where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1
              end

              if @invqty_canuse2 < @qtymain2 --判断库存是否也没有，就记缺货列表，缺货待配和配货池不用记录。
              begin
                set @ckinvM  = @ckinv & 1 --只记缺货列表
                set @diff = @qtymain2 - @invqty_canuse2
                set @diffm = @diff * @price2
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 0,
                  @wrh2, @invqty2, @invtotal2, @invqty2, @invtotal2, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
              end
            end
            else if @FLAG2 = 1
            begin
              update STKOUTGFTDTL set MATCHTIME = @MinPerAlcQty2, GFTQTY = @MinPerAlcQty2 * @GFTQTY2
                where cls = @cls and num = @num and AGANUM = @AGANUM and GFTGID = @GFTGID2 and FLAG = 1

              select @wrh2 = GFTWRH from STKOUTGFTDTL(nolock) where cls = @cls and num = @num
                 and gftgid = @GFTGID2 and AGANUM = @AGANUM

              select @invqty2 = isnull(sum(AVLQTY), 0) from V_ALCINV(nolock)
                 where WRH = @wrh2 and GDGID = @GFTGID2 and STORE = @m_store

              set @invqty_canuse2 = @invqty2

              --@qtymain配出单数量
              select @qtymain2 = qty from stkoutdtl
                where cls = @cls and num = @num and gdgid = @GFTGID2 and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM

              --@qty2实际可以配出数量
              set @qty2 = (@OldMatch2 - @MinPerAlcQty2) * @GFTQTY2
              --set @qty2 = @qtymain2 - @qty2
              set @qty2 = @OldMatch2 * @GFTQTY2 - @qty2
              if @qty2 > @invqty_canuse2 set @qty2 = @invqty_canuse2

              update stkoutdtl set qty = @qty2, total = round(@qty2 * price, 2)
                where cls = @cls and num = @num and gdgid = @GFTGID2 and SRCAGANUM = @AGANUM and isnull(gftflag, 0) = 1

              --更新后的数量比原来的少了-记录缺货待配
              select @inprc2 = isnull(inprc, 0), @rtlprc2 = isnull(rtlprc, 0), @wsprc2 = isnull(whsprc, 0),
                @taxrate2 = isnull(taxrate, 0), @qpc2 = isnull(qpc, 0)
              from goods(nolock) where gid = @GFTGID2

              select @PRICE2 = isnull(PRICE, 0)
              from stkoutdtl(nolock)
              where cls = @cls and num = @num and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM and gdgid = @GFTGID2

              select @wrh2 = gftwrh from STKOUTGFTDTL(nolock)
              where cls = @cls and num = @num and GFTGID = @GFTGID2 and AGANUM = @AGANUM

              select @invqty2 = isnull(sum(AVLQTY), 0), @invtotal2 = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
              where WRH = @wrh2 and GDGID = @GFTGID2 and STORE = @m_store

              set @invqty_canuse2 = @invqty2


              set @diff = @qtymain2 - @qty2
              set @diffm = @diff * @price2
              if @diff > 0
              begin
                /* 以下注释掉,赠品不需要记录待配和配货池 */
                /*set @ckinvM  = @ckinv & 6 --只记缺货待配和配货池
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @GFTGID2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 1,
                  @wrh2, @invqty2, @invtotal2, 0, 0, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output, 1 -- 缺货待配累加*/
                  /*将GFTID置为-1，防止后面将‘缺货待配’的配出单明细删除*/
                  update stkoutdtl set GFTID = -1
                    where cls = @cls and num = @num and gdgid = @GFTGID2 and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM
              end
              if @invqty_canuse2 < @qtymain2 --判断库存是否也没有，就记缺货列表，缺货待配和配货池不用记录。
              begin
                set @ckinvM  = @ckinv & 1 --只记缺货列表
                set @diff = @qtymain2 - @invqty_canuse2
                set @diffm = @diff * @price2
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @GFTGID2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 1,
                  @wrh2, @invqty2, @invtotal2, @invqty2, @invtotal2, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
              end
            end

            fetch next from c_Procalcgft2 into
              @GDGID2, @ALCQTY2, @GFTGID2, @GFTQTY2, @FLAG2
          end
          close c_Procalcgft2
          deallocate c_Procalcgft2
          if @MinPerAlcQty2 = 0 delete from STKOUTGFTDTL where cls = @cls and num = @num and AGANUM = @AGANUM
        end  -- if opt_AlcGftQtyMatch = 1
      end -- if (@gftflag = 0) or (@gftflag = 1) --主商品或赠品处理相同
      --更新成已记录库存
      update STKOUTGFTDTL set INVTAG = 1 where cls = @cls and num = @num  
        and AGANUM = @AGANUM
      /*if @gftflag = 0
        update STKOUTGFTDTL set INVTAG = 1 where cls = @cls and num = @num
          and AGANUM = @AGANUM and GDGID = @gdgid and flag = 0
      else
        update STKOUTGFTDTL set INVTAG = 1 where cls = @cls and num = @num
          and AGANUM = @AGANUM and gftgid = @gdgid and flag = 1*/
    end  -- else if @lackratio <= @bvalt
    else
    begin
      /* 如果是普通商品,下面会删除记录;如果是赠品主商品,下面会删除记录,根据选项,
         匹配的话,这里要把同组的主商品和赠品删除,防止只配了赠品不配主商品,并记录
         他们的缺货列表待配;如果是赠品,根据选项,如果可以不匹配,下面会处理,如果必
         须匹配,要删除同组的主商品和赠品,对他们记录缺货列表待配 */
      if (@gftflag = 0) or (@gftflag = 1) --主商品或赠品处理相同
      begin
        if (@opt_AlcGftQtyMatch = 1) or (@gftflag = 0 and @opt_AlcGftQtyMatch = 0)
        begin
          --记录缺货列表待配
          declare c_Procalcgft2 cursor for
          select GDGID, ALCQTY, GFTGID, GFTQTY, FLAG
          from STKOUTGFTDTL(nolock) where AGANUM = @AGANUM and cls = @cls and num = @num

          open c_Procalcgft2
          fetch next from c_procalcgft2 into @GDGID2, @ALCQTY2, @GFTGID2, @GFTQTY2, @FLAG2
          while @@fetch_status = 0
          begin
            if (@opt_AlcGftQtyMatch = 1) and (@FLAG2 = 0)
            begin
              --更新后的数量比原来的少了-记录缺货待配
              select @inprc2 = isnull(inprc, 0), @rtlprc2 = isnull(rtlprc, 0), @wsprc2 = isnull(whsprc, 0),
                @taxrate2 = isnull(taxrate, 0), @qpc2 = isnull(qpc, 0)
              from goods(nolock) where gid = @GDGID2

              select @PRICE2 = isnull(PRICE, 0)
              from stkoutdtl(nolock)
              where cls = @cls and num = @num and isnull(gftflag, 0) <> 1 and gdgid = @GDGID2

              select @wrh2 = wrh from stkoutdtl(nolock) where cls = @cls and num = @num and gdgid = @GDGID2 and isnull(gftflag, 0) <> 1

              select @invqty2 = isnull(sum(AVLQTY), 0), @invtotal2 = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
                 where WRH = @wrh2 and GDGID = @gdgid2 and STORE = @m_store

              --select @GDAlcQty2 = alcqty from goods(nolock) where gid = @GDGID2
              exec GetGdValue @m_client, @GDGID2, 'ALCQTY', @GDAlcQty2 OUTPUT

              if @opt_CanAlcQtyLmt = 0  --不按配货单位
                select @GDAlcQty2 = 1

              set @invqty_canuse2 = floor(@invqty2 / @GDAlcQty2) * @GDAlcQty2
              if (@opt_AlcQtyLmt = 1) and (@invqty_canuse2 = 0) --配货出货单审核时要货数量小于配货单位的处理
              begin
                set @invqty_canuse2 = @invqty2
              end

              set @diff = @ALCQTY2
              set @diffm = @diff * @price2
              if @diff > 0
              begin
                set @ckinvM  = @ckinv & 6 --只记缺货待配和配货池
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 0,
                  @wrh2, @invqty2, @invtotal2, 0, 0, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output, 1 /*缺货待配累加*/
                  /*将GFTID置为-1，防止后面将‘缺货待配’的配出单明细删除*/
                  update stkoutdtl set GFTID = -1
                    where cls = @cls and num = @num and gdgid = @gdgid2 and isnull(gftflag, 0) <> 1
              end
              if @invqty_canuse2 < @ALCQTY2 --判断库存是否也没有，就记缺货列表，缺货待配和配货池不用记录。
              begin
                set @ckinvM  = @ckinv & 1 --只记缺货列表
                set @diff = @ALCQTY2 - @invqty_canuse2
                set @diffm = @diff * @price2
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 0,
                  @wrh2, @invqty2, @invtotal2, @invqty2, @invtotal2, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
              end
            end
            else if @FLAG2 = 1
            begin
              --更新后的数量比原来的少了-记录缺货待配
              select @inprc2 = isnull(inprc, 0), @rtlprc2 = isnull(rtlprc, 0), @wsprc2 = isnull(whsprc, 0),
                @taxrate2 = isnull(taxrate, 0), @qpc2 = isnull(qpc, 0)
              from goods(nolock) where gid = @GFTGID2

              select @PRICE2 = isnull(PRICE, 0)
              from stkoutdtl(nolock)
              where cls = @cls and num = @num and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM and gdgid = @GFTGID2

              select @wrh2 = gftwrh from STKOUTGFTDTL(nolock)
              where cls = @cls and num = @num and GFTGID = @GFTGID2 and AGANUM = @AGANUM

              select @invqty2 = isnull(sum(AVLQTY), 0), @invtotal2 = isnull(sum(TOTAL), 0) from V_ALCINV(nolock)
              where WRH = @wrh2 and GDGID = @GFTGID2 and STORE = @m_store

              set @invqty_canuse2 = @invqty2

              set @diff = @GFTQTY2
              set @diffm = @diff * @price2
              if @diff > 0
              begin
                /* 以下注释掉,赠品不需要记录待配和配货池 */
                /*set @ckinvM  = @ckinv & 6 --只记缺货待配和配货池
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @GFTQTY2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 1,
                  @wrh2, @invqty2, @invtotal2, 0, 0, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output, 1 --缺货待配累加*/
                  /*将GFTID置为-1，防止后面将‘缺货待配’的配出单明细删除*/
                  update stkoutdtl set GFTID = -1
                    where cls = @cls and num = @num and gdgid = @GFTGID2 and isnull(gftflag, 0) = 1 and SRCAGANUM = @AGANUM
              end
              if @invqty_canuse2 < @GFTQTY2 --判断库存是否也没有，就记缺货列表，缺货待配和配货池不用记录。
              begin
                set @ckinvM  = @ckinv & 1 --只记缺货列表
                set @diff = @GFTQTY2 - @invqty_canuse2
                set @diffm = @diff * @price2
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @GFTQTY2, @price2, @inprc2, @rtlprc2, @wsprc2, @taxrate2, @qpc2, 1,
                  @wrh2, @invqty2, @invtotal2, @invqty2, @invtotal2, @diff, @diffm,
                  @cls, @num, @m_store, @m_settleno, @m_client, @m_slr, @m_filler,
                  @m_ordnum,
                  @outnum output
              end
            end

            fetch next from c_Procalcgft2 into
              @GDGID2, @ALCQTY2, @GFTGID2, @GFTQTY2, @FLAG2
          end
          close c_Procalcgft2
          deallocate c_Procalcgft2

          /* 删除赠品和主商品*/
          --对主商品遍历
          if not ((@opt_AlcGftQtyMatch = 0) and (@gftflag = 0))
          begin
            declare c_Procalcgft2 cursor for
            select GDGid, Isnull(ALCQTY, 0) from STKOUTGFTDTL
            where cls = @cls and num = @num and FLAG = 0
              and AGANUM = @AGANUM

            open c_Procalcgft2
            fetch next from c_Procalcgft2 into
              @GDGid2, @MainGDQty2
            while @@fetch_status = 0
            begin
              select @TmpMainQty2 = qty from stkoutdtl where cls = @cls and num = @num and GDGID = @GDGid2 and isnull(gftflag, 0) <> 1
              if @TmpMainQty2 > @MainGDQty2
              begin
                update stkoutdtl set qty = qty - @MainGDQty2
                  where cls = @cls and num = @num and GDGID = @GDGid2 and isnull(gftflag, 0) <> 1
                update stkoutdtl set total = round(qty * price, 2)
                  where cls = @cls and num = @num and GDGID = @GDGid2 and isnull(gftflag, 0) <> 1
              end else delete from stkoutdtl where cls = @cls and num = @num and GDGID = @GDGid2 and isnull(gftflag, 0) <> 1

              fetch next from c_Procalcgft2 into
                @GDGid2, @MainGDQty2  --主商品循环
            end
            close c_Procalcgft2
            deallocate c_Procalcgft2
          end

          --删除赠品
          delete from stkoutdtl where cls = @cls and num = @num and SRCAGANUM = @AGANUM and isnull(gftflag, 0) = 1
          delete from STKOUTGFTDTL where cls = @cls and num = @num and AGANUM = @AGANUM
        end  --if (@opt_AlcGftQtyMatch = 1) or (@gftflag = 0 and @opt_AlcGftQtyMatch = 0)
      end  --if (@gftflag = 0) or (@gftflag = 1) --主商品或赠品处理相同

      update STKOUTGFTDTL set INVTAG = 1 where cls = @cls and num = @num  
        and AGANUM = @AGANUM

      /*if @gftflag = 0
        update STKOUTGFTDTL set INVTAG = 1 where cls = @cls and num = @num
          and AGANUM = @AGANUM and GDGID = @gdgid and flag = 0
      else
        update STKOUTGFTDTL set INVTAG = 1 where cls = @cls and num = @num
          and AGANUM = @AGANUM and gftgid = @gdgid and flag = 1*/
    end

    fetch next from c_Procalcgft1 into @gdgid, @qty, @gftflag, @GFTWRH, @PRICE, @TOTAL, @AGANUM, @flag
  end
  close c_Procalcgft1
  deallocate c_Procalcgft1


  /*删除数量为0的记录*/
  if @opt_DelFlag = 1
    delete from stkoutdtl where cls = @cls and num = @num and qty = 0

  /*更新行号*/
  declare c_Procalcgft1 cursor for
    select gdgid, line
    from stkoutdtl(nolock)
    where cls = @cls and num = @num order by line

  set @line = 0
  update stkoutdtl set line = line + 10 where cls = @cls and num = @num
  open c_Procalcgft1
  fetch next from c_Procalcgft1 into @gdgid, @lineno
  while @@fetch_status = 0
  begin
    set @line = @line + 1
    update stkoutdtl set line = @line
      where cls = @cls and num = @num and gdgid = @gdgid and line = @lineno
    fetch next from c_Procalcgft1 into @gdgid, @lineno
  end
  close c_Procalcgft1
  deallocate c_Procalcgft1

  return(0)
end
GO
