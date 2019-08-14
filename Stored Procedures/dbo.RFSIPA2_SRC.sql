SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_SRC](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @usergid int,
  @p_src int,
  @p_line smallint output,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int
  declare @d_bill char(10), @d_billcls char(10), @d_billnum char(10),
    @d_billline smallint, @d_adjflag char(3), @d_itemno int
  declare @a_adjcost money
  declare @m_adjcost money, @m_newprc money
  
  delete from TMP_IPADTL where SPID = @@spid
  
  select @m_adjcost = ADJCOST, @m_newprc = NEWPRC
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
  
  if @p_src = @usergid
    exec @ret_status = RFSIPA2_SRC_SCBILL_Z @p_cls, @p_num, @p_subwrh, @err_msg output
  else
    exec @ret_status = RFSIPA2_SRC_SCBILL_M @p_cls, @p_num, @p_subwrh,
      @usergid, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  
  select @ret_status = 0
  declare c2 cursor for
    select BILL, CLS, NUM, LINE, ADJFLAG, ITEMNO
    from TMP_IPADTL
    where SPID = @@spid
    for update
  open c2
  fetch next from c2 into @d_bill, @d_billcls, @d_billnum, @d_billline,
    @d_adjflag, @d_itemno
  while @@fetch_status = 0
  begin
    exec @ret_status = FETCHBILLADJCOST @d_bill, @d_billcls, @d_billnum, @d_billline,
      @p_subwrh, @d_adjflag, @usergid, @a_adjcost output, @err_msg output
    if @ret_status <> 0 break
    update TMP_IPADTL set A_ADJCOST = @a_adjcost
      where current of c2
    if @p_src = @usergid    --若是总部，TMP_IPADTL应只有一条记录
      update TMP_IPADTL set 
        ADJCOST = case 
          when @p_cls = '金额' then @m_adjcost
          else round(QTY * @m_newprc, 2) - (BILLCOST + A_ADJCOST)   --@p_cls = '批次'
          end
        where current of c2
    insert into IPA2DTL (CLS, NUM, SUBWRH, LINE, STORE,
      BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM,
      WRH, QTY, ADJFLAG, INCOST, OUTCOST,
      ALCAMT, ADJINCOST, ADJOUTCOST, ADJALCAMT, ALCSTORE,
      LACTIME)
      select @p_cls, @p_num, @p_subwrh, @p_line, @usergid,
      BILL, CLS, NUM, LINE, SRCNUM,
      WRH, QTY, ADJFLAG, 
      case when substring(ADJFLAG, 1, 1) = '1' then BILLCOST + A_ADJCOST else 0 end,
      case when substring(ADJFLAG, 2, 1) = '1' then BILLCOST + A_ADJCOST else 0 end,
      case when substring(ADJFLAG, 3, 1) = '1' then BILLCOST + A_ADJCOST else 0 end,
      case when substring(ADJFLAG, 1, 1) = '1' then ADJCOST else 0 end,
      case when substring(ADJFLAG, 2, 1) = '1' then ADJCOST else 0 end,
      case when substring(ADJFLAG, 3, 1) = '1' then ADJCOST else 0 end,
      ALCSTORE, null
      from TMP_IPADTL
      where SPID = @@spid and ITEMNO = @d_itemno
    select @p_line = @p_line + 1
    fetch next from c2 into @d_bill, @d_billcls, @d_billnum, @d_billline,
      @d_adjflag, @d_itemno
  end
  close c2
  deallocate c2
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
  
  delete from TMP_IPADTL where SPID = @@spid

  return(0)
end
GO
