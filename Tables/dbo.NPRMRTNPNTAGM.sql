CREATE TABLE [dbo].[NPRMRTNPNTAGM]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL CONSTRAINT [DF__NPRMRTNPN__SETTL__1927E56B] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NPRMRTNPNT__STAT__1A1C09A4] DEFAULT (0),
[RECCNT] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NPRMRTNPN__FILDA__1B102DDD] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NOT NULL,
[BEGINTIME] [datetime] NOT NULL CONSTRAINT [DF__NPRMRTNPN__BEGIN__1C045216] DEFAULT (getdate()),
[ENDTIME] [datetime] NOT NULL CONSTRAINT [DF__NPRMRTNPN__ENDTI__1CF8764F] DEFAULT ('9999.12.31 23:59:59'),
[AUTOGEN] [smallint] NOT NULL CONSTRAINT [DF__NPRMRTNPN__AUTOG__1DEC9A88] DEFAULT (0),
[GENTIME] [datetime] NULL,
[RTNSTAT] [smallint] NOT NULL CONSTRAINT [DF__NPRMRTNPN__RTNST__1EE0BEC1] DEFAULT (0),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NPRMRTNPN__LSTUP__1FD4E2FA] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NPRMRTNPN__LSTUP__20C90733] DEFAULT ('未知[-]'),
[CHKTIME] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPRMRTNPNTAGM] ADD CONSTRAINT [PK__NPRMRTNPNTAGM__21BD2B6C] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPRMRTNPNTAGM_NUM] ON [dbo].[NPRMRTNPNTAGM] ([NUM]) ON [PRIMARY]
GO