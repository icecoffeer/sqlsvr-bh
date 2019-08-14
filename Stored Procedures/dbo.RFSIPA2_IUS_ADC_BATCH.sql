SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_IUS_ADC_BATCH](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @p_src int,
  @usergid int,
  @p_newprc money,
  @err_msg varchar(200) = '' output
) as
begin
  declare @d_wrh int
  declare @d_itemno int, @d_bill char(10), @d_qty money, @d_cost money,
    @d_adjcost money
  declare @d_adjincost money, @d_adjinvcost money, @d_inqty money,
    @d_invqty money, @d_incost money, @d_invcost money
  
  -- 计算TMP_IPADTL中所有业务的本次成本调整额
  declare c2 cursor for
    select ITEMNO, QTY, BILLCOST + A_ADJCOST
    from TMP_IPADTL
    where SPID = @@spid and BILL <> '出货'
    for read only
  open c2
  fetch next from c2 into @d_itemno, @d_qty, @d_cost
  while @@fetch_status = 0
  begin
    select @d_adjcost = round(@d_qty * @p_newprc, 2) - @d_cost
    update TMP_IPADTL set ADJCOST = @d_adjcost
      where SPID = @@spid and ITEMNO = @d_itemno
    fetch next from c2 into @d_itemno, @d_qty, @d_cost
  end
  close c2
  deallocate c2
  
  if @p_src <> @usergid
  begin
    -- 对于门店，检查每个仓位，对于(本次进货成本调整额-本次库存成本调整额<>0)的
    -- 仓位，将该差额作为出货成本调整额加入TMP_IPADTL。
    declare c2 cursor for
      select GID
      from WAREHOUSEH
      for read only
    open c2
    fetch next from c2 into @d_wrh
    while @@fetch_status = 0
    begin
      select @d_adjincost = isnull(sum(ADJINCOST), 0),
        @d_inqty = isnull(sum(QTY), 0),
        @d_incost = isnull(sum(INCOST), 0)
        from IPA2DTL
        where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
        and STORE = @usergid and WRH = @d_wrh
      select @d_adjinvcost = isnull(sum(ADJCOST), 0),
        @d_invqty = isnull(sum(QTY), 0),
        @d_invcost = isnull(sum(BILLCOST + A_ADJCOST), 0)
        from TMP_IPADTL
        where SPID = @@spid and BILL = '库存' and WRH = @d_wrh
      if @d_inqty - @d_invqty <> 0
        or @d_adjincost - @d_adjinvcost <> 0
        insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
          WRH, QTY, ADJFLAG, BILLCOST, ADJCOST)
          values (@@spid, '出货', '', '', 1,
          @d_wrh, @d_inqty - @d_invqty, '010', @d_incost - @d_invcost,
          @d_adjincost - @d_adjinvcost)
      fetch next from c2 into @d_wrh
    end
    close c2
    deallocate c2
  end
  
  return(0)
end
GO
