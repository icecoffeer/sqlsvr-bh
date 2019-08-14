CREATE TABLE [dbo].[NEMPLOYEEGROUP]
(
[ID] [int] NOT NULL,
[GID] [int] NOT NULL,
[NO] [smallint] NOT NULL,
[NAME] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RIGHT] [text] COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NEMPLOYEE__RIGHT__4CA6BE1A] DEFAULT (''),
[EXTRARIGHT] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NEMPLOYEE__EXTRA__4D9AE253] DEFAULT (''),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NEMPLOYEEGR__SRC__4E8F068C] DEFAULT (1),
[SNDTIME] [datetime] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NEMPLOYEEGROUP] ADD CONSTRAINT [PK__NEMPLOYEEGROUP__4F832AC5] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NEMPLOYEEGROUP_TYPE] ON [dbo].[NEMPLOYEEGROUP] ([TYPE]) ON [PRIMARY]
GO
