SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2CHK_0TO1](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int, @usergid int, @cur_settleno int,
    @cur_date datetime
  declare @d_subwrh int, @d_gdgid int, @d_qty money,
    @d_adjcost money, @d_newprc money, @d_cost money
  
  select @ret_status = 0, @usergid = USERGID from SYSTEM
  select @cur_date = convert(char, getdate(), 102),
    @cur_settleno = max(NO)
    from MONTHSETTLE
  exec @ret_status = RFSIPA2 @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  
  update IPA2 set STAT = 1, CHKDATE = getdate()
    where CLS = @p_cls and NUM = @p_num
    
  declare c1 cursor for
    select SUBWRH, GDGID, QTY, ADJCOST, NEWPRC, COST
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num
    for read only
  open c1
  fetch next from c1 into @d_subwrh, @d_gdgid, 
    @d_qty, @d_adjcost, @d_newprc, @d_cost
  while @@fetch_status = 0
  begin
    exec @ret_status = IPA2CHK_0TO1_SW @p_cls, @p_num, @d_subwrh, @d_gdgid,
      @d_qty, @d_adjcost, @d_newprc, @d_cost, @usergid, @cur_settleno, @cur_date,
      @err_msg output
    if @ret_status <> 0 break
    fetch next from c1 into @d_subwrh, @d_gdgid, 
      @d_qty, @d_adjcost, @d_newprc, @d_cost
  end
  close c1
  deallocate c1
  if @ret_status <> 0
    return(@ret_status)
  
  return(0)
end
GO
