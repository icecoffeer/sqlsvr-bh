SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2RCVGO](
  @p_src int,
  @p_id int,
  @p_checker int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int, @cur_settleno int
  declare @m_frcflag smallint, @m_cls char(10), @m_num char(10)
  declare @nm_vendor int, @nm_client int, @nm_checker int,
    @nd_gdgid int
  declare @lm_vendor int, @lm_client int, @lm_filler int,
    @ld_gdgid int
  declare @d_subwrh int, @ld_line smallint, @nd_line smallint
  
  select @ret_status = 0
  select @cur_settleno = max(NO) from MONTHSETTLE
  select @nm_vendor = VENDOR, @nm_client = CLIENT, @nm_checker = CHECKER,
    @m_frcflag = FRCFLAG, @m_cls = CLS, @m_num = NUM
    from NIPA2
    where SRC = @p_src and ID = @p_id
  
  if exists (select 1 from IPA2 where CLS = @m_cls and NUM = @m_num)
    return(0)
    
  select @lm_vendor = null
  if @nm_vendor is not null
  begin
    select @lm_vendor = LGID from VDRXLATE where NGID = @nm_vendor
    if @@rowcount = 0
    begin
      select @err_msg = '本地未包含供应商资料(GID = ' + rtrim(convert(char, @nm_vendor)) + ')。'
      raiserror(@err_msg, 16, 1)
    end
  end
  
  select @lm_client = null
  if @nm_client is not null
  begin
    select @lm_client = LGID from CLNXLATE where NGID = @nm_client
    if @@rowcount = 0
    begin
      select @err_msg = '本地未包含客户资料(GID = ' + rtrim(convert(char, @nm_client)) + ')。'
      raiserror(@err_msg, 16, 1)
    end
  end
  
  select @lm_filler = LGID from EMPXLATE where NGID = @nm_checker
  if @@rowcount = 0
  begin
    select @err_msg = '本地未包含审核人资料(GID = ' + rtrim(convert(char, @nm_checker)) + ')。'
    raiserror(@err_msg, 16, 1)
  end
  
  --插入单据汇总
  insert into IPA2 (CLS, NUM, SETTLENO, VENDOR, CLIENT,
    ADJCOST, ADJINCOST, ADJINVCOST, ADJOUTCOST, ADJALCAMT,
    FILDATE, FILLER, STAT, LAUNCH, CHECKER,
    CHKDATE, VERIFIER, VRFDATE, SRC, SNDTIME,
    PRNTIME, FINISHED, CAUSE, NOTE, SEARCHINF)
    select CLS, NUM, @cur_settleno, @lm_vendor, @lm_client,
    ADJCOST, ADJINCOST, ADJINVCOST, ADJOUTCOST, ADJALCAMT,
    FILDATE, @lm_filler, 0, 0, @p_checker,
    getdate(), null, null, SRC, null,
    null, 0, CAUSE, NOTE, null
    from NIPA2
    where SRC = @p_src and ID = @p_id
  
  declare c1 cursor for
    select SUBWRH, GDGID
    from NIPA2SWDTL
    where SRC = @p_src and ID = @p_id
    for read only
  open c1
  fetch next from c1 into @d_subwrh, @nd_gdgid
  while @@fetch_status = 0
  begin
    select @ld_gdgid = LGID from GDXLATE where NGID = @nd_gdgid
    if @@rowcount = 0
    begin
      select @err_msg = '本地未包含商品资料(GID = ' + rtrim(convert(char, @nd_gdgid)) + ')。'
      select @ret_status = 1
      break
    end
    --插入单据批次明细
    insert into IPA2SWDTL (CLS, NUM, SUBWRH, GDGID, INBILL,
      INCLS, INNUM, INLINE, INCHKDATE, QTY,
      ADJCOST, NEWPRC)
      select @m_cls, @m_num, SUBWRH, @ld_gdgid, INBILL,
      INCLS, INNUM, INLINE, null, QTY,
      ADJCOST, NEWPRC 
      from NIPA2SWDTL
      where SRC = @p_src and ID = @p_id and SUBWRH = @d_subwrh
      
    --插入单据成本调整明细
    select @ld_line = 0
    declare c2 cursor for
      select LINE
      from NIPA2DTL
      where SRC = @p_src and ID = @p_id and SUBWRH = @d_subwrh
      for read only
    open c2
    fetch next from c2 into @nd_line
    while @@fetch_status = 0
    begin
      insert into IPA2DTL (CLS, NUM, SUBWRH, LINE, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM,
        WRH, QTY, ADJFLAG, INCOST, OUTCOST,
        ALCAMT, ADJINCOST, ADJOUTCOST, ADJALCAMT, ALCSTORE,
        LACTIME)
        select @m_cls, @m_num, @d_subwrh, @ld_line, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM,
        WRH, QTY, ADJFLAG, INCOST, OUTCOST,
        ALCAMT, ADJINCOST, ADJOUTCOST, ADJALCAMT, ALCSTORE,
        LACTIME
        from NIPA2DTL
        where SRC = @p_src and ID = @p_id and SUBWRH = @d_subwrh
        and LINE = @nd_line
      select @ld_line = @ld_line + 1
      fetch next from c2 into @nd_line
    end
    close c2
    deallocate c2
    
    fetch next from c1 into @d_subwrh, @nd_gdgid
  end
  close c1
  deallocate c1
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end
    
  --自动审核单据
  if @m_frcflag <> 0
  begin
    exec @ret_status = IPA2CHK @m_cls, @m_num, @m_frcflag, @err_msg output
    if @ret_status <> 0
    begin
      raiserror(@err_msg, 16, 1)
      return(@ret_status)
    end
  end
  
  return(0)
end
GO
