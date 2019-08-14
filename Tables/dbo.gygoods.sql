CREATE TABLE [dbo].[gygoods]
(
[spid] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fcid] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[bz] [varchar] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[sale] [varchar] (1) COLLATE Chinese_PRC_CI_AS NULL,
[inprc] [float] NULL,
[rtlprc] [float] NULL,
[gid] [int] NOT NULL CONSTRAINT [DF__gygoods__gid__7B9CE01B] DEFAULT (0)
) ON [PRIMARY]
GO
