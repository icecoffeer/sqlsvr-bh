CREATE TABLE [dbo].[fccode]
(
[id] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[tel] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[hd] [varchar] (15) COLLATE Chinese_PRC_CI_AS NULL,
[bp] [varchar] (15) COLLATE Chinese_PRC_CI_AS NULL,
[addr] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[lxr] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[gid] [int] NOT NULL CONSTRAINT [DF__fccode__gid__50B28216] DEFAULT (0)
) ON [PRIMARY]
GO
