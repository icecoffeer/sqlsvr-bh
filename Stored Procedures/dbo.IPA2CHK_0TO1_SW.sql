SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2CHK_0TO1_SW](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @p_gdgid int,
  @p_qty money,
  @p_adjcost money,
  @p_newprc money,
  @p_cost money,
  @usergid int,
  @cur_settleno int,
  @cur_date datetime,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int
  declare @d_line smallint, @i_invprc money
  
  select @ret_status = 0
  
  -- 审核库存明细
  declare c2 cursor for
    select LINE
    from IPA2INVDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
      and STORE = @usergid and LACTIME is null
    for read only
  open c2
  fetch next from c2 into @d_line
  while @@fetch_status = 0
  begin
    exec @ret_status = IPA2CHK_0TO1_SW_INV @p_cls, @p_num, @p_subwrh, @d_line,
      @p_gdgid, @usergid, @cur_settleno, @cur_date, @err_msg output
    if @ret_status <> 0 break
    fetch next from c2 into @d_line
  end
  close c2
  deallocate c2
  if @ret_status <> 0
    return(@ret_status)
  
  -- 关于SUBWRH表的处理
  select @i_invprc = case when @p_cls = '批次' then @p_newprc 
    else (@p_cost + @p_adjcost) / @p_qty end
  if exists (select 1 from SUBWRH
    where GID = @p_subwrh and GDGID = @p_gdgid)
    update SUBWRH set 
      INPRC = @i_invprc
    where GID = @p_subwrh and GDGID = @p_gdgid
  else
    insert into SUBWRH (GID, CODE, NAME, WRH, GDGID, INPRC)
      values (@p_subwrh, '', '', 1, @p_gdgid, @i_invprc)
      
  -- 审核单据成本调整明细
  declare c2 cursor for
    select LINE
    from IPA2DTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
      and STORE = @usergid and LACTIME is null
    for read only
  open c2
  fetch next from c2 into @d_line
  while @@fetch_status = 0
  begin
    exec @ret_status = IPA2CHK_0TO1_SW_DTL @p_cls, @p_num, @p_subwrh, @d_line,
      @p_gdgid, @usergid, @cur_settleno, @cur_date, @err_msg output
    if @ret_status <> 0 break
    fetch next from c2 into @d_line
  end
  close c2
  deallocate c2
  if @ret_status <> 0
    return(@ret_status)
  
  return(0)
end
GO
