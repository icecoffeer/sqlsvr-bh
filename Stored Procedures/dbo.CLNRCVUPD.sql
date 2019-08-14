SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CLNRCVUPD](
    @p_src int,
    @p_id int,
    @p_l_gid int
) with encryption as
begin
    update CLIENT
        set
            Code = N.Code, /*2001-06-09*/
            Name = N.Name, ShortName = N.ShortName, Address = N.Address,
            TaxNo = N.TaxNo, AccountNo = N.AccountNo, Fax = N.Fax,
            Zip = N.Zip, Tele = N.Tele, CreateDate = N.CreateDate,
            Property = N.Property, SettleAccount = N.SettleAccount,
            PayTerm = N.PayTerm, Memo = N.Memo, LawRep = N.LawRep,
            Contactor = N.Contactor, CtrPhone = N.CtrPhone, CtrBP = N.CtrBP,
            OutPrc = N.OutPrc, EMailAdr = N.EMailAdr, WWWAdr = N.WWWAdr,
            IDCard = N.IDCard, Addr2 = N.Addr2, Sex = N.Sex,
            Birthday = N.Birthday, Company = N.Company, Business = N.Business,
            Families = N.Families, Income = N.Income, Hobby = N.Hobby,
            Traffic = N.Traffic, Transactor = N.Transactor, WeddingDay = N.WeddingDay,
            FavColor = N.FavColor, Other = N.Other, MobilePhone = N.MobilePhone,
            BP = N.BP, MaxOverDraft = N.MaxOverDraft, DetailLevel = N.DetailLevel,
            Credit = N.Credit, MasterCln = N.MasterCln,
            /*Src = @p_src ,2002-08-08 */ SndTime = null, LstUpdTime = isnull(N.LstUpdTime, getdate()), style = N.style
        from CLIENT C, NCLIENT N
        where C.Gid = @p_l_gid
            and N.Src = @p_src
            and N.Id = @p_Id
    return(0)
end
GO
