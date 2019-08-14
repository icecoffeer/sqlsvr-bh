SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_IUS_USE_ADC](
  @p_subwrh int,
  @usergid int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int
  declare @d_bill char(10), @d_billcls char(10), @d_billnum char(10),
    @d_billline smallint, @d_adjflag char(3), @d_adjcost money
  
  select @ret_status = 0
  declare c2 cursor for
    select BILL, CLS, NUM, LINE, ADJFLAG
    from TMP_IPADTL
    where SPID = @@spid and BILL <> '库存'
    for update
  open c2
  fetch next from c2 into @d_bill, @d_billcls, @d_billnum, @d_billline,
    @d_adjflag
  while @@fetch_status = 0
  begin
    exec @ret_status = FETCHBILLADJCOST @d_bill, @d_billcls, @d_billnum, @d_billline,
      @p_subwrh, @d_adjflag, @usergid, @d_adjcost output, @err_msg output
    if @ret_status <> 0 break
    update TMP_IPADTL set A_ADJCOST = @d_adjcost
      where current of c2
    fetch next from c2 into @d_bill, @d_billcls, @d_billnum, @d_billline,
      @d_adjflag
  end
  close c2
  deallocate c2
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
  
  return(0)
end
GO
