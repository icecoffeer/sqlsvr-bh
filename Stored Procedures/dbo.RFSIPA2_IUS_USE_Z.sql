SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_IUS_USE_Z](
  @p_subwrh int,
  @p_gdgid int,
  @err_msg varchar(200) = '' output
) as
begin
  --使用批次的单据：STKINBCK（自营）, STKOUT（批发、配货）, STKOUTBCK（配货）,
  --RTL, XF, LS, DIRALC（直配出退）, MXF
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'STKINBCK', m.CLS, m.NUM, d.LINE,
    m.SRCNUM, d.WRH, - d.QTY, '100', - d.COST
    from STKINBCK m, STKINBCKDTL2 d
    where m.CLS = d.CLS and m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh and m.CLS = '自营'
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST, ALCSTORE)
    select @@spid, 'STKOUT', m.CLS, m.NUM, d.LINE,
    m.SRCNUM, d.WRH, d.QTY,
    case when m.CLS = '配货' then '011' else '010' end,
    d.COST,
    case when m.CLS = '配货' then m.CLIENT else null end
    from STKOUT m, STKOUTDTL2 d
    where m.CLS = d.CLS and m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh and m.CLS in ('批发', '配货')
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'STKOUTBCK', m.CLS, m.NUM, d.LINE,
    m.SRCNUM, d.WRH, - d.QTY, '010', - d.COST
    from STKOUTBCK m, STKOUTBCKDTL2 d
    where m.CLS = d.CLS and m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh and d.CLS = '配货'
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'RTL', '', m.NUM, d.LINE,
    null, d.WRH, d.QTY, '010', d.COST
    from RTL m, RTLDTL2 d
    where m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'LS', '', m.NUM, d.LINE,
    null, d.WRH, d.QTY, '010', d.COST
    from LS m, LSDTL2 d
    where m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'DIRALC', m.CLS, m.NUM, d.LINE,
    null, d.WRH, - d.QTY, '110', - d.COST
    from DIRALC m, DIRALCDTL2 d
    where m.CLS = d.CLS and m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh and m.CLS = '直配出退'

  -- XF
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'XF', '调出', m.NUM, d.LINE,
    null, d.WRH, d.QTY, '010', d.COST
    from XF m, XFDTL2 d
    where m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
    and d.FROMTO = -1
  --内部调拨单调出<==>调拨间仓调入
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'XF', '调入', m.NUM, d.LINE,
    null, -100, d.QTY, '100', d.COST
    from XF m, XFDTL2 d
    where m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
    and d.FROMTO = -1
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'XF', '调入', m.NUM, d.LINE,
    null, d.WRH, d.QTY, '100', d.COST
    from XF m, XFDTL2 d
    where m.NUM = d.NUM and m.STAT in (9)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
    and d.FROMTO = 1
  --内部调拨单调入<==>调拨间仓调出
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'XF', '调出', m.NUM, d.LINE,
    null, -100, d.QTY, '010', d.COST
    from XF m, XFDTL2 d
    where m.NUM = d.NUM and m.STAT in (9)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
    and d.FROMTO = 1
    
  -- MXF
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST)
    select @@spid, 'MXF', '调出', m.NUM, d.LINE,
    null, d.WRH, d.QTY, '100', d.COST
    from MXF m, MXFDTL2 d
    where m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
    and d.FROMTO = -1
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    SRCNUM, WRH, QTY, ADJFLAG, BILLCOST, ALCSTORE)
    select @@spid, 'MXF', '调入', m.NUM, d.LINE,
    null, d.WRH, d.QTY, '011', d.COST, m.TOSTORE
    from MXF m, MXFDTL2 d
    where m.NUM = d.NUM and m.STAT not in (0, 7)
    and d.GDGID = @p_gdgid and d.SUBWRH = @p_subwrh
    and d.FROMTO = 1
  
  return(0)
end
GO
