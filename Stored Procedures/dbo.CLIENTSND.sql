SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CLIENTSND] (
  @piGid	int,
  @piRcv	int,
  @piFrcUpd	int, 
  @poMsg varchar(255) output
)
as
begin
  declare 
    @opt_SendOtherClient smallint,
    @opt_SendToOrign smallint,
    @vUserGid int,                  @vSrc int,
    @vProperty int
    
  exec optreadint 27, 'SendOtherClient', 0, @opt_SendOtherClient output
  exec optreadint 27, 'SendToOrign', 0, @opt_SendToOrign output
  select @vUserGid = usergid from system
  select @vSrc = src from client (nolock) where gid = @piGid
  select @vProperty = property from store (nolock) where gid = @vUserGid
  
  if (@opt_SendOtherClient = 1)
    if (@vUserGid <> @vSrc)-- and (@vProperty & 16 <> 16)
    begin
      set @poMsg = '不能发送非本地的客户。'
      return 1
    end
  if (@opt_SendToOrign = 1) 
    if (@piRcv = @vSrc) 
    begin
      set @poMsg = '不能发送客户到来源单位。'
      return 1
    end
    
  insert into NCLIENT (GID, CODE, NAME, SHORTNAME, ADDRESS, TAXNO, 
      ACCOUNTNO, FAX, ZIP, TELE, CREATEDATE, PROPERTY, SETTLEACCOUNT, PAYTERM, PAYCLS, 
      MEMO, SRC, SNDTIME, RCV, RCVTIME, FRCUPD, TYPE, NSTAT, LAWREP,
      CONTACTOR, CTRPHONE, CTRBP, NNOTE, 
      OUTPRC, EMAILADR, WWWADR, CDTLMT, IDCARD, ADDR2, SEX, BIRTHDAY, COMPANY, 
      BUSINESS, FAMILIES, INCOME, HOBBY, TRAFFIC, TRANSACTOR, WEDDINGDAY, 
      FAVCOLOR, OTHER, MOBILEPHONE, BP, BALANCE, MAXOVERDRAFT, DETAILLEVEL, 
      CREDIT, MASTERCLN , STYLE, LSTUPDTIME)
  select GID, CODE, NAME, SHORTNAME, ADDRESS, TAXNO, 
      ACCOUNTNO, FAX, ZIP, TELE, CREATEDATE, PROPERTY, SETTLEACCOUNT, PAYTERM, PAYCLS, 
      MEMO, @vUserGID , getdate(), @piRcv, null, @piFrcUpd, 0, 0, LAWREP, CONTACTOR, CTRPHONE, CTRBP, null, 
      OUTPRC, EMAILADR, WWWADR, CDTLMT, IDCARD, ADDR2, SEX, BIRTHDAY, COMPANY, 
      BUSINESS, FAMILIES, INCOME, HOBBY, TRAFFIC, TRANSACTOR, WEDDINGDAY, 
      FAVCOLOR, OTHER, MOBILEPHONE, BP, BALANCE, MAXOVERDRAFT, DETAILLEVEL, CREDIT, MASTERCLN, STYLE, LSTUPDTIME
  from Client where GID = @piGid

  update CLIENT set SNDTIME = getdate() where GID = @piGid

end
GO
