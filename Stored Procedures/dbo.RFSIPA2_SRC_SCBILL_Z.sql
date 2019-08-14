SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_SRC_SCBILL_Z](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @d_inbill char(10), @d_incls char(10), @d_innum char(10),
    @d_inline char(10), @d_gdgid int
    
  select @d_inbill = INBILL, @d_incls = INCLS, @d_innum = INNUM,
    @d_inline = INLINE, @d_gdgid = GDGID
    from IPA2SWDTL where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
    
  -- 产生批次的单据，包括：STKIN（自营）、STKOUTBCK（批发）、
  -- RTLBCK（零售退）、DIRALC（直配出、直销、直销退）、OVF
  if @d_inbill = 'STKIN' and @d_incls = '自营'
    insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
      SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
      select @@spid, 'STKIN', m.CLS, m.NUM, d.LINE,
      m.SRCNUM, d.WRH, d.QTY, '100', d.COST
      from STKIN m, STKINDTL2 d
      where m.CLS = d.CLS and m.NUM = d.NUM and m.CLS = '自营'
      and m.CLS = @d_incls and m.NUM = @d_innum and d.LINE = @d_inline
      and d.SUBWRH = @p_subwrh and d.GDGID = @d_gdgid
  else if @d_inbill = 'STKOUTBCK'
    insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
      SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
      select @@spid, 'STKOUTBCK', m.CLS, m.NUM, d.LINE,
      m.SRCNUM, d.WRH, - d.QTY, '010', - d.COST
      from STKOUTBCK m, STKOUTBCKDTL2 d
      where m.CLS = d.CLS and m.NUM = d.NUM and m.CLS = '批发'
      and m.CLS = @d_incls and m.NUM = @d_innum and d.LINE = @d_inline
      and d.SUBWRH = @p_subwrh and d.GDGID = @d_gdgid
  else if @d_inbill = 'RTLBCK'
    insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
      SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
      select @@spid, 'RTKBCK', '', m.NUM, d.LINE,
      null, d.WRH, - d.QTY, '010', - d.COST
      from RTLBCK m, RTLBCKDTL2 d
      where m.NUM = d.NUM and m.NUM = @d_innum and d.LINE = @d_inline
      and d.SUBWRH = @p_subwrh and d.GDGID = @d_gdgid
  else if @d_inbill = 'OVF'
    insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
      SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
      select @@spid, 'OVF', '', m.NUM, d.LINE,
      null, d.WRH, d.QTY, '100', d.COST
      from OVF m, OVFDTL2 d
      where m.NUM = d.NUM and m.NUM = @d_innum and d.LINE = @d_inline
      and d.SUBWRH = @p_subwrh and d.GDGID = @d_gdgid
  else if @d_inbill = 'DIRALC'
  begin
    if @d_incls not in ('直配出', '直销', '直销退')
    begin
      select @err_msg = '意外发现单据中描述的批次对应的单据不是产生该批次的单据。'
      raiserror(@err_msg, 16, 1)
      return(1)
    end
    insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
      SRCNUM, WRH, QTY, ADJFLAG, BILLCOST,
      ALCSTORE)
      select @@spid, 'DIRALC', m.CLS, m.NUM, d.LINE,
      m.SRCNUM, d.WRH,
      case m.CLS when '直销退' then - d.QTY else d.QTY end, 
      case m.CLS when '直配出' then '111' else '110' end,
      case m.CLS when '直销退' then - d.COST else d.COST end,
      case m.CLS when '直配出' then m.RECEIVER else null end
      from DIRALC m, DIRALCDTL2 d
      where m.CLS = d.CLS and m.NUM = d.NUM 
      and m.CLS = @d_incls and m.NUM = @d_innum and d.LINE = @d_inline
      and d.SUBWRH = @p_subwrh and d.GDGID = @d_gdgid
      and m.CLS in ('直配出', '直销', '直销退')
  end
  else
  begin
    select @err_msg = '意外发现单据中描述的批次对应的单据不是产生该批次的单据。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
    
  return(0) 
end
GO
