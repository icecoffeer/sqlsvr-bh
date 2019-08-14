SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_IUS_INS](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @usergid int,
  @p_iline smallint output,
  @p_dline smallint output,
  @err_msg varchar(200) = '' output
) as
begin
  declare @d_bill char(10), @d_billcls char(10), @d_billnum char(10),
    @d_billline smallint, @d_billsrcnum char(10), @d_wrh int,
    @d_qty money, @d_adjflag char(3), @d_cost money,
    @d_adjcost money, @d_alcstore int
  
  declare c2 cursor for
    select BILL, CLS, NUM, LINE, SRCNUM,
      WRH, QTY, ADJFLAG, BILLCOST + A_ADJCOST, ADJCOST, ALCSTORE
    from TMP_IPADTL
    where SPID = @@spid
    for read only
  open c2
  fetch next from c2 into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
    @d_wrh, @d_qty, @d_adjflag, @d_cost, @d_adjcost, @d_alcstore
  while @@fetch_status = 0
  begin
    if @d_bill = '库存'
    begin
      insert into IPA2INVDTL (CLS, NUM, SUBWRH, LINE, STORE,
        WRH, QTY, COST, ADJCOST, LACTIME)
        values (@p_cls, @p_num, @p_subwrh, @p_iline, @usergid,
        @d_wrh, @d_qty, @d_cost, @d_adjcost, null)
      select @p_iline = @p_iline + 1
    end
    else  
    begin
      insert into IPA2DTL (CLS, NUM, SUBWRH, LINE, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM,
        WRH, QTY, ADJFLAG, INCOST, OUTCOST, ALCAMT,
        ADJINCOST, ADJOUTCOST, ADJALCAMT, ALCSTORE, LACTIME)
        values (@p_cls, @p_num, @p_subwrh, @p_dline, @usergid,
        @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
        @d_wrh, @d_qty, @d_adjflag,
        case when substring(@d_adjflag, 1, 1) = '1' then @d_cost else 0 end,
        case when substring(@d_adjflag, 2, 1) = '1' then @d_cost else 0 end,
        case when substring(@d_adjflag, 3, 1) = '1' then @d_cost else 0 end,
        case when substring(@d_adjflag, 1, 1) = '1' then @d_adjcost else 0 end,
        case when substring(@d_adjflag, 2, 1) = '1' then @d_adjcost else 0 end,
        case when substring(@d_adjflag, 3, 1) = '1' then @d_adjcost else 0 end,
        @d_alcstore, null)
      select @p_dline = @p_dline + 1
    end
    fetch next from c2 into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
      @d_wrh, @d_qty, @d_adjflag, @d_cost, @d_adjcost, @d_alcstore
  end
  close c2
  deallocate c2
  
  return(0)
end
GO
