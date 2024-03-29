CREATE TABLE [dbo].[NSTOREPRCSCHEME]
(
[ID] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[CLS] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NSTOREPRCSC__CLS__6089C283] DEFAULT ('核算售价'),
[CODE] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NSTOREPRCSC__SRC__617DE6BC] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTOREPRCSCHEME] ADD CONSTRAINT [PK__NSTOREPRCSCHEME__5F959E4A] PRIMARY KEY CLUSTERED  ([SRC], [RCV], [ID], [CODE], [STOREGID], [CLS]) ON [PRIMARY]
GO
