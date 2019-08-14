SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RFSINPRCADJ](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @o_adjincost money,
    @o_adjoutcost money,
    @o_adjamt money,
    @o_adjinvcost money,
    @d_store int

  exec @ret_status = RFSIPALACDTL @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  exec @ret_status = RFSIPAAINVDTL @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  exec @ret_status = RFSIPADTL @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  exec @ret_status = RFSIPAINVDTL @p_cls, @p_num, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  declare c cursor for
    select STORE
    from INPRCADJLACDTL
    where CLS = @p_cls and NUM = @p_num
    for update
  open c
  fetch next from c into @d_store
  while @@fetch_status = 0
  begin
    select @o_adjincost = isnull(sum(ADJINCOST), 0),
      @o_adjoutcost = isnull(sum(ADJOUTCOST), 0),
      @o_adjamt = isnull(sum(ADJAMT), 0)
      from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num
        and STORE = @d_store
    select @o_adjinvcost = isnull(sum(ADJCOST), 0)
      from INPRCADJINVDTL
      where CLS = @p_cls and NUM = @p_num
        and STORE = @d_store
    update INPRCADJLACDTL set
      INADJAMT = @o_adjincost,
      INVADJAMT = @o_adjinvcost,
      OUTADJAMT = @o_adjoutcost,
      ALCADJAMT = @o_adjamt
      where CLS = @p_cls and NUM = @p_num
        and STORE = @d_store
    fetch next from c into @d_store
  end
  close c
  deallocate c

  select @o_adjincost = isnull(sum(ADJINCOST), 0),
    @o_adjoutcost = isnull(sum(ADJOUTCOST), 0),
    @o_adjamt = isnull(sum(ADJAMT), 0)
    from INPRCADJDTL
    where CLS = @p_cls and NUM = @p_num
  select @o_adjinvcost = isnull(sum(ADJCOST), 0)
    from INPRCADJINVDTL
    where CLS = @p_cls and NUM = @p_num
  update INPRCADJ set
    INADJAMT = @o_adjincost,
    INVADJAMT = @o_adjinvcost,
    OUTADJAMT = @o_adjoutcost,
    ALCADJAMT = @o_adjamt
    where CLS = @p_cls and NUM = @p_num

  return(0)
end

GO
