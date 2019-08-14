SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
cREATE procedure [dbo].[LOADIN](
  @p_wrh int,
  @p_gdgid int,
  @p_qty money,
  @p_prc money,
  @p_validdate datetime,
  /* 2000-10-24 */
  @p_updordqty smallint = 1
) with encryption as
begin
  declare
    @g_chkvd smallint,
    @w_chkvd smallint,
    @qty money,
    @total money,
    @ordqty money,
    @ysettleno int,
    @settleno int,
    @cur_date datetime,
    @store int,
    @msg varchar(200)

  select @g_chkvd = CHKVD from GOODS where GID = @p_gdgid
  select @w_chkvd = CHKVD from WAREHOUSE where GID = @p_wrh
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

--  if @p_validdate is null begin	/*2003.04.09*/
    if not exists ( select * from INV where WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store)
      insert into INV (STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
      values (@store, @p_wrh, @p_gdgid, 0, 0, @p_validdate)
    select
      @qty = QTY + @p_qty,
      @total = TOTAL + @p_qty * @p_prc
/*2006.12.08 deleted by zhanglong, 删除对在单量的影响*/
--      @ordqty = ORDQTY
      from INV
      where  WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store
--    if @p_qty > 0 /* 防止LOADIN负数量 */ /* 2000-10-24 */ and @p_updordqty = 1
--    begin
--      select @ordqty = @ordqty - @p_qty
--      if @ordqty < 0 select @ordqty = 0
--    end
    update INV
      set QTY = @qty, TOTAL = @total--, ORDQTY = @ordqty
      where  WRH = @p_wrh and GDGID = @p_gdgid and STORE = @store
/*end*/


/*  end else begin  --2003.04.09
    if not exists ( select * from INV where WRH = @p_wrh and GDGID = @p_gdgid
      and VALIDDATE = @p_validdate and STORE = @store) begin
      insert into INV (STORE, WRH, GDGID, QTY, TOTAL, VALIDDATE)
      values (@store, @p_wrh, @p_gdgid, 0, 0, @p_validdate)
    end
    select
      @qty = QTY + @p_qty,
      @total = TOTAL + @p_qty * @p_prc,
      @ordqty = ORDQTY
      from INV
      where  WRH = @p_wrh and GDGID = @p_gdgid and VALIDDATE = @p_validdate
      and STORE = @store
    if @p_qty > 0  and @p_updordqty = 1
    begin
      select @ordqty = @ordqty - @p_qty
      if @ordqty < 0 select @ordqty = 0
    end
    update INV
      set QTY = @qty, TOTAL = @total, ORDQTY = @ordqty
      where WRH = @p_wrh and GDGID = @p_gdgid and VALIDDATE = @p_validdate
      and STORE = @store
  end*/
  /* 修改报表 */
  if @store = (select usergid from system)
  begin
    select @settleno = max(NO) from MONTHSETTLE
    select @cur_date = convert(datetime, convert(char, getdate(), 102))
    select @ysettleno = max(NO) from YEARSETTLE
    execute CRTINVRPT @store, @settleno, @cur_date, @p_wrh, @p_gdgid
    update INVDRPT
      set FQ = FQ + @p_qty, FT = FT + @p_qty * @p_prc,
      LSTUPDTIME = getdate()
      where ASETTLENO = @settleno and ADATE = @cur_date and ASTORE = @store
      and BWRH = @p_wrh and BGDGID = @p_gdgid
    update INVMRPT
      set FQ = FQ + @p_qty, FT = FT + @p_qty * @p_prc
      where ASETTLENO = @settleno and ASTORE = @store
      and BWRH = @p_wrh and BGDGID = @p_gdgid
    update INVYRPT
      set FQ = FQ + @p_qty, FT = FT + @p_qty * @p_prc
      where ASETTLENO = @ysettleno and ASTORE = @store
      and BWRH = @p_wrh and BGDGID = @p_gdgid
  end
end
GO
