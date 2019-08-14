CREATE TABLE [dbo].[STORE]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[PHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CONTACTOR] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[UPD] [smallint] NULL,
[PROPERTY] [smallint] NULL CONSTRAINT [DF__STORE__PROPERTY__39F86E99] DEFAULT (2),
[OUTPRC] [char] (30) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__STORE__OUTPRC__3AEC92D2] DEFAULT ('RTLPRC'),
[SYSPATH] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[LASTEXCHANGEDATETIME] [datetime] NULL,
[LASTEXCHANGETIME] [datetime] NULL,
[AREA] [char] (10) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__STORE__AREA__3BE0B70B] DEFAULT ('-'),
[MSD] [int] NULL CONSTRAINT [DF__STORE__MSD__3CD4DB44] DEFAULT (0),
[YSD] [int] NULL CONSTRAINT [DF__STORE__YSD__3DC8FF7D] DEFAULT (0),
[SNDFLAG] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SVRNAME] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[MAINDB] [char] (40) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__store__MAINDB__4D61141F] DEFAULT ('HD31'),
[POOLDB] [char] (40) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__store__POOLDB__4E553858] DEFAULT ('HD31Buypool'),
[DOMAIN] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[OSUSERNAME] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[OSPWD] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[DBUSERNAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[DBPWD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[IPAFLAG] [smallint] NOT NULL CONSTRAINT [DF__STORE__IPAFLAG__139F5235] DEFAULT (1),
[ISLTD] [smallint] NOT NULL CONSTRAINT [DF__store__ISLTD__52E4E34B] DEFAULT (0),
[LICENSE] [char] (41) COLLATE Chinese_PRC_CI_AS NULL,
[E_MAIL] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[MAILPWD] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[E_MAILPHONE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[POP3] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SMTP] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[COMMPHONE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[VERSION] [varchar] (3) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__VERSION__66E1BA57] DEFAULT ('3.0'),
[DBMS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__DBMS__67D5DE90] DEFAULT ('MSSQL'),
[mailacct] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[E_MAIL2] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[MAILPWD2] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[E_MAILPHONE2] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[POP32] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SMTP2] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[mailacct2] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[FTPServer] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__FTPServer__68CA02C9] DEFAULT (''),
[FTPUser] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__FTPUser__69BE2702] DEFAULT (''),
[FTPPwd] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__FTPPwd__6AB24B3B] DEFAULT (''),
[FTPPortNO] [int] NOT NULL CONSTRAINT [DF__store__FTPPortNO__6BA66F74] DEFAULT (21),
[FTPDir] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__FTPDir__6C9A93AD] DEFAULT ('/'),
[SCOSCHEME] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__store__SCOSCHEME__37F1C144] DEFAULT ('-'),
[ACCOUNTCLASS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__STORE__ACCOUNTCL__6193C0AC] DEFAULT (null),
[ORGDOMAIN] [char] (38) COLLATE Chinese_PRC_CI_AS NULL,
[UPPERORG] [int] NULL,
[REMARK] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TOPRTLPRCCHK] [int] NOT NULL CONSTRAINT [DF__STORE__TOPRTLPRC__295BEB2F] DEFAULT (0),
[AlcScheme] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[STORE_DLT] on [dbo].[STORE] for delete as
begin
	delete from VENDOR
	from deleted
	where VENDOR.GID = deleted.GID

	delete from VENDORH
	from deleted
	where VENDORH.GID = deleted.GID

	delete from CLIENT
	from deleted
	where CLIENT.GID = deleted.GID

	delete from CLIENTH
	from deleted
	where CLIENTH.GID = deleted.GID

/*2001-08-27:便利版并入标准版*/
      if exists (select 1 from warehouse, deleted where warehouse.gid = deleted.gid)
	delete from WAREHOUSE
	from deleted
	where WAREHOUSE.GID = deleted.GID
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[STORE_INS] on [dbo].[STORE] for insert as
begin
	insert into VENDOR (GID, CODE, NAME, ADDRESS, TELE, CONTACTOR, SRC, CREATEDATE)
	select GID, CODE, NAME, ADDRESS, PHONE, CONTACTOR, 1, GetDate()
	from inserted
	where GID not in (select GID from VENDORH)
/*2001-3-31 陈庆洪*/
	insert into CLIENT (GID, CODE, NAME, ADDRESS, TELE, CONTACTOR, SRC, MASTERCLN, ISLTD)
	select GID, CODE, NAME, ADDRESS, PHONE, CONTACTOR, 1, GID, case ISLTD when 1 then 4 else 0 end
	from inserted
	where GID not in (select GID from CLIENTH)
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[STORE_UPD] on [dbo].[STORE] for update as
begin
	declare @USerGID int

	update VENDOR
	set CODE = inserted.CODE,
		NAME = inserted.NAME,
		ADDRESS = inserted.ADDRESS,
		TELE = inserted.PHONE,
		CONTACTOR = inserted.CONTACTOR
	from inserted
	where VENDOR.GID = inserted.GID

	update CLIENT
	set CODE = inserted.CODE,
		NAME = inserted.NAME,
		ADDRESS = inserted.ADDRESS,
		TELE = inserted.PHONE,
		CONTACTOR = inserted.CONTACTOR,
		ISLTD = case inserted.ISLTD when 1 then 4 else 0 end
	from inserted
	where CLIENT.GID = inserted.GID

	update SYSTEM
	set USERCODE = inserted.CODE,
		USERNAME = inserted.NAME,
		UPD = inserted.UPD,
		USERPROPERTY = inserted.PROPERTY
	from inserted
	where SYSTEM.USERGID = inserted.GID

/*2001-08-27:便利版并入标准版*/
      if exists (select 1 from warehouse, inserted where warehouse.gid = inserted.gid)
	update WAREHOUSE
	set CODE = inserted.CODE,
		NAME = inserted.NAME
	from inserted
	where WAREHOUSE.GID = inserted.GID
end
GO
ALTER TABLE [dbo].[STORE] ADD CONSTRAINT [PK__STORE__4FB2A58E] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STORE] ADD CONSTRAINT [UQ__STORE__2759D01A] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
