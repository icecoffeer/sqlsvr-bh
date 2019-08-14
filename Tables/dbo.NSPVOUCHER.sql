CREATE TABLE [dbo].[NSPVOUCHER]
(
[ID] [int] NOT NULL,
[SRC] [int] NOT NULL,
[SN] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NSPVOUCHER__SN__05DCD971] DEFAULT (''),
[STAT] [int] NOT NULL CONSTRAINT [DF__NSPVOUCHER__STAT__06D0FDAA] DEFAULT (0),
[PHASE] [int] NOT NULL CONSTRAINT [DF__NSPVOUCHE__PHASE__07C521E3] DEFAULT (0),
[FILDATE] [datetime] NULL,
[SALEAMT] [decimal] (24, 2) NULL CONSTRAINT [DF__NSPVOUCHE__SALEA__08B9461C] DEFAULT (0),
[ENSN] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[BESOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[BESSRC] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[HANDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[HANDSRC] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[HANDTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSPVOUCHER] ADD CONSTRAINT [PK__NSPVOUCHER__04E8B538] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO