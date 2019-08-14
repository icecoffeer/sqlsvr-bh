SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2SND_STORE](
  @p_cls char(10),
  @p_num char(10),
  @p_frcflag smallint = 2,
  @p_store int,
  @usergid int,
  @cur_time datetime,
  @err_msg varchar(200) = '' output
) as
begin
  declare @n_billid int
  
  exec GETNETBILLID @n_billid output
  insert into NIPA2 (SRC, ID, CLS, NUM, SETTLENO, 
    VENDOR, CLIENT, ADJCOST, ADJINCOST, ADJINVCOST,
    ADJOUTCOST, ADJALCAMT, FILDATE, FILLER, STAT,
    CHECKER, CHKDATE, CAUSE, NOTE, SNDTIME, RCV,
    RCVTIME, TYPE, NSTAT, FRCFLAG, NNOTE)
    select @usergid, @n_billid, CLS, NUM, SETTLENO,
    VENDOR, CLIENT, ADJCOST, ADJINCOST, ADJINVCOST,
    ADJOUTCOST, ADJALCAMT, FILDATE, FILLER, STAT,
    CHECKER, CHKDATE, CAUSE, NOTE, @cur_time, @p_store,
    null, 0, 0, 1, null
    from IPA2
    where CLS = @p_cls and NUM = @p_num
  insert into NIPA2SWDTL (SRC, ID, SUBWRH, GDGID, INBILL,
    INCLS, INNUM, INLINE, QTY, ADJCOST,
    NEWPRC)
    select @usergid, @n_billid, SUBWRH, GDGID, INBILL,
    INCLS, INNUM, INLINE, QTY, ADJCOST,
    NEWPRC
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num
  insert into NIPA2DTL (SRC, ID, SUBWRH, LINE, STORE,
    BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM,
    WRH, QTY, ADJFLAG, INCOST, OUTCOST,
    ALCAMT, ADJINCOST, ADJOUTCOST, ADJALCAMT, ALCSTORE,
    LACTIME)
    select @usergid, @n_billid, SUBWRH, LINE, STORE,
    BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM,
    WRH, QTY, ADJFLAG, INCOST, OUTCOST,
    ALCAMT, ADJINCOST, ADJOUTCOST, ADJALCAMT, ALCSTORE,
    LACTIME
    from IPA2DTL
    where CLS = @p_cls and NUM = @p_num and STORE = @usergid
    and ALCSTORE = @p_store
  
  return(0)
end
GO
