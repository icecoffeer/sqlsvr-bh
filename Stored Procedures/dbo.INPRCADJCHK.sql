SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[INPRCADJCHK](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @usergid int,
    @cur_date datetime,
    @cur_settleno int,
    @m_stat smallint,
    @m_gdgid int,
    @m_newprc money,
    @d_line smallint

  select @ret_status = 0, @usergid = USERGID from SYSTEM
  select @cur_date = convert(char, getdate(), 102),
    @cur_settleno = max(NO)
    from MONTHSETTLE
  select @m_stat = STAT, @m_gdgid = GDGID, @m_newprc = NEWPRC
    from INPRCADJ
    where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  if @m_stat <> 0
  begin
    select @err_msg = '审核的不是未审核的单据。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end

  update INPRCADJ set STAT = 1, CHKDATE = getdate()
    where CLS = @p_cls and NUM = @p_num

  exec @ret_status = RFSINPRCADJ @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  declare c cursor for
    select LINE
    from INPRCADJINVDTL
    where CLS = @p_cls and NUM = @p_num
      and STORE = @usergid
      and LACTIME is null
    for update
  open c
  fetch next from c into @d_line
  while @@fetch_status = 0
  begin
    exec @ret_status = INPRCADJINVDTLCHK @p_cls, @p_num, @d_line, @m_gdgid, @m_newprc,
      @cur_date, @cur_settleno, @err_msg
    if @ret_status <> 0 break
    fetch next from c into @d_line
  end
  close c
  deallocate c

  if @ret_status = 0
  begin
    declare c cursor for
      select LINE
      from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num
        and STORE = @usergid
        and LACTIME is null
      for update
    open c
    fetch next from c into @d_line
    while @@fetch_status = 0
    begin
      exec @ret_status = INPRCADJDTLCHK @p_cls, @p_num, @d_line, @m_gdgid,
        @cur_date, @cur_settleno, @err_msg
      if @ret_status <> 0 break
      fetch next from c into @d_line
    end
    close c
    deallocate c
  end

  if @ret_status = 0
  begin
    update INPRCADJLACDTL set LACTIME = getdate(), STAT = 1
      where CLS = @p_cls and NUM = @p_num and STORE = @usergid
    if not exists(select 1 from INPRCADJLACDTL
      where CLS = @p_cls and NUM = @p_num and LACTIME is null)
      update INPRCADJ set STAT = 2
        where CLS = @p_cls and NUM = @p_num
  end

  return(@ret_status)
end

GO
