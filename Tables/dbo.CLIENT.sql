CREATE TABLE [dbo].[CLIENT]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SHORTNAME] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TAXNO] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[ACCOUNTNO] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FAX] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ZIP] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[TELE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__NEW_CLIEN__CREAT__10E215C4] DEFAULT (getdate()),
[PROPERTY] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLEACCOUNT] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[PAYTERM] [smallint] NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LAWREP] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CONTACTOR] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CTRPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CTRBP] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NEW_CLIENT__SRC__11D639FD] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NEW_CLIEN__LSTUP__12CA5E36] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__NEW_CLIEN__FILLE__13BE826F] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__NEW_CLIEN__MODIF__14B2A6A8] DEFAULT (1),
[OUTPRC] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NEW_CLIEN__OUTPR__15A6CAE1] DEFAULT ('WHSPRC'),
[EMAILADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[WWWADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CDTLMT] [money] NULL,
[IDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LASTTIME] [datetime] NULL,
[TOTAL] [money] NOT NULL CONSTRAINT [DF__NEW_CLIEN__TOTAL__169AEF1A] DEFAULT (0),
[FAVAMT] [money] NOT NULL CONSTRAINT [DF__NEW_CLIEN__FAVAM__178F1353] DEFAULT (0),
[TLCNT] [int] NOT NULL CONSTRAINT [DF__NEW_CLIEN__TLCNT__1883378C] DEFAULT (0),
[TLGD] [money] NOT NULL CONSTRAINT [DF__NEW_CLIENT__TLGD__19775BC5] DEFAULT (0),
[ADDR2] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SEX] [smallint] NULL CONSTRAINT [DF__NEW_CLIENT__SEX__1A6B7FFE] DEFAULT (0),
[BIRTHDAY] [datetime] NULL,
[COMPANY] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FAMILIES] [int] NULL,
[INCOME] [money] NULL,
[HOBBY] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[TRAFFIC] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TRANSACTOR] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[WEDDINGDAY] [datetime] NULL,
[FAVCOLOR] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OTHER] [varchar] (60) COLLATE Chinese_PRC_CI_AS NULL,
[MOBILEPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[BP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[BALANCE] [money] NOT NULL CONSTRAINT [DF__NEW_CLIEN__BALAN__1B5FA437] DEFAULT (0),
[MAXOVERDRAFT] [money] NOT NULL CONSTRAINT [DF__NEW_CLIEN__MAXOV__1C53C870] DEFAULT (0),
[DETAILLEVEL] [smallint] NOT NULL CONSTRAINT [DF__NEW_CLIEN__DETAI__1D47ECA9] DEFAULT (0),
[CREDIT] [smallint] NOT NULL CONSTRAINT [DF__NEW_CLIEN__CREDI__1E3C10E2] DEFAULT (0),
[MASTERCLN] [int] NULL,
[BACKBUYTOTAL] [money] NULL CONSTRAINT [DF__NEW_CLIEN__BACKB__1F30351B] DEFAULT (0),
[ISLTD] [smallint] NOT NULL CONSTRAINT [DF__client__ISLTD__53D90784] DEFAULT (0),
[STYLE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[WSLIMIT] [int] NOT NULL CONSTRAINT [DF__Client__WSLIMIT__0E7B75BC] DEFAULT (0),
[PayCls] [smallint] NULL CONSTRAINT [DF__Client__PayCls__778EBA1A] DEFAULT (2),
[AREA] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TRADE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[CLNT_DLT] on [dbo].[CLIENT] for delete as
begin
  if exists (select * from deleted where GID = 1)
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
  end
  if exists (
    select * from deleted, V_CSTYRPT
    where deleted.GID = V_CSTYRPT.BCSTGID
    and (NPQTY <> 0 or NPTL <> 0)
  ) begin
    rollback transaction
    raiserror('不能删除未结客户', 16, 1)
  end
  if exists (
    select * from deleted, store
    where deleted.GID = store.gid
  ) begin
    rollback transaction
    raiserror('不能删除存在对应门店的客户', 16, 1)
  end
  delete from CLNXLATE where LGID in (select GID from deleted)

  /* 2000.1.11 LiQi */
  UPDATE CARD SET STATE = 2 WHERE CSTGID IN (SELECT GID FROM DELETED)
  UPDATE CARD SET STATE = 2 WHERE CSTGID IN (SELECT GID FROM CLIENT
  WHERE MASTERCLN IN (SELECT GID FROM DELETED))
  DELETE FROM CLIENT WHERE MASTERCLN IN (SELECT GID FROM DELETED)
  AND MASTERCLN <> GID
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[CLNT_INS] on [dbo].[CLIENT] for insert as
begin
  insert into CLIENTH
    select * from inserted
  insert into CLNXLATE (NGID,LGID) select GID,GID from inserted
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[CLNT_UPD] on [dbo].[CLIENT] for update as
begin
  delete from CLIENTH
    from DELETED
    where CLIENTH.GID = DELETED.GID
  insert into CLIENTH
    select * from INSERTED
end

GO
ALTER TABLE [dbo].[CLIENT] ADD CONSTRAINT [PK__CLIENT__4979DDF4] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLIENT] ADD CONSTRAINT [UQ__CLIENT__2C88998B] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
