CREATE TABLE [dbo].[STOREORDAPPLY]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[VENDORGID] [int] NOT NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__STOREORDA__RECCN__094F0E50] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__STOREORDAP__STAT__0A433289] DEFAULT (0),
[FILLER] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILLDATE] [datetime] NOT NULL CONSTRAINT [DF__STOREORDA__FILLD__0B3756C2] DEFAULT (getdate()),
[OPDATE] [datetime] NULL,
[GENNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[MEMO] [varchar] (256) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [int] NOT NULL CONSTRAINT [DF__STOREORDAP__TYPE__0C2B7AFB] DEFAULT (0),
[TAXRATELMT] [decimal] (24, 4) NULL,
[DEPTLMT] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[CHECKER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[GENNUM2] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NULL,
[APPLYDGID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STOREORDAPPLY] ADD CONSTRAINT [PK__StoreOrdApply__0D1F9F34] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO