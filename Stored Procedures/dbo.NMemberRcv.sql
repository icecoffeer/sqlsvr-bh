SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
	2003.05.29增加对会员代码的判断　added by hxs
*/
create procedure [dbo].[NMemberRcv]
  @ID int,
  @Src int
as
begin
  declare @usergid int,@GID int,@lsrc int,@lLstUpdTime datetime,@nLstUpdTime datetime,@rcv int
  
  declare @curgid int,@ncode varchar(20),@curcode varchar(20)

  select @usergid = usergid from system(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  if @Src=@usergid 
  begin
    delete from NMEMBER where ID = @ID and Src = @Src
    return
  end
 
  select @GID = GID,@ncode = code,@nLstUpdTime=LstUpdTime,@rcv=rcv from NMember where ID = @ID and Src = @Src
  if @rcv<>@usergid
  begin
    delete from NMEMBER where ID = @ID and Src = @Src
    return
  end
  select @curgid from  member where code = @ncode
  if @curgid <> @gid 
  begin
	update nmember set nnote = '代码已经被另外的会员使用了。' where src = @src and id = @id
	return
  end

  select @lsrc = src,@lLstUpdTime=LstUpdTime from Member where GID = @GID
  if (@@rowcount=1) and ((@lsrc=@usergid) or (@nLstUpdTime<=@lLstUpdTime))
  begin
    delete from NMEMBER where ID = @ID and Src = @Src
    return
  end else begin
   delete from Member  where GID = @GID
   delete from MemberH where GID = @GID
  end

    insert into MEMBER(GID, Code, Name, Address, Zip, Tele,
      EmailAdr, WWWAdr, CdtLmt, IDCard, LastTime, Total, FavAmt,
      TLCnt, TLGD, Addr2, Sex, Company, Business, Families, Income,
      Hobby, Traffic, Transactor, WeddingDay, FavColor, Other,
      MobilePhone, BP, Balance, MaxOverDraft, DetailLevel, Credit,
      MasterCln, BackBuyTotal, Age, CreateDate, Memo, Src, SndTime,
      LstUpdTime, Filler, Modifier)
    select GID, Code, Name, Address, Zip, Tele,
      EmailAdr, WWWAdr, CdtLmt, IDCard, LastTime, Total, FavAmt,
      TLCnt, TLGD, Addr2, Sex, Company, Business, Families, Income,
      Hobby, Traffic, Transactor, WeddingDay, FavColor, Other,
      MobilePhone, BP, Balance, MaxOverDraft, DetailLevel, Credit,
      MasterCln, BackBuyTotal, Age, CreateDate, Memo, Src, SndTime,
      LstUpdTime, Filler, Modifier
    from NMEMBER where ID = @ID and Src = @Src

  delete from NMEMBER where ID = @ID and Src = @Src
end
GO
