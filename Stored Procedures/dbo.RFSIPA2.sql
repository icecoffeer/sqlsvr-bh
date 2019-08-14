SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int, @usergid int
  declare @m_src int
  declare @d_subwrh int, @d_gdgid int, @d_adjcost money,
    @d_newprc money, @d_dline smallint, @d_iline smallint
  
  select @usergid = USERGID from SYSTEM
  select @m_src = SRC from IPA2 where CLS = @p_cls and NUM = @p_num

  --初始化
  delete from IPA2INVDTL
    where CLS = @p_cls and NUM = @p_num and LACTIME is null and STORE = @usergid
  delete from IPA2DTL
    where CLS = @p_cls and NUM = @p_num and LACTIME is null and STORE = @usergid
  
  select @ret_status = 0
  declare c1 cursor for
    select SUBWRH, GDGID, ADJCOST, NEWPRC
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num
    for read only
  open c1
  fetch next from c1 into @d_subwrh, @d_gdgid, @d_adjcost, @d_newprc
  while @@fetch_status = 0
  begin
    exec @ret_status = RFSIPA2_LAC @p_cls, @p_num, @d_subwrh, @m_src, @err_msg output
    if @ret_status <> 0 break

    select @d_dline = isnull(max(LINE) + 1, 1) from IPA2DTL
      where CLS = @p_cls and NUM = @p_num and SUBWRH = @d_subwrh
    select @d_iline = isnull(max(LINE) + 1, 1) from IPA2INVDTL
      where CLS = @p_cls and NUM = @p_num and SUBWRH = @d_subwrh
    
    exec @ret_status = RFSIPA2_SRC @p_cls, @p_num, @d_subwrh, @usergid, @m_src,
      @d_dline output, @err_msg output
    if @ret_status <> 0 break
    
    exec @ret_status = RFSIPA2_IUS @p_cls, @p_num, @d_subwrh, @usergid, @m_src,
      @d_iline output, @d_dline output, @err_msg output
    if @ret_status <> 0 break
          
    exec @ret_status = RFSIPA2_SDLAC @p_cls, @p_num, @d_subwrh, @err_msg output
    if @ret_status <> 0 break
    exec @ret_status = RFSIPA2_SDSWDTL @p_cls, @p_num, @d_subwrh, @err_msg output
    if @ret_status <> 0 break
    
    fetch next from c1 into @d_subwrh, @d_gdgid, @d_adjcost, @d_newprc
  end
  close c1
  deallocate c1
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
  
  --刷新IPA2中的合计项
  exec @ret_status = RFSIPA2_SDMASTER @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
  
  return(0)
end
GO
