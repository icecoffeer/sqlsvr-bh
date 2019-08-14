SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_IUS](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @usergid int,
  @p_src int,
  @p_iline smallint output,
  @p_dline smallint output,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int
  declare @m_gdgid int, @m_qty money, @m_adjcost money,
    @m_newprc money
  
  select @m_gdgid = GDGID, @m_qty = QTY, @m_adjcost = ADJCOST,
    @m_newprc = NEWPRC
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
  
  delete from TMP_IPADTL where SPID = @@spid
  exec @ret_status = RFSIPA2_IUS_INV @p_subwrh, @m_gdgid, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  
  --搜索需要进行成本调整的业务
  if @p_src = @usergid
  begin
    --总部
    exec @ret_status = RFSIPA2_IUS_USE_Z @p_subwrh, @m_gdgid, @err_msg output
    if @ret_status <> 0
    begin
      raiserror(@err_msg, 16, 1)
      return(@ret_status)
    end
    exec @ret_status = RFSIPA2_IUS_USE_ADC @p_subwrh, @usergid, @err_msg output
    if @ret_status <> 0
    begin
      raiserror(@err_msg, 16, 1)
      return(@ret_status)
    end
  end
  
  --计算需要分摊的成本
  if @p_cls = '批次'
    exec @ret_status = RFSIPA2_IUS_ADC_BATCH @p_cls, @p_num, @p_subwrh, 
      @p_src, @usergid, @m_newprc, @err_msg output
  else
    exec @ret_status = RFSIPA2_IUS_ADC_AMOUNT @p_cls, @p_num, @p_subwrh,
      @usergid, @m_qty, @m_adjcost, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
  
  --TMP_IPADTL插入IPA2INVDTL和IPA2DTL
  exec @ret_status = RFSIPA2_IUS_INS @p_cls, @p_num, @p_subwrh, @usergid,
    @p_iline output, @p_dline output, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@ret_status, 16, 1)
    return(@ret_status)
  end

  delete from TMP_IPADTL where SPID = @@spid
  
  return(0)
end
GO
