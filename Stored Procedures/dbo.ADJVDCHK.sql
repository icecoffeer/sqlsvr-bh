SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[ADJVDCHK](
  @p_num char(10)
) with encryption as
begin
  declare
    @m_num char(10),
    @m_filler int,
    @m_fildate datetime,
    @m_wrh int,
    @e_gdgid int,
    @e_qty money,
    @f_qty money,
    @e_total money,
    @f_total money,
    @g_error smallint,
    @gdgid int,
    @qty money,
    @prc money,
    @total money,
    @validdate datetime,
    @prctype smallint,
    @store int,
    @m_wrh_saved int

  select
    @m_num = NUM,
    @m_filler = FILLER,
    @m_fildate = FILDATE,
    @m_wrh = WRH,
    @m_wrh_saved = WRH
    from ADJVD where NUM = @p_num

  /* 如果这个仓位是一个门店 */
  select @store = null
  select @store = GID from STORE where GID = @m_wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @m_wrh = 1

  select
    @g_error = 0
  declare c_adjvdc cursor for select GDGID, SUM(QTY), SUM(TOTAL) from ADJVDDTL
    where NUM = @p_num group by GDGID
  open c_adjvdc
  fetch next from c_adjvdc into @e_gdgid, @e_qty, @e_total
  while @@fetch_status = 0 begin
    select @f_qty = sum(QTY), @f_total = SUM(TOTAL)
      from INV where WRH = @m_wrh and GDGID = @e_gdgid and STORE = @store
    -- 对非可变价商品,检查数量相等;对可变价商品,检查金额误差在0.1以内
    select @prctype = PRCTYPE from GOODS where GID = @e_gdgid
    if @prctype = 0 begin
      if @f_qty <> @e_qty begin
        select @g_error = 1
        break
      end
    end else begin
      if abs(@f_total - @e_total) > 0.1 begin
        select @g_error = 1
        break
      end
    end
    delete from INV where WRH = @m_wrh and GDGID = @e_gdgid and STORE = @store
    fetch next from c_adjvdc into @e_gdgid, @e_qty, @e_total
  end
  close c_adjvdc
  deallocate c_adjvdc
  if @g_error = 1 begin
    raiserror('调整前后库存数量或金额不同.', 16, 1)
    return(1)
  end
  declare c_adjvd cursor for
    select GDGID, QTY, TOTAL, VALIDDATE from ADJVDDTL where NUM = @p_num
    for update
  open c_adjvd
  fetch next from c_adjvd into @gdgid, @qty, @total, @validdate
  while @@fetch_status = 0 begin
    -- 对非可变价商品,使用当前RTLPRC更新金额
    select @prctype = PRCTYPE, @prc = RTLPRC from GOODS where GID = @gdgid
    if @prctype = 0
      update ADJVDDTL set TOTAL = @qty * @prc where current of c_adjvd
    else
       select @prc = @total / @qty
    execute @g_error = LOADIN @m_wrh_saved, @gdgid, @qty, @prc, @validdate
    if @g_error <> 0 break
    fetch next from c_adjvd into @gdgid, @qty, @total, @validdate
  end
  close c_adjvd
  deallocate c_adjvd
  if @g_error <> 0 begin
    return(@g_error)
  end
end
GO
