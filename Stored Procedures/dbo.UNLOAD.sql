SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
cREATE procedure [dbo].[UNLOAD] (
  @p_wrh int,
  @p_gdgid int,
  @p_qty money,
  @p_prc money,
  @p_validdate datetime,
  @ckinv smallint = 0
) with encryption as
begin
  /*
    on return:
    0 = ok
    1 = 缺少到效日期信息, with raiserror
    2 = 库存量不足, with raiserror
    3 = 库存量不足, without raiserror
    4 = 指定的到效期商品不存在, with raiserror
  */
  declare
    @g_chkvd smallint,
    @w_chkvd smallint,
    @w_allowneg smallint,
    @i_qty money,
    @i_total money,
    /* 2000-04-21 */ @i_dspqty money, @i_bckqty money,
    @ysettleno int,
    @settleno int,
    @cur_date datetime,
    @store int,
    @g_prctype smallint,
    @msg varchar(200)

  select @g_chkvd = CHKVD, @g_prctype=PRCTYPE from GOODS where GID = @p_gdgid
  select @w_chkvd = CHKVD, @w_allowneg = ALLOWNEG from WAREHOUSE where GID = @p_wrh
  if @g_chkvd = 1 and @w_chkvd = 1 begin
    if @p_validdate is null begin
      select @msg = '商品' + (select CODE from GOODS where GID = @p_gdgid)
        + '在仓位' + (select code from warehouse where gid = @p_wrh)
        + '实行到效期管理, 但输入数据中缺少到效日期信息.'
      raiserror(@msg, 16, 1)
      return(1)
    end
  end else select @p_validdate = null

  /* 如果这个仓位是一个门店 */
  select @store = null
  select @store = GID from STORE where GID = @p_wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @p_wrh = 1

  if @w_allowneg = 0 begin
    select @i_qty = sum(QTY), @i_total = sum(TOTAL)
      from INV where WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store

    /* 当库存中不存在该仓位该商品的记录时,null < anything不成立,从而会出现负库存.99-03-30 */
    if @i_qty is null select @i_qty = 0, @i_total = 0

    if @i_qty < @p_qty           -- 2001-08-27 or /*2000-7-28*/(@g_prctype=1 and @i_total < @p_qty * @p_prc)
    begin
      if @ckinv = 0
      begin
        select @msg =
          '不允许负库存的仓位' + (select code from warehouse where gid = @p_wrh)
          + '中商品' + (select CODE from GOODS where GID = @p_gdgid)
          + '的库存量不足'
        raiserror(@msg, 16, 1)
        return(2)
      end
      else
      begin
        /* 生成缺货记录 */
        insert into GDLACK (GDGID, WRH, ACNTQTY, ACNTTOTAL)
        values (@p_gdgid, @p_wrh, @i_qty, @i_total)
        return (3)
      end
    end
  end

  if @p_validdate is null begin
    if not exists (select * from INV where WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store)
      insert into INV (STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
        values (@store, @p_wrh, @p_gdgid, 0, 0, null)
    update INV set
      QTY = QTY - @p_qty,
      TOTAL = TOTAL - @p_qty * @p_prc
      where  WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store
  end else begin
    if not exists (select * from INV where WRH = @p_wrh and GDGID = @p_gdgid
    and VALIDDATE = @p_validdate and QTY >= @p_qty and STORE = @store) begin
      select @msg = '商品' + (select CODE from GOODS where GID = @p_gdgid)
        + '在仓位' + (select code from warehouse where gid = @p_wrh)
        + '实行到效期管理, 但指定的到效期商品不存在.'
      raiserror(@msg, 16, 1)
      return(4)
    end
    select @i_qty = QTY, @i_total = TOTAL,
      /* 2000-04-21 */@i_dspqty = DSPQTY, @i_bckqty = BCKQTY
      from INV where WRH = @p_wrh and GDGID = @p_gdgid
      and VALIDDATE = @p_validdate and STORE = @store
    update INV set
      QTY = QTY - @p_qty,
      TOTAL = TOTAL - @p_qty * @p_prc
      where WRH = @p_wrh and GDGID = @p_gdgid and VALIDDATE = @p_validdate
      and STORE = @store
    if @i_qty = @p_qty and @i_total = @p_qty * @p_prc
    /* 2000-04-21 */ and @i_dspqty = 0 and @i_bckqty = 0
    begin
      delete from INV
      where WRH = @p_wrh and GDGID = @p_gdgid and VALIDDATE = @p_validdate
      and STORE = @store
      if not exists (select * from INV
      where WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store)
        insert into INV(STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
        values (@store, @p_wrh, @p_gdgid, 0, 0, null)
    end
  end
  /* 修改报表 */
  if @store = (select usergid from system)
  begin
    select @settleno = max(NO) from MONTHSETTLE
    select @cur_date = convert(datetime, convert(char, getdate(), 102))
    select @ysettleno = max(NO) from YEARSETTLE
    execute CRTINVRPT @store, @settleno, @cur_date, @p_wrh, @p_gdgid
    update INVDRPT
      set FQ = FQ - @p_qty, FT = FT - @p_qty * @p_prc,
      LSTUPDTIME = getdate()
      where ASETTLENO = @settleno and ADATE = @cur_date and ASTORE = @store
      and BWRH = @p_wrh and BGDGID = @p_gdgid
    update INVMRPT
      set FQ = FQ - @p_qty, FT = FT - @p_qty * @p_prc
      where ASETTLENO = @settleno and ASTORE = @store
      and BWRH = @p_wrh and BGDGID = @p_gdgid
    update INVYRPT
      set FQ = FQ - @p_qty, FT = FT - @p_qty * @p_prc
      where ASETTLENO = @ysettleno and ASTORE = @store
      and BWRH = @p_wrh and BGDGID = @p_gdgid
  end
  return (0)
end
GO
