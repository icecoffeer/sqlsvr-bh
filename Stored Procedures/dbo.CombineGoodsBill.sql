SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将单据中@store, @settleno, 的商品@oldgdgid, 改成@gdgid
*/
create procedure [dbo].[CombineGoodsBill]
	@store int,
	@settleno int,
	@oldgdgid int,
	@gdgid int
as
begin
	/*订货单(ORD)，进货单(STKIN)，进退单(STKINBCK)，直配单(DIRALC)*/
        /*出货单(STKOUT)，出退单(STKOUTBCK)，零售单(BUY2)*/
        /*调价单(PRCADJ)，促销单(PRCPRM)，损耗单(LS)，溢余单(OVF)，内部调拨单(XF)*/
        /*供应商结算单(PAY)，供应商结算调整单(PAYADJ)，客户结算单(RCP)，客户结算调整单(RCPADJ)*/
        /*盘入单(CK)*/

        if @oldgdgid = @gdgid
        	return(0)
        /*订货单(ORD)*/
	update ORDDTL set GDGID = @gdgid
	from ORD
	where ORDDTL.NUM = ORD.NUM 
		and ORD.SRC = @store and ORD.SETTLENO = @settleno
		and ORDDTL.GDGID = @oldgdgid

        /*进货单(STKIN)*/
	update STKINDTL set GDGID = @gdgid
	from STKIN
	where STKINDTL.NUM = STKIN.NUM 
		and STKINDTL.CLS = STKIN.CLS 
		and STKIN.SRC = @store and STKIN.SETTLENO = @settleno
		and STKINDTL.GDGID = @oldgdgid

        /*进退单(STKINBCK)*/
	update STKINBCKDTL set GDGID = @gdgid
	from STKINBCK
	where STKINBCKDTL.NUM = STKINBCK.NUM 
		and STKINBCKDTL.CLS = STKINBCK.CLS 
		and STKINBCK.SRC = @store and STKINBCK.SETTLENO = @settleno
		and STKINBCKDTL.GDGID = @oldgdgid

	/*直配单(DIRALC)*/
	update DIRALCDTL set GDGID = @gdgid
	from DIRALC
	where DIRALCDTL.NUM = DIRALC.NUM 
		and DIRALCDTL.CLS = DIRALC.CLS 
		and DIRALC.SRC = @store and DIRALC.SETTLENO = @settleno
		and DIRALCDTL.GDGID = @oldgdgid

        /*出货单(STKOUT)*/
	update STKOUTDTL set GDGID = @gdgid
	from STKOUT
	where STKOUTDTL.NUM = STKOUT.NUM 
		and STKOUTDTL.CLS = STKOUT.CLS 
		and STKOUT.SRC = @store and STKOUT.SETTLENO = @settleno
		and STKOUTDTL.GDGID = @oldgdgid

        /*出退单(STKOUTBCK)*/
	update STKOUTBCKDTL set GDGID = @gdgid
	from STKOUTBCK
	where STKOUTBCKDTL.NUM = STKOUTBCK.NUM 
		and STKOUTBCKDTL.CLS = STKOUTBCK.CLS 
		and STKOUTBCK.SRC = @store and STKOUTBCK.SETTLENO = @settleno
		and STKOUTBCKDTL.GDGID = @oldgdgid

	/*零售单(BUY2) 价格怎样改?*/
	update BUY2 set GID = @gdgid
	where SETTLENO = @settleno and GID = @oldgdgid

        /*调价单(PRCADJ)*/
        update PRCADJDTL set GDGID = @gdgid
	from PRCADJ
	where PRCADJDTL.NUM = PRCADJ.NUM 
		and PRCADJDTL.CLS = PRCADJ.CLS 
		and PRCADJ.SRC = @store
		and PRCADJ.SETTLENO = @settleno
		and PRCADJDTL.GDGID = @oldgdgid	
        
        /*促销单(PRCPRM)*/
        update PRCPRMDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	
        
        /*损耗单(LS)*/
	update LSDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

	/*溢余单(OVF)*/
	update OVFDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

        /*内部调拨单(XF)*/
	update XFDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

        /*供应商结算单(PAY)*/
	update PAYDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

        /*供应商结算调整单(PAYADJ)*/
	update PAYADJDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

        /*客户结算单(RCP)*/
	update RCPDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

        /*客户结算调整单(RCPADJ)*/
	update RCPADJDTL set GDGID = @gdgid
	where SETTLENO = @settleno and GDGID = @oldgdgid	

        /*盘入单(CK)*/
        update CKDTL set GDGID = @gdgid
        where SETTLENO = @settleno and GDGID = @oldgdgid
end
GO
