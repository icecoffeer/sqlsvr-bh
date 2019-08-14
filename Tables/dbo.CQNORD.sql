CREATE TABLE [dbo].[CQNORD]
(
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNORD__NSTAT__4CF961D0] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNORD__EXTIME__4DED8609] DEFAULT (getdate()),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[VENDOR] [int] NOT NULL CONSTRAINT [DF__CQNORD__VENDOR__4EE1AA42] DEFAULT (1),
[TOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNORD__TOTAL__4FD5CE7B] DEFAULT (0),
[TAX] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNORD__TAX__50C9F2B4] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__CQNORD__FILDATE__51BE16ED] DEFAULT (getdate()),
[PAYDATE] [datetime] NULL,
[PREPAY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNORD__PREPAY__52B23B26] DEFAULT (0),
[FILLER] [int] NOT NULL CONSTRAINT [DF__CQNORD__FILLER__53A65F5F] DEFAULT (1),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__CQNORD__CHECKER__549A8398] DEFAULT (1),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__CQNORD__STAT__558EA7D1] DEFAULT (0),
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[WRH] [int] NOT NULL CONSTRAINT [DF__CQNORD__WRH__5682CC0A] DEFAULT (1),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__CQNORD__RECCNT__5776F043] DEFAULT (0),
[SRC] [int] NOT NULL,
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[RECEIVER] [int] NOT NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__CQNORD__PSR__586B147C] DEFAULT (1),
[PRNTIME] [datetime] NULL,
[FINISHED] [smallint] NOT NULL CONSTRAINT [DF__CQNORD__FINISHED__595F38B5] DEFAULT (0),
[EXPDATE] [datetime] NULL,
[ALCCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PRECHECKER] [int] NULL,
[PRECHKDATE] [datetime] NULL,
[DLVBDATE] [datetime] NULL,
[DLVEDATE] [datetime] NULL,
[IMPFLAG] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[ALCGID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNORD] ADD CONSTRAINT [PK__CQNORD__5A535CEE] PRIMARY KEY CLUSTERED  ([GROUPID], [NUM]) ON [PRIMARY]
GO
