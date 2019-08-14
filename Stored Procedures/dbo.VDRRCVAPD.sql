SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRRCVAPD](
    @p_src int,
    @p_id int
) with encryption as
begin
    declare
    @n_gid int

    select @n_gid = Gid
        from NVENDOR
        where Src = @p_src and Id = @p_id
    if exists (select * from VENDORH where Gid = @n_gid)
        delete from VENDORH where Gid = @n_gid
    insert into VENDOR(
        Gid, Code, Name, ShortName, Address,
        TaxNo, AccountNo, Fax, Zip, Tele,
        CreateDate, Property, SettleAccount, PayTerm, Memo,
        LawRep, Contactor, CtrPhone, CtrBP,
        days, PayCls, Src, SndTime, LstUpdTime,MVDR, 
        ADFEE, PRMFEE, EMAILADR, WWWADR,KEEPAMT,CDTRATE, 
        INVCODE,ISUSETOKEN, SafeAmt,PAYLIMITED,SendArea,--2003-11-19 --204.11.21
        UpCtrl,	SendType, UPay,	SendLocation,
        BckCycleType,BckBgnMon,BckBgnDays,BckBgnAmt,BckExpRate,BckExpDays,BckLmt, --2006.1.11
        MinDlvQty,MinDlvAmt
        )  
        select
            Gid, Code, Name, ShortName, Address,
            TaxNo, AccountNo, Fax, Zip, Tele,
            CreateDate, Property, SettleAccount, PayTerm, Memo,
            LawRep, Contactor, CtrPhone, CtrBP,
            days, PayCls, Src, null, getdate(), --2001-07-17
            MVDR, ADFEE, PRMFEE, EMAILADR, WWWADR,KEEPAMT,
            CDTRATE, INVCODE,ISUSETOKEN, SafeAmt, PAYLIMITED, SendArea,
            UpCtrl,SendType, UPay, SendLocation,
            BckCycleType,BckBgnMon,BckBgnDays,BckBgnAmt,BckExpRate,BckExpDays,BckLmt,
            MinDlvQty,MinDlvAmt
        from NVENDOR
        where Src = @p_src and Id = @p_id
    return(0)
end
GO
