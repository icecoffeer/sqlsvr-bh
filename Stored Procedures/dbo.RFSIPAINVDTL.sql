SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RFSIPAINVDTL](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @nextline smallint,
    @cur_settleno int,
    @usergid int,
    @m_gdgid int,
    @m_subwrh int,
    @m_newprc money,
    @o_wrh int,
    @o_subwrh int,
    @o_qty money,
    @o_cost money,
    @o_line smallint,
    @o_style char(10),
    @d_qty money,
    @d_cost money,
    @d_line smallint

  select @ret_status = 0, @usergid = USERGID from SYSTEM
  select @m_gdgid = GDGID, @m_subwrh = SUBWRH, @m_newprc = NEWPRC
    from INPRCADJ
    where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  delete from INPRCADJINVDTL
    where CLS = @p_cls and NUM = @p_num and STORE = @usergid
      and LACTIME is null
  select @nextline = isnull(max(LINE) + 1, 1) from INPRCADJINVDTL
    where CLS = @p_cls and NUM = @p_num
  select @cur_settleno = max(NO) from MONTHSETTLE

  -- 还应考虑内部调拨未提和在途的情况

  if @p_cls = '批次'
    declare c cursor for
      select WRH, SUBWRH, sum(QTY) QTY, sum(COST) COST, 'SWINVMRPT'
      from SUBWRHINV
      where GDGID = @m_gdgid
        and SUBWRH = @m_subwrh
        and QTY <> 0
      group by WRH, SUBWRH
      union
      select m.TOWRH WRH, d.TOSUBWRH SUBWRH, sum(d.QTY) QTY, sum(d.QTY * d.INPRC) COST, 'XF'
      from XF m inner join XFDTL d on m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and m.STAT in (1, 8)
        and d.TOSUBWRH = @m_subwrh
        and d.QTY <> 0
      group by m.TOWRH, d.TOSUBWRH
      for read only
  else
    declare c cursor for
      select WRH, SUBWRH, sum(QTY) QTY, sum(COST) COST, 'SWINVMRPT'
      from SUBWRHINV
      where GDGID = @m_gdgid
        and SUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num)
        and QTY <> 0
      group by WRH, SUBWRH
      union
      select m.TOWRH WRH, d.TOSUBWRH SUBWRH, sum(d.QTY) QTY, sum(d.QTY * d.INPRC) COST, 'XF'
      from XF m inner join XFDTL d on m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and m.STAT in (1, 8)
        and d.TOSUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num)
        and d.QTY <> 0
      group by m.TOWRH, d.TOSUBWRH
      for read only
  open c
  fetch next from c into @o_wrh, @o_subwrh, @o_qty, @o_cost, @o_style
  while @@fetch_status = 0
  begin
  	if @o_style = 'XF'
  	  -- 已经发生的成本调整
  	  select @o_cost = @o_cost + isnull(sum(ADJINCOST), 0)
  	    from INPRCADJDTL
  	    where STORE = @usergid and WRH = @o_wrh and SUBWRH = @o_subwrh and BILL = 'XF' 
  	      and BILLCLS = '调入' and LACTIME is not null
  	select @d_line = LINE, @d_qty = QTY, @d_cost = COST
  	  from INPRCADJINVDTL 
  	  where CLS = @p_cls and NUM = @p_num and WRH = @o_wrh and SUBWRH = @o_subwrh
  	if @@rowcount > 0
  	begin
  	  if @d_qty + @o_qty = 0 and @d_cost + @o_cost = 0
  	    delete from INPRCADJINVDTL where CLS = @p_cls and NUM = @p_num and LINE = @d_line
  	  else
  	    update INPRCADJINVDTL set
  	      QTY = QTY + @o_qty, COST = COST + @o_cost, 
  	      ADJCOST = ADJCOST + round(@m_newprc * @o_qty - @o_cost, 2)
  	      where CLS = @p_cls and NUM = @p_num and LINE = @d_line
  	end else
  	  if @o_qty <> 0 or @o_cost <> 0
  	  begin
        insert into INPRCADJINVDTL (
          CLS, NUM, LINE, SETTLENO, STORE,
          WRH, SUBWRH, QTY, COST, ADJCOST,
          LACTIME, NOTE)
          values(
          @p_cls, @p_num, @nextline, @cur_settleno, @usergid,
          @o_wrh, @o_subwrh, @o_qty, @o_cost, round(@m_newprc * @o_qty - @o_cost, 2),
          null, null)
        select @nextline = @nextline + 1
      end
    fetch next from c into @o_wrh, @o_subwrh, @o_qty, @o_cost, @o_style
  end
  close c
  deallocate c

  -- 整理行号
  select @nextline = 1
  declare c cursor for
    select LINE
    from INPRCADJINVDTL
    where CLS = @p_cls and NUM = @p_num
    order by LINE
    for update
  open c
  fetch next from c into @o_line
  while @@fetch_status = 0
  begin
    update INPRCADJINVDTL set LINE = @nextline
      where CLS = @p_cls and NUM = @p_num and LINE = @o_line
    select @nextline = @nextline + 1
    fetch next from c into @o_line
  end
  close c
  deallocate c

  return(@ret_status)
end

GO
