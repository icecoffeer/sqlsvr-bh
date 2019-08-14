SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2SND](
  @p_cls char(10),
  @p_num char(10),
  @p_frcflag smallint = 2,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int, @usergid int, @cur_time datetime
  declare @m_stat smallint, @m_src int
  declare @d_store int
  
  select @usergid = USERGID, @cur_time = getdate() from SYSTEM
  select @m_stat = STAT, @m_src = SRC
    from IPA2 where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  if @m_stat = 0
  begin
    select @err_msg = '发送的不是已审核的单据。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  
  declare c cursor for
    select distinct STORE
    from IPA2LACDTL
    where CLS = @p_cls and NUM = @p_num and store<>@usergid
    for read only
  open c
  fetch next from c into @d_store
  while @@fetch_status = 0
  begin
    exec @ret_status = IPA2SND_STORE @p_cls, @p_num, @p_frcflag, @d_store,
      @usergid, @cur_time, @err_msg output
    if @ret_status <> 0 break
    fetch next from c into @d_store
  end
  close c
  deallocate c
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
  
  update IPA2 set SNDTIME = getdate()
    where CLS = @p_cls and NUM = @p_num
  
  return(0)
end
GO
