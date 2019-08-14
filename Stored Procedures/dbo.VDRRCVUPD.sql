SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRRCVUPD](
    @p_src int,
    @p_id int,
    @p_l_gid int
) with encryption as
begin
    update VENDOR
        set
            Code = N.Code, /*2001-06-09*/
            Name = N.Name, ShortName = N.ShortName, Address = N.Address,
            TaxNo = N.TaxNo, AccountNo = N.AccountNo, Fax = N.Fax,
            Zip = N.Zip, Tele = N.Tele, CreateDate = N.CreateDate,
            Property = N.Property, SettleAccount = N.SettleAccount,
            PayTerm = N.PayTerm, Memo = N.Memo, LawRep = N.LawRep,
            Contactor = N.Contactor, CtrPhone = N.CtrPhone, CtrBP = N.CtrBP, DayS= N.Days, --2001-07-17
            PayCls = N.PayCls,
            Src = @p_src, SndTime = null, LstUpdTime = getdate(),
            MVDR=N.MVDR,                  /*2002-08-08*/
            ADFEE =N.ADFEE, PRMFEE = N.PRMFEE, EMAILADR = N.EMAILADR, WWWADR = N.WWWADR,   /*2003-02-28*/
            KEEPAMT =N.KEEPAMT, CDTRATE=N.CDTRATE, INVCODE=N.INVCODE, ISUSETOKEN=N.ISUSETOKEN  /*2003-06-13*/
            ,SafeAmt = N.SafeAmt /*FDY 2003-11-19*/
            ,PayLimited = N.PAYLIMITED
            ,SendArea = N.SendArea /*FDY 2004-11-21*/
            ,UPCTRL = N.UPCTRL, SENDTYPE = N.SENDTYPE, UPAY = N.UPAY, SENDLOCATION = N.SENDLOCATION
            ,BckCycleType = N.BckCycleType --2006.1.11 6000
            ,BckBgnMon    = N.BckBgnMon    
            ,BckBgnDays   = N.BckBgnDays   
            ,BckBgnAmt    = N.BckBgnAmt    
            ,BckExpRate   = N.BckExpRate   
            ,BckExpDays   = N.BckExpDays   
            ,BckLmt       = N.BckLmt       
            ,MinDlvQty    = N.MinDlvQty    
            ,MinDlvAmt    = N.MinDlvAmt    
        from VENDOR C, NVENDOR N
        where C.Gid = @p_l_gid
            and N.Src = @p_src
            and N.Id = @p_Id
    return(0)
end
GO
