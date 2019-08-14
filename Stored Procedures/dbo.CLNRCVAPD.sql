SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CLNRCVAPD](
    @p_src int,
    @p_id int
) with encryption as
begin
    declare
    @n_gid int

    select @n_gid = Gid
        from NCLIENT
        where Src = @p_src and Id = @p_id
    if exists (select * from CLIENTH where Gid = @n_gid)
        delete from CLIENTH where Gid = @n_gid
    insert into CLIENT(
        Gid, Code, Name, ShortName, Address,
        TaxNo, AccountNo, Fax, Zip, Tele,
        CreateDate, Property, SettleAccount, PayTerm, Memo,
        LawRep, Contactor, CtrPhone, CtrBP, OutPrc,
        EMailAdr, WWWAdr, IDCard, Addr2, Sex,
        Birthday, Company, Business, Families, Income,
        Hobby, Traffic, Transactor, WeddingDay, FavColor,
        Other, MobilePhone, BP, Balance, MaxOverDraft,
        DetailLevel, Credit, CDTLMT, MasterCln,
        Src, SndTime, LstUpdTime, style)
        select
            Gid, Code, Name, ShortName, Address,
            TaxNo, AccountNo, Fax, Zip, Tele,
            CreateDate, Property, SettleAccount, PayTerm, Memo,
            LawRep, Contactor, CtrPhone, CtrBP,OutPrc,
            EMailAdr, WWWAdr, IDCard, Addr2, Sex,
            Birthday, Company, Business, Families, Income,
            Hobby, Traffic, Transactor, WeddingDay, FavColor,
            Other, MobilePhone, BP, Balance, MaxOverDraft,
            DetailLevel, Credit, CDTLMT, MasterCln,
            Src, null, getdate(), style
            from NCLIENT
            where Src = @p_src and Id = @p_id
    return(0)
end
GO
