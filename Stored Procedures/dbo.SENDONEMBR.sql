SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SENDONEMBR]
  @MbrGID int, --会员GID
  @Store int, --接收门店GID
  @FrcChk smallint --是否强制审核
as
begin
  declare @ID int, @Count int, @Ret smallint
  declare @usergid int,@src int

  select @usergid = usergid from system(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  if @usergid=@Store return 
  select @src= src from member where gid=@MbrGID
  
  if exists(select * from system(nolock) where usergid=zbgid) --总部--added nolock by hxs 2003.03.02任务单号2003030243129
  begin  
    if @store=@src return
  end else begin  --门店
    if @src<>@usergid return
  end  

  execute @ID = SEQNEXTVALUE 'NMEMBER'
  insert into NMEMBER(ID, GID, Code, Name, Address, Zip, Tele,
    EmailAdr, WWWAdr, CdtLmt, IDCard, LastTime, Total, FavAmt,
    TLCnt, TLGD, Addr2, Sex, Company, Business, Families, Income,
    Hobby, Traffic, Transactor, WeddingDay, FavColor, Other,
    MobilePhone, BP, Balance, MaxOverDraft, DetailLevel, Credit,
    MasterCln, BackBuyTotal, Age, CreateDate, Memo, Src, SndTime,
    LstUpdTime, Filler, Modifier, Rcv, RcvTime, FrcChk, NType,
    NStat, NNote)
  select @ID, GID, Code, Name, Address, Zip, Tele,
    EmailAdr, WWWAdr, CdtLmt, IDCard, LastTime, Total, FavAmt,
    TLCnt, TLGD, Addr2, Sex, Company, Business, Families, Income,
    Hobby, Traffic, Transactor, WeddingDay, FavColor, Other,
    MobilePhone, BP, Balance, MaxOverDraft, DetailLevel, Credit,
    MasterCln, BackBuyTotal, Age, CreateDate, Memo, @usergid, GetDate(),
    LstUpdTime, Filler, Modifier, @Store, null, @FrcChk, 0, 0, null
  from MEMBER where GID = @MbrGID

  update member set sndtime = getdate()
	where gid = @mbrGID

end
GO
