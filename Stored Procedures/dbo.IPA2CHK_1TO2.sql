SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2CHK_1TO2](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare @usergid int, @cur_settleno int,
    @cur_date datetime
  declare @m_vendor int
  declare @d_subwrh int, @d_inbill char(10), @d_incls char(10),
    @d_innum char(10), @d_gdgid int, @d_adjcost money,
    @d_wrh int, @d_psr int
  
  select @usergid = USERGID from SYSTEM
  select @cur_date = convert(char, getdate(), 102),
    @cur_settleno = max(NO)
    from MONTHSETTLE
    
  update IPA2 set STAT = 2, VRFDATE = getdate()
    where CLS = @p_cls and NUM = @p_num
    
  -- 产生批次，且产生供应商账款的单据，包括：STKIN（自营）、DIRALC（直配出、直销）
  select @m_vendor = VENDOR from IPA2
    where CLS = @p_cls and NUM = @p_num
  if @m_vendor is null return 0
  
  declare c1 cursor for
    select SUBWRH, INBILL, INCLS, INNUM, GDGID, ADJCOST
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num
  open c1
  fetch next from c1 into @d_subwrh, @d_inbill, @d_incls, @d_innum,
    @d_gdgid, @d_adjcost
  while @@fetch_status = 0
  begin
    select @d_wrh = WRH from SUBWRH where GID = @d_subwrh --Modified by wang xin 2003.03.24 取调价批次所在仓位记录帐款
    if @d_inbill = 'STKIN' and @d_incls = '自营'
    begin
      select @d_psr = PSR from STKIN 
        where CLS = @d_incls and NUM = @d_innum
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q, ZJ_A, ZJ_T, ACNT)
        values (@cur_date, @cur_settleno, @d_wrh, @d_gdgid, @m_vendor, @d_psr,
        0, @d_adjcost, 0, 1)
    end
    else if @d_inbill = 'DIRALC' and @d_incls in ('直配出', '直销')
    begin
      select @d_psr = PSR from DIRALC
        where CLS = @d_incls and NUM = @d_innum
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_Q, ZPJ_A, ZPJ_T, ACNT)
        values (@cur_date, @cur_settleno, @d_wrh, @d_gdgid, @m_vendor, @d_psr,
        0, @d_adjcost, 0, 1)
    end
    fetch next from c1 into @d_subwrh, @d_inbill, @d_incls, @d_innum,
      @d_gdgid, @d_adjcost
  end
  close c1
  deallocate c1
  
  --如果批次明细中只有直销退货单，则直接置为“已结”
  if not exists (select 1 from IPA2SWDTL
    where INBILL <> 'DIRALC' or INCLS <> '直销退')
    update IPA2 set FINISHED = 1
      where CLS = @p_cls and NUM = @p_num
  
  return(0)
end
GO
