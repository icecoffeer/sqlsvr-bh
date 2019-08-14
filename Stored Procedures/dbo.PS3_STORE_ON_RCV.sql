SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_STORE_ON_RCV] (
  @piOper varchar(40),
  @poErrMsg varchar(255) output
) with encryption as
begin
  declare
    @gid int,
    @ret int
   --更新STORE  
  declare cur_nstore_rcv cursor for
    select a.GID from NSTORE a(nolock), STORE(nolock) where a.TYPE = 1 and a.GID = STORE.GID
  open cur_nstore_rcv
  fetch next from cur_nstore_rcv into @gid
  while @@fetch_status = 0
  begin
    update STORE set CODE = a.CODE,
			NAME = a.NAME,
			ADDRESS = a.ADDRESS,
			PHONE = a.PHONE,
			CONTACTOR = a.CONTACTOR,
			UPD = a.UPD,
			PROPERTY = a.PROPERTY,
			SNDFLAG = a.SNDFLAG,
			SVRNAME = a.SVRNAME,
			MAINDB = a.MAINDB,
			POOLDB = a.POOLDB,
			DOMAIN = a.DOMAIN,
			OSUSERNAME = a.OSUSERNAME,
			OSPWD = a.OSPWD,
			DBUSERNAME = a.DBUSERNAME,
			DBPWD = a.DBPWD,
			SYSPATH = a.SYSPATH,
            E_MAIL = a.E_MAIL ,        
            MAILPWD = a.MAILPWD ,
            E_MAILPHONE = a.E_MAILPHONE ,
            POP3 = a.POP3 ,
            SMTP = a.SMTP ,
            COMMPHONE = a.COMMPHONE ,
            VERSION = a.VERSION ,
            DBMS = a.DBMS ,
            mailacct = a.mailacct ,
            E_MAIL2 = a.E_MAIL2 ,
            MAILPWD2 = a.MAILPWD2 ,
            E_MAILPHONE2 = a.E_MAILPHONE2  ,
            POP32 = a.POP32 ,
            SMTP2 = a.SMTP2 ,
            mailacct2 = a.mailacct2 ,
            FTPServer = a.FTPServer ,
            FTPUser = a.FTPUser ,
            FTPPwd = a.FTPPwd ,
            FTPPortNO = a.FTPPortNO ,
            FTPDir = a.FTPDir,
            UPPERORG = a.UPPERORG
	  from NSTORE a
	  where a.GID = STORE.GID
	  and a.GID = @gid
     exec @ret = PS3_STORE_ON_MODIFY @gid, @piOper, @poErrMsg output
     if @ret <> 0
       break;
     fetch next from cur_nstore_rcv into @gid
  end
  close cur_nstore_rcv
  deallocate cur_nstore_rcv
  if @ret <> 0
    return @ret
  
  --新增STORE
  declare cur_nstore_ins cursor for
    select GID from NSTORE(nolock) where TYPE = 1 and GID not in (select GID from STORE(nolock))
  open cur_nstore_ins 
  fetch next from cur_nstore_ins into @gid
  while @@fetch_status = 0
  begin
    insert into STORE (GID, CODE, NAME, ADDRESS, PHONE, CONTACTOR,
           UPD, PROPERTY, SNDFLAG, SYSPATH,
           SVRNAME, MAINDB, POOLDB, DOMAIN, OSUSERNAME, OSPWD, DBUSERNAME, DBPWD,
           E_MAIL, MAILPWD, E_MAILPHONE, POP3, SMTP, COMMPHONE, VERSION, DBMS, mailacct, E_MAIL2,
           MAILPWD2, E_MAILPHONE2, POP32, SMTP2, mailacct2,
           FTPServer, FTPUser, FTPPwd, FTPPortNO, FTPDir, UPPERORG)
    select GID, CODE, NAME, ADDRESS, PHONE, CONTACTOR,
           UPD, PROPERTY, SNDFLAG, SYSPATH,
           SVRNAME, MAINDB, POOLDB, DOMAIN, OSUSERNAME, OSPWD, DBUSERNAME, DBPWD,
           E_MAIL, MAILPWD, E_MAILPHONE, POP3, SMTP, COMMPHONE, VERSION, DBMS, mailacct, E_MAIL2,
           MAILPWD2, E_MAILPHONE2, POP32, SMTP2, mailacct2,
           FTPServer, FTPUser, FTPPwd, FTPPortNO, FTPDir, UPPERORG
    from NSTORE where GID = @gid
    exec @ret = PS3_STORE_ON_ADDNEW @gid, @piOper, @poErrMsg output
    if @ret <> 0
      break;
    fetch next from cur_nstore_ins into @gid
  end
  close cur_nstore_ins
  deallocate cur_nstore_ins
  if @ret <> 0
    return @ret
  
  delete from NSTORE where TYPE = 1
  return 0
end
GO
